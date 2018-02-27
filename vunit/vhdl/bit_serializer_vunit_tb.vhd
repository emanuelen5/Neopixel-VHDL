library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.neopixel_pkg.all;
use work.bit_serialized_vunit_tb_pkg.all;

use work.message_types_pkg.all;
use work.message_codecs_pkg.all;

entity bit_serializer_vunit_tb is
  generic (
    runner_cfg  : string := runner_cfg_default;
    output_path : string;
    tb_path     : string
  );
end entity; -- bit_serializer_vunit_tb

architecture arch of bit_serializer_vunit_tb is
  signal clk   : std_logic := '1';
  signal rst_n : std_logic := '0';
  signal valid, ready : boolean := false;
  signal color        : rgb_color_t := black;
  signal serialized   : std_logic := '0';
  constant clk_period : time := 10 ns;
begin

  clk <= not clk after clk_period/2;

  tests : process
    variable self_bit : actor_t := create("tests_bit");
    variable self_color : actor_t := create("tests_color");
    variable proc_check_bit : actor_t := find("check_bit");
    variable proc_send_color : actor_t := find("send_color");
    variable message : message_ptr_t;
    variable receipt : receipt_t;
    variable sent_value : rgb_color_t;
    variable decoded_bit : std_logic;
    variable ticks : natural;

    procedure check_equal (
      expected, actual : rgb_color_t;
      msg : string := ""
    ) is
    begin
      check_equal(expected.red, actual.red, join("Red is not equal: ", msg));
      check_equal(expected.green, actual.green, join("Green is not equal: ", msg));
      check_equal(expected.blue, actual.blue, join("Blue is not equal: ", msg));
    end procedure;

    procedure queue_color (
      constant send_value : rgb_color_t
    ) is
    begin
      send(net, proc_send_color, color_m(send_value.red, send_value.blue, send_value.green), receipt);
    end procedure;

    procedure receive_bit (
      constant expected : std_logic := '-';
      constant msg : string := ""
    ) is
    begin
      receive(net, self_bit, message, 10 * clk_period);
      if message.status = timeout then
        check_failed("The line was never pulled high by the bit serializer");
      end if;
      decoded_bit := decode(message.payload.all);
      if expected /= '-' then
        check_equal(decoded_bit, expected, "Comparison between sent value and intrepreted value");
      end if;
    end procedure receive_bit;

    procedure queue_color_check_received (
      constant send_value : rgb_color_t 
    ) is
      variable tmp_color : rgb_color_t := black;
    begin
      queue_color(send_value);
      for color_index in 1 to 3 loop
        for bit_index in 0 to 7 loop
          receive_bit;
          if message.status = timeout then
            check_failed("The line was never pulled high by the bit serializer");
          end if;
        end loop;
        case color_index is
          when 1 =>
            tmp_color.red(color_index) := decoded_bit;
          when 2 =>
            tmp_color.green(color_index) := decoded_bit;
          when 3 =>
            tmp_color.blue(color_index) := decoded_bit;
        end case;
      end loop;
      check_equal(tmp_color, send_value, "Comparison between sent value and intrepreted value");
    end procedure queue_color_check_received;
  begin
    test_runner_setup(runner, runner_cfg);
    checker_init(stop_level => failure);
    rst_n <= '1';

    while test_suite loop
      if run("Output is zero on reset") then
        rst_n <= '0';
        wait for clk_period;
        check_equal(serialized, '0');
      elsif run("1 timing") then
        queue_color(white);
        receive_bit('1');
      elsif run("0 timing") then
        queue_color(black);
        receive_bit('0');
      elsif run("Serialization: White (only ones)") then
        queue_color_check_received(white);
      elsif run("Serialization: Black (only zeros)") then
        queue_color_check_received(black);
      elsif run("Timeout when no data within RES") then
        check_failed("Not implemented yet");
      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
    wait;
  end process;

  test_runner_watchdog(runner, 10 ms);

  decode_serialized_bit : process
    variable self : actor_t := create("check_bit");
    variable proc_tests_bit : actor_t := find("tests_bit");
    variable message : message_ptr_t;
    variable expected_value : std_logic;
    variable receipt : receipt_t;
    variable interpreted_high : bit;
  begin
    wait on clk until serialized = '1';
    wait on clk until serialized = '0';
    interpreted_high := '1' when serialized'last_event > T0.H.maximum else '0';
    send(net, proc_tests_bit, encode(interpreted_high), receipt);
  end process;

  send_serialized_bit : process
    variable self : actor_t := create("send_color");
    variable message : message_ptr_t;
    variable send_value : rgb_color_t;
    variable receipt : receipt_t;
  begin
    receive(net, self, message);
    send_value := to_rgb_color_t(decode(message.payload.all));
    info("send_serialized_bit: Queueing color '" & message.payload.all & "' to be sent serially...");
    valid <= true;
    color <= send_value;
    wait until rising_edge(clk) and ready;
    valid <= false;
    info("send_serialized_bit: Sent!");
  end process;

  bs_i0 : bit_serializer
  generic map (
    clk_frequency => 50.0e6
  )
  port map (
    clk        => clk,
    rst_n      => rst_n,
    color      => color,
    valid_s    => valid,
    ready_s    => ready,
    serialized => serialized
  );
  
end architecture; -- arch
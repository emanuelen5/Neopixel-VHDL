library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.neopixel_pkg.all;
use work.bit_serialized_vunit_tb_pkg.all;

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
  signal color_bit    : std_logic := '0';
  signal serialized   : std_logic := '0';
  constant clk_period : time := 10 ns;
begin

  clk <= not clk after clk_period/2;

  tests : process
    variable self : actor_t := create("tests");
    variable proc_check_bit : actor_t := find("check_bit");
    variable proc_send_bit : actor_t := find("send_bit");
    variable message : message_ptr_t;
    variable receipt : receipt_t;
    variable sent_value : std_logic;
    variable ticks : natural;

    procedure queue_bit_check_received (
      constant send_value : std_logic 
    ) is
    begin
      send(net, proc_send_bit, encode(send_value), receipt);
      receive(net, self, message, 10 * clk_period);
      if message.status = timeout then
        check_failed("The line was never pulled high by the bit serializer");
      end if;
      sent_value := decode(message.payload.all);
      check_equal(sent_value, send_value, "Comparison between sent value and intrepreted value");
    end procedure queue_bit_check_received;
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
        queue_bit_check_received('1');
      elsif run("0 timing") then
        queue_bit_check_received('0');
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
    variable proc_tests : actor_t := find("tests");
    variable message : message_ptr_t;
    variable expected_value : std_logic;
    variable receipt : receipt_t;
    variable interpreted_high : bit;
  begin
    wait on clk until serialized = '1';
    wait on clk until serialized = '0';
    interpreted_high := '1' when serialized'last_event > T0.H.maximum else '0';
    send(net, proc_tests, encode(interpreted_high), receipt);
  end process;

  send_serialized_bit : process
    variable self : actor_t := create("send_bit");
    variable message : message_ptr_t;
    variable send_value : std_logic;
    variable receipt : receipt_t;
  begin
    receive(net, self, message);
    send_value := decode(message.payload.all);
    info("send_serialized_bit: Queueing '" & message.payload.all & "' to send serially...");
    valid <= true;
    color_bit <= send_value;
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
    color_bit  => color_bit,
    valid_s    => valid,
    ready_s    => ready,
    serialized => serialized
  );
  
end architecture; -- arch
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library osvvm;
  use osvvm.RandomPkg.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.neopixel_pkg.all;
use work.bit_serializer_vunit_tb_pkg.all;

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
  signal valid, ready : std_logic := '0';
  signal last         : std_logic := '0';
  signal color        : rgb_color_t := neopixel_black;
  signal serialized   : std_logic := '0';
  constant frequency : real := 50.0e6;
  constant clk_period : time := 1.0 us / (frequency / 1.0e6);
begin

  clk <= not clk after clk_period/2;

  tests : process
    constant self_bit : actor_t := new_actor("tests_bit");
    constant self_color : actor_t := new_actor("tests_color");
    constant proc_check_bit : actor_t := find("check_bit");
    constant proc_send_color : actor_t := find("send_color");
    variable message : msg_t;
    variable sent_value : rgb_color_t;
    variable ticks : natural;

    procedure check_equal (
      actual, expected : rgb_color_t;
      msg : string := ""
    ) is
    begin
      check_equal(actual.red, expected.red, join("Red is not equal: ", msg));
      check_equal(actual.green, expected.green, join("Green is not equal: ", msg));
      check_equal(actual.blue, expected.blue, join("Blue is not equal: ", msg));
    end procedure;

    procedure queue_color (
      constant send_value : rgb_color_t;
      constant last_value : std_logic := '0'
    ) is
    begin
      write(net, proc_send_color, send_value, last_value);
    end procedure;

    procedure receive_bit (
      variable decoded_bit : out std_logic
    ) is
    begin
      receive(net, self_bit, message, 10 ms);
      if message.status = timeout then
        check_failed("The line was never pulled high by the bit serializer", level => failure);
      end if;
      decoded_bit := pop(message);
    end procedure receive_bit;

    procedure expect_bit (
      constant expected    : in  std_logic := '-';
      constant msg         : in  string    := ""
    ) is
      variable decoded_bit : std_logic;
    begin
      receive(net, self_bit, message, 10 ms);
      if message.status = timeout then
        check_failed("The line was never pulled high by the bit serializer", level => failure);
      end if;
      decoded_bit := pop(message);
      if expected /= '-' then
        check_equal(decoded_bit, expected, "Comparison between sent value and intrepreted value");
      end if;
    end procedure expect_bit;

    procedure queue_color_check_received (
      constant send_value : rgb_color_t;
      constant last       : std_logic := '0'
    ) is
      variable tmp_color : rgb_color_t := neopixel_black;
      variable tmp_bit : std_logic;
    begin
      queue_color(send_value, last);
      for color_index in 1 to 3 loop
        for bit_index in 7 downto 0 loop
          receive_bit(tmp_bit);
          case color_index is
            when 1 =>
              tmp_color.green(bit_index) := tmp_bit;
            when 2 =>
              tmp_color.red(bit_index) := tmp_bit;
            when 3 =>
              tmp_color.blue(bit_index) := tmp_bit;
          end case;
          info("Received bit " & to_string(color_index) & "." & to_string(bit_index) & " = " & to_string(tmp_bit));
        end loop;
      end loop;
      check_equal(tmp_color, send_value, "Comparison between sent value and intrepreted value");
    end procedure queue_color_check_received;

    variable RV : RandomPType;
    variable last_time : time;
  begin
    RV.InitSeed(RV'instance_name);
    test_runner_setup(runner, runner_cfg);
    set_stop_level(failure);
    rst_n <= '1';

    while test_suite loop
      if run("Output is zero on reset") then
        rst_n <= '0';
        wait for clk_period;
        check_equal(serialized, '0');
      elsif run("1 timing") then
        queue_color(neopixel_white);
        expect_bit('1');
      elsif run("0 timing") then
        queue_color(neopixel_black);
        expect_bit('0');
      elsif run("Serialization: White (only ones)") then
        queue_color_check_received(neopixel_white);
      elsif run("Serialization: Black (only zeros)") then
        queue_color_check_received(neopixel_black);
      elsif run("Serialization: Red") then
        queue_color_check_received(
          rgb_color_t'(red => (others => '1'), others => (others => '0'))
        );
      elsif run("Serialization: Random color") then
        queue_color_check_received(
          rgb_color_t'(
            red => RV.RandUnsigned(8),
            green => RV.RandUnsigned(8),
            blue => RV.RandUnsigned(8)
          )
        );
      elsif run("Serialization: Two pixels") then
        queue_color_check_received(neopixel_white);
        queue_color_check_received(neopixel_black);
      elsif run("Timeout: At TLAST") then
        queue_color_check_received(neopixel_black, '1');
        last_time := now;
        queue_color(neopixel_white);
        wait until serialized = '1' for RES.minimum;
        check_relation(now - last_time >= RES.minimum, "Reset should happen after TLAST = '1'. Was low for " & to_string(now - last_time) & ", expected " & to_string(RES.minimum));
      elsif run("Timeout: No data within RES") then
        last_time := now;
        wait until serialized = '1' for RES.minimum;
        check_relation(now - last_time >= RES.minimum, "Reset should happen after TLAST = '1'. Was low for " & to_string(now - last_time) & ", expected " & to_string(RES.minimum));
      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
    wait;
  end process;

  test_runner_watchdog(runner, 10 ms);

  decode_serialized_bit : process
    constant self : actor_t := new_actor("check_bit");
    constant proc_tests_bit : actor_t := find("tests_bit");
    variable message : msg_t;
    variable expected_value : std_logic;
    variable interpreted_high : bit;
    variable start_time : time;
  begin
    if (rst_n = '0') then
      wait until rst_n = '1';
    end if;
    if (serialized /= '1') then
      debug("serialized is not one");
      wait until serialized = '1';
    end if;
    start_time := now;
    debug("serialized is one");
    if (serialized /= '0') then
      wait until serialized = '0';
    end if;
    debug("serialized is zero");
    interpreted_high := '1' when (now - start_time) > T0.H.maximum else '0';
    debug("Time high: " & to_string(now - start_time));
    message := new_msg;
    push(message, interpreted_high);
    send(net, proc_tests_bit, message);
  end process;

  send_serialized_bit : process
    constant self : actor_t := new_actor("send_color");
    variable message : msg_t;
    variable send_value : rgb_color_t;
    variable last_value : std_logic;
    variable color_m_msg : color_m_msg_t;
  begin
    read(net, self, send_value, last_value);
    debug("send_serialized_bit: Queueing color '" & to_string(color_m_msg) & "' to be sent serially...");
    valid <= '1';
    color <= send_value;
    last  <= last_value;
    wait until rising_edge(clk) and ready = '1';
    valid <= '0';
    last  <= '0';
    debug("send_serialized_bit: Sent!");
  end process send_serialized_bit;

  bs_i0 : entity work.bit_serializer
  generic map (
    clk_frequency => frequency
  )
  port map (
    clk        => clk,
    rst_n      => rst_n,
    color      => color,
    valid_s    => valid,
    last_s     => '0',
    ready_s    => ready,
    serialized => serialized
  );

end architecture; -- arch
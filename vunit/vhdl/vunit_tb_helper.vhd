library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.neopixel_pkg.all;

entity vunit_tb_helper is
  generic (
    runner_cfg  : string := runner_cfg_default;
    output_path : string;
    tb_path     : string
  );
end entity; -- vunit_tb_helper

architecture arch of vunit_tb_helper is
begin
  tests : process
    variable ticks : natural;
  begin
    test_runner_setup(runner, runner_cfg);
    checker_init(stop_level => failure);

    while test_suite loop
      if run("Frequency to ticks - no rounding") then
        ticks := frequency_time_to_ticks(1.0e6, 1000 us);
        check_equal(ticks, 1000);
      elsif run("Frequency to ticks - round downward") then
        ticks := frequency_time_to_ticks(1.0e6, 1499 ns);
        check_equal(ticks, 1);
      elsif run("Frequency to ticks - round upward") then
        ticks := frequency_time_to_ticks(1.0e6, 500 ns);
        check_equal(ticks, 1);
      elsif run("Frequency to ticks - twice speed") then
        ticks := frequency_time_to_ticks(2.0e6, 1000 ns);
        check_equal(ticks, 2);
      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
    wait;
  end process;

  test_runner_watchdog(runner, 10 ms);
end architecture; -- arch
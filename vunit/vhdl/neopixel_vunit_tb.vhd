library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.neopixel_pkg.all;

entity neopixel_vunit_tb is
  generic (
    runner_cfg  : string := runner_cfg_default;
    output_path : string;
    tb_path     : string
  );
end entity; -- neopixel_vunit_tb

architecture arch of neopixel_vunit_tb is
begin
  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("test_pass") then
        check_equal(1, 1, "Stupid message");
      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
    wait;
  end process;

  test_runner_watchdog(runner, 10 ms);
  
end architecture; -- arch
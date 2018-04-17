library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;

package bit_serializer_vunit_tb_pkg is
  -- Send a bit to the bit serializer
  procedure send(
    signal clk : in std_logic;
    constant bit_value :  rgb_color_t;
    signal color : out rgb_color_t;
    signal valid : out boolean;
    signal ready : in  boolean
  );

  -- Send a start command to the checker
  procedure pulse_start_flag(
    signal clk : in std_logic;
    signal start_flag : out boolean
  );
end package; -- bit_serializer_vunit_tb_pkg

package body bit_serializer_vunit_tb_pkg is
  procedure send(
    signal clk : in std_logic;
    constant bit_value :  rgb_color_t;
    signal color : out rgb_color_t;
    signal valid : out boolean;
    signal ready : in  boolean
  ) is
  begin
    valid <= true;
    color <= bit_value;
    wait until rising_edge(clk) and ready;
    valid <= false;
  end procedure;

  procedure pulse_start_flag(
    signal clk : in std_logic;
    signal start_flag : out boolean
  ) is
  begin
    start_flag <= true;
    wait until rising_edge(clk);
    start_flag <= false;
  end procedure;
end package body;
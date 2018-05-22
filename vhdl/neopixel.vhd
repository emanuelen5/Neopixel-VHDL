library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity neopixel is
  generic (
    clk_frequency  : real := 50.0e6
  );
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    color   : in  rgb_color_t;
    valid   : in  std_logic; -- Read when ready is '1'
    last    : in  std_logic;
    ready   : out std_logic; -- Ready to accept another color
    serialized_color : out std_logic
  );
end entity; -- neopixel

architecture arch of neopixel is
  signal valid_color : std_logic;
  signal ready_color : std_logic;
  signal color_i : rgb_color_t;
begin

  valid_color <= valid;
  ready <= ready_color;
  color_i <= color;

  -- fifo color in, color out

  bit_s : entity work.bit_serializer
  generic map (
    clk_frequency => clk_frequency
  )
  port map (
    clk        => clk,
    rst_n      => rst_n,
    color      => color_i,
    valid_s    => valid_color,
    last_s     => last,
    ready_s    => ready_color,
    serialized => serialized_color
  );

end architecture; -- arch
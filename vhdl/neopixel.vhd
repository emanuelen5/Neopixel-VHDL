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
    valid   : in  boolean; -- Read when ready is '1'
    ready   : out boolean; -- Ready to accept another color
    serialized_color : out std_logic
  );
end entity; -- neopixel

architecture arch of neopixel is
  signal valid_color : boolean;
  signal ready_color : boolean;
  signal valid_color_bit : boolean;
  signal ready_color_bit : boolean;
  signal color_bit : std_logic;
begin

  valid_color <= valid;
  ready <= ready_color;

  byte_s : color_serializer
  port map (
    clk     => clk,
    rst_n   => rst_n,
    color   => color,
    valid_s => valid_color,
    ready_s => ready_color,
    valid_m => valid_color_bit,
    ready_m => ready_color_bit,
    bit_out => color_bit
  );

  bit_s : bit_serializer
  generic map (
    clk_frequency => clk_frequency
  )
  port map (
    clk        => clk,
    rst_n      => rst_n,
    color_bit  => color_bit,
    valid_s    => valid_color_bit,
    ready_s    => ready_color_bit,
    serialized => serialized_color
  );

end architecture; -- arch
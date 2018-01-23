library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity color_serializer is
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    color   : in  rgb_color_t;
    valid_s : in  boolean; -- Read when ready is '1'
    ready_s : out boolean; -- Ready to accept another color
    valid_m : out boolean;
    ready_m : in  boolean;
    bit_out : out std_logic
  );
end entity; -- color_serializer

architecture arch of color_serializer is
begin

end architecture; -- arch
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity bit_serializer is
  generic (
    frequency_clk : real
  );
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    color_bit  : in  std_logic;
    valid_s    : in  boolean; -- Read when ready is '1'
    ready_s    : out boolean; -- Ready to accept another color
    serialized : out std_logic
  );
end entity; -- bit_serializer

architecture arch of bit_serializer is
begin

end architecture; -- arch
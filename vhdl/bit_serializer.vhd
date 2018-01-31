library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity bit_serializer is
  generic (
    clk_frequency : real
  );
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic := '1';
    color_bit  : in  std_logic;
    valid_s    : in  boolean; -- Read when ready is '1'
    ready_s    : out boolean := true; -- Ready to accept another color
    serialized : out std_logic := '0'
  );
end entity; -- bit_serializer

architecture arch of bit_serializer is
  signal color_bit_i : std_logic;
begin

  

  bit_serializing_process : process (clk, rst_n)
  begin
    if rst_n = '1' then
      serialized <= '0';
      ready_s    <= true;
    elsif rising_edge(clk) then

    end if;
  end process; -- bit_serializing_process

end architecture; -- arch
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package neopixel_pkg is
  type rgb_color_t is record
    red   : std_logic_vector(7 downto 0);
    green : std_logic_vector(7 downto 0);
    blue  : std_logic_vector(7 downto 0);
  end record;

  -- https://cdn-shop.adafruit.com/datasheets/WS2812.pdf
  -- https://wp.josh.com/2014/05/13/ws2812-neopixels-are-not-so-finicky-once-you-get-to-know-them/

  type bit_time_t is record
    H, L  : time;
  end record;

  constant T0 : bit_time_t := (H => 0.35 us, L => 0.80 us);
  constant T1 : bit_time_t := (H => 0.70 us, L => 0.60 us);

  -- TH + TL = 1250ns (+- 600ns)
  -- +- 150 ns
  constant RES : time := 6.00 us; -- 50.0 us according to spec

  component color_serializer
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
  end component; -- color_serializer


  component bit_serializer
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
  end component; -- bit_serializer
end package; -- neopixel_pkg 
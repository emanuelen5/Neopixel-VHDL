library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

package neopixel_pkg is
  subtype color_t is unsigned(7 downto 0);
  type rgb_color_t is record
    red   : color_t;
    green : color_t;
    blue  : color_t;
  end record;

  constant black : rgb_color_t := (
    others => (others => '0')
  ); 
  constant white : rgb_color_t := (
    others => (others => '1')
  ); 

  -- https://cdn-shop.adafruit.com/datasheets/WS2812.pdf
  -- https://wp.josh.com/2014/05/13/ws2812-neopixels-are-not-so-finicky-once-you-get-to-know-them/

  type time_range is record
    minimum, mean, maximum : time;
  end record;
  type tick_range is record
    minimum, mean, maximum : natural;
  end record;

  type high_low_time_t is record
    H, L  : time_range;
  end record;

  constant T0 : high_low_time_t := (
      H => (
          minimum => 0.200 us,
          mean => 0.35 us,
          maximum => 0.5 us
        ),
      L => (
          minimum => 0.65 us,
          mean => 0.80 us,
          maximum => 5 us
        )
    );
  constant T1 : high_low_time_t := (
      H => (
          minimum => 0.55 us,
          mean => 0.70 us,
          maximum => 3600 sec -- No maximum?
        ),
      L => (
          minimum => 0.45 us,
          mean => 0.60 us,
          maximum => 5 us
        )
    );

  -- TH + TL = 1250ns (+- 600ns)
  -- +- 150 ns
  constant RES : time_range := (
      minimum => 6.00 us,
      mean => 6.00 us,
      maximum => 3600 sec
    ); -- 50.0 us according to spec

  function frequency_time_to_ticks(
    freq : real;
    t : time
  ) return natural;

  function to_tick_range (
    constant freq : real;
    constant tr   : time_range
  ) return tick_range;

  component color_serializer is
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

  component bit_serializer is
    generic (
      clk_frequency : real
    );
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      color       : in  rgb_color_t;
      valid_s     : in  boolean; -- Read when ready is '1'
      ready_s     : out boolean; -- Ready to accept another color
      serialized  : out std_logic
    );
  end component; -- bit_serializer

  component neopixel is
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
  end component; -- neopixel
end package; -- neopixel_pkg 

package body neopixel_pkg is
  function frequency_time_to_ticks(
    freq : real;
    t : time
  ) return natural is
    variable ret : natural := 0;
  begin
    assert freq > 0.0 report "Frequency must be positive" severity failure;
    ret := (integer(t * freq / 100 ms) + 5)/10;
    return ret;
  end function;

  function to_tick_range (
    constant freq : real;
    constant tr   : time_range
  ) return tick_range is
    variable ret_var : tick_range;
  begin
    ret_var.minimum := frequency_time_to_ticks(freq, tr.minimum);
    ret_var.mean    := frequency_time_to_ticks(freq, tr.mean);
    ret_var.maximum := frequency_time_to_ticks(freq, tr.maximum);
    return ret_var;
  end function;
end package body; -- neopixel_pkg 
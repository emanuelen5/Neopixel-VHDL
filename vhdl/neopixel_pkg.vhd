library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package neopixel_pkg is
  subtype color_t is unsigned(7 downto 0);
  type rgb_color_t is record
    red   : color_t;
    green : color_t;
    blue  : color_t;
  end record;

  constant neopixel_black : rgb_color_t := (
    others => (others => '0')
  );
  constant neopixel_white : rgb_color_t := (
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

  -- Should be unlimited, but must set some limit
  constant MAX_TIME : time := 36 sec;

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
          maximum => MAX_TIME -- No maximum?
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
      maximum => MAX_TIME
    ); -- 50.0 us according to spec

  function frequency_time_to_ticks(
    freq : real;
    t : time
  ) return natural;

  function to_tick_range (
    constant freq : real;
    constant tr   : time_range
  ) return tick_range;

  component bit_serializer is
    generic (
      clk_frequency : real
    );
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      color       : in  rgb_color_t;
      valid_s     : in  std_logic; -- Read when ready is '1'
      last_s      : in  std_logic;
      ready_s     : out std_logic; -- Ready to accept another color
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
      valid   : in  std_logic; -- Read when ready is '1'
      last    : in  std_logic;
      ready   : out std_logic; -- Ready to accept another color
      serialized_color : out std_logic
    );
  end component; -- neopixel

  function get_bit (
    rgb   : rgb_color_t;
    index : natural range 0 to 23
  ) return std_logic;
end package; -- neopixel_pkg

package body neopixel_pkg is
  function frequency_time_to_ticks(
    freq : real;
    t : time
  ) return natural is
    variable ret : natural := 0;
    variable ticks_per_s : unsigned(31 downto 0);
    variable total_ticks : unsigned(63 downto 0);
    variable divided_ticks : unsigned(63 downto 0);
  begin
    assert freq > 0.0 report "Frequency must be positive" severity failure;
    ticks_per_s := to_unsigned(t / 1.0 ns, 32);
    total_ticks := ticks_per_s * integer(freq);
    divided_ticks := total_ticks / 1e9;
    ret := to_integer(divided_ticks);
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

  function get_bit (
    rgb   : rgb_color_t;
    index : natural range 0 to 23
  ) return std_logic is
  begin
    if (index < 8) then
      return std_logic(rgb.green(7 - index));
    elsif (index < 16) then
      return std_logic(rgb.red(15 - index));
    else
      return std_logic(rgb.blue(23 - index));
    end if;
  end function;
end package body; -- neopixel_pkg
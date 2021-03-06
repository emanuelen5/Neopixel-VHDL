library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity neestori_top is
    port (
        clock          : in  std_logic;
        button         : in  std_logic;
        led_out        : out std_logic_vector(2 downto 0);
        neo_serialized : out std_logic
    );
end entity neestori_top;

architecture arch of neestori_top is
    signal led_out_inverted       : std_logic_vector(led_out'range);
    signal rst                    : std_logic;
    signal rst_n                  : std_logic := '0';
    signal button_debounced       : std_logic := '0';
    constant C_MAX_DEBOUNCE_COUNT : natural   := 5000000;
    signal color : rgb_color_t := (
        red   => to_unsigned(0, 8),
        green => to_unsigned(0, 8),
        blue  => to_unsigned(0, 8)
    );
    signal valid_s : std_logic := '1';
    signal ready_s : std_logic;
    signal last_s  : std_logic := '1';
begin

    rst_n                        <= '1';
    rst                          <= not rst_n;
    led_out                      <= not led_out_inverted;
    led_out_inverted(2 downto 0) <= (
        others => button_debounced
    );

    -- Debounce the button
    u0_debounce : entity work.debouncer
        generic map (
            G_DELAY => C_MAX_DEBOUNCE_COUNT
        )
        port map (
            clock     => clock,
            rst_n     => rst_n,
            button    => button,
            debounced => button_debounced
        );

    bit_serializer_1 : entity work.bit_serializer
        generic map (
            clk_frequency => 50.0e6
        )
        port map (
            clk        => clock,
            rst_n      => rst_n,
            color      => color,
            valid_s    => valid_s,
            last_s     => last_s,
            ready_s    => ready_s,
            serialized => neo_serialized
        );

    process (clock, rst_n)
        variable last_button : std_logic := '0';
        variable led_cnt : integer := 0;
        constant MAX_CNT : integer := 5;
        variable change_color : integer := 0;
        constant delay : integer := 25;
    begin
        if rst_n = '0' then
        elsif rising_edge(clock) then
            if (valid_s = '1' and ready_s = '1') then
                if led_cnt >= MAX_CNT-1 then
                    led_cnt := 0;
                    last_s <= '1';

                    if change_color >= delay then
                        change_color := 0;
                        color <= (red => color.red + 1, green => color.green, blue => color.blue);
                    else
                        change_color := change_color + 1;
                    end if;
                else
                    led_cnt := led_cnt + 1;
                    last_s <= '0';
                end if;
            end if;

            -- The button is pressed
            if (button_debounced = '0' and last_button = '1') then
                color <= (red => color.blue, green => color.red, blue => color.green);
            end if;
            last_button := button_debounced;
        end if;
    end process;

end architecture arch;
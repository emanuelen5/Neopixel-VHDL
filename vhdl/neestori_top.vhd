library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity neestori_top is
    port (
        clock   : in  std_logic;
        button  : in  std_logic;
        led_out : out std_logic_vector(2 downto 0)
    );
end entity neestori_top;

architecture arch of neestori_top is
    constant c_counter_width      : natural := 30;
    signal led_out_inverted       : std_logic_vector(led_out'range);
    signal counter_i              : std_logic_vector(c_counter_width-1 downto 0);
    signal clock_pll              : std_logic;
    signal rst                    : std_logic;
    signal rst_n                  : std_logic := '0';
    signal counter_frequency      : integer   := 0;
    signal button_debounced       : std_logic := '0';
    constant C_MAX_DEBOUNCE_COUNT : natural   := 5000000;
begin

    rst_n                        <= '1';
    rst                          <= not rst_n;
    led_out                      <= not led_out_inverted;
    --led_out_inverted <= std_logic_vector(to_unsigned(counter_frequency, 3));
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

    -- Use the button
    process (clock, rst_n)
        variable last_button : std_logic := '0';
    begin
        if rst_n = '0' then
            counter_frequency <= 0;
        elsif rising_edge(clock) then
            if (button_debounced = '0' and last_button = '1') then
                if counter_frequency <= 10 then
                    counter_frequency <= counter_frequency + 1;
                else
                    counter_frequency <= 0;
                end if;
            end if;
            last_button := button_debounced;
        end if;
    end process;

end architecture arch;
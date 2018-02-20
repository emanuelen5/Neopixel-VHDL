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
    -- Some aliases to help overloading
    constant T0H_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T0.H);
    constant T0L_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T0.L);
    constant T1H_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T1.H);
    constant T1L_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T1.L);
    constant RES_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.RES);

    -- The stored value for the 
    signal color_bit_reg : std_logic;

    type serialization_state is (reset, high, low, res, done);
    signal serializer_state : serialization_state;
    signal chosen_ticks : tick_range;
    signal count : natural;
begin
    state_signal_driver : process(all)
    begin
        case serializer_state is
            when reset =>
                ready_s <= false;
            when done =>
                ready_s <= true;
            when low =>
                ready_s <= true;
            when others =>
                ready_s <= false;
        end case;
    end process;

    state_machine_transitions : process(clk, rst_n)
    begin
        if rst_n = '1' then
            chosen_ticks <= RES_ticks;
            serializer_state <= reset;
        elsif rising_edge(clk) then
            case serializer_state is
                when reset =>
                    serializer_state <= done;
                when done =>
                    -- Go to next state if there is a valid color present
                    if valid_s then
                        color_bit_reg <= color_bit;
                        if color_bit = '1' then
                            chosen_ticks <= T0H_ticks;
                        elsif color_bit = '1' then
                            chosen_ticks <= T1H_ticks;
                        end if;
                    end if;

                when high =>
                    null;
                when others =>
                    serializer_state <= reset;
             end case;
        end if;
    end process; -- state_machine_transitions

    counter_proc : process(clk)
    begin
        if rising_edge(clk) then
            case serializer_state is
                when high | low | res =>
                    count <= count + 1;
                when reset | done =>
                    count <= 0;
                when others =>
                    count <= 0;
            end case;
        end if;
    end process; -- counter_proc

end architecture; -- arch
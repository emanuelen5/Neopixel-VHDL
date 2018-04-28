library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.neopixel_pkg.all;

entity bit_serializer is
    generic (
        clk_frequency : real
    );
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic := '1';
        color       : in  rgb_color_t;
        valid_s     : in  boolean; -- Read when ready is '1'
        ready_s     : out boolean := true; -- Ready to accept another color bit
        serialized  : out std_logic := '0'
    );
end entity; -- bit_serializer

architecture arch of bit_serializer is
    -- Time ranges converted to tick ranges
    constant T0H_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T0.H);
    constant T0L_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T0.L);
    constant T1H_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T1.H);
    constant T1L_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.T1.L);
    constant RES_ticks : tick_range := to_tick_range(clk_frequency, work.neopixel_pkg.RES);

    signal timeout : boolean;

    signal color_reg : rgb_color_t;
    subtype bit_cycle_state_t is natural range 0 to 7;
    subtype color_cycle_state_t is natural range 0 to 2;
    type serialization_state is (reset, high, low, res, done, done_delay, next_color);

    signal bit_cycle_state : bit_cycle_state_t;
    signal color_cycle_state : color_cycle_state_t;
    signal serializer_state : serialization_state;
    signal chosen_ticks : tick_range;
    signal count : natural;
    signal color_bit_index : natural range 0 to 23;
    signal debug_current_bit : std_logic;
begin

    debug_current_bit <= get_bit(color_reg, color_bit_index);

    state_signal_driver : process(all)
    begin
        case serializer_state is
            when reset =>
                ready_s <= false;
                serialized <= '0';
            when done | low =>
                ready_s <= true;
                serialized <= '0';
            when high =>
                ready_s <= true;
                serialized <= '1';
            when others =>
                ready_s <= false;
                serialized <= '0';
        end case;
    end process;

    -- Convenience signal
    timeout_proc : process (count, serializer_state, chosen_ticks) is
    begin
        case serializer_state is
            when high | low =>
                timeout <= count >= chosen_ticks.mean - 1;
            when others =>
                timeout <= count >= chosen_ticks.maximum - 1;
        end case;
    end process timeout_proc;

    color_serializer_state_transitions : process (clk, rst_n) is
    begin
        if rst_n = '0' then
        elsif rising_edge(clk) then
        end if;
    end process color_serializer_state_transitions;

    bit_cycle_state_transition : process (clk, rst_n) is
    begin
        if rst_n = '0' then
        elsif rising_edge(clk) then
        end if;
    end process bit_cycle_state_transition;

    bit_serializer_state_transitions : process(clk, rst_n)
    begin
        if rst_n = '0' then
            chosen_ticks <= RES_ticks;
            serializer_state <= reset;
        elsif rising_edge(clk) then
            case serializer_state is
                when reset =>
                    serializer_state <= done;
                when done =>
                    -- Start up if there is a valid color present
                    if valid_s then
                        color_cycle_state <= 0;
                        bit_cycle_state <= 0;
                        serializer_state <= done_delay;
                        color_reg <= color;
                    end if;
                    color_bit_index <= 0;

                when done_delay =>
                    serializer_state <= high;
                    if get_bit(color_reg, color_bit_index) = '0' then
                        chosen_ticks <= T0H_ticks;
                    else -- get_bit(color_reg, 0) = '1' then
                        chosen_ticks <= T1H_ticks;
                    end if;

                when high =>
                    if timeout then
                        serializer_state <= low;
                        if get_bit(color_reg, color_bit_index) = '0' then
                            chosen_ticks <= T0L_ticks;
                        else -- get_bit(color_reg, 0) = '1' then
                            chosen_ticks <= T1L_ticks;
                        end if;
                    end if;

                when low =>
                    if color_bit_index = 23 and timeout then
                        serializer_state <= res;
                    elsif timeout then
                        color_bit_index <= color_bit_index + 1;
                        serializer_state <= high;
                        if get_bit(color_reg, color_bit_index) = '0' then
                            chosen_ticks <= T0H_ticks;
                        else -- get_bit(color_reg, 0) = '1' then
                            chosen_ticks <= T1H_ticks;
                        end if;
                    end if;

                when others =>
                    serializer_state <= reset;
             end case;
        end if;
    end process bit_serializer_state_transitions;

    counter_proc : process(clk)
    begin
        if rising_edge(clk) then
            case serializer_state is
                when high | low | res =>
                    if timeout then 
                        count <= 0;
                    else
                        count <= count + 1;
                    end if;
                when reset | done =>
                    count <= 0;
                when others =>
                    count <= 0;
            end case;
        end if;
    end process; -- counter_proc

end architecture; -- arch
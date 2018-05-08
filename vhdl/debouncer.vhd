library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
    generic (
        G_DELAY : natural := 200000
    );
    port (
        clock     : in  std_logic;
        rst_n     : in  std_logic := '1';
        button    : in  std_logic;
        debounced : out std_logic
    );
end entity;

architecture rtl of debouncer is
    signal debounced_i : std_logic := '0';
begin
    debounced <= debounced_i;

    debounce : process(clock, rst_n)
        variable ticks_since_change : natural := 0;
    begin
        if rst_n = '0' then
            debounced_i        <= '0';
            ticks_since_change := 0;
        elsif rising_edge(clock) then
            if not (debounced_i = button) then
                if ticks_since_change < G_DELAY then
                    ticks_since_change := ticks_since_change + 1;
                else
                    debounced_i        <= button;
                    ticks_since_change := 0;
                end if;
            else
                ticks_since_change := 0;
            end if;
        end if;
    end process;
end architecture;
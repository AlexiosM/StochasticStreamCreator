--- Edge Memory ---
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
library work;
use work.all;
entity EM is
    Port (
        clk : in std_logic;
        random_address : in std_logic_vector(6 downto 1);
        input : in std_logic;
        update : in std_logic;
        output : out std_logic
        );
end EM;

architecture em_behavior of EM is
    signal d : std_logic_vector(64 downto 1);
begin
process(clk)
    begin
    if rising_edge(clk) then
        if update = '1' then -- non hold state
            output <= d(to_integer(unsigned(random_address)));-- 64 to 1 multiplexer (select of 6 signals)
            d(64)<= input;  -- Assume  input->|64|63|...|2|1|->output
        else
            for i in 63 to 2 loop
                d(i-1) <= d(i);
            end loop;
        end if;
    end if;
end process;
end em_behavior;

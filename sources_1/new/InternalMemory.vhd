---  Internal Memory ---
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.all;
entity IM is
    Port (
        clk : in std_logic;
        random_address : in std_logic;
        input : in std_logic;
        enable : in std_logic;
        output : out std_logic
        );
end IM;
architecture im_behavior of IM is
    signal d : std_logic_vector(2 downto 1);
begin
process(clk)
    begin
    if rising_edge(clk) then
        if enable = '1' then
            if random_address = '1' then -- multiplex output between D Flip Flops outputs
                output <= d(2); 
            else 
                output <= d(1);
            end if;
        else
                d(2)<= input;
                d(1)<= d(2); 
        end if;
    end if;
end process;
end im_behavior;

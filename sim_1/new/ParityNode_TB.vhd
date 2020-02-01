----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2019 19:01:24
-- Design Name: 
-- Module Name: ParityCheck_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity ParityNode_TB is
end;

architecture bench of ParityNode_TB is

  component ParityNode
      Port ( input : in STD_LOGIC_VECTOR (7 downto 1);
             clk : in STD_LOGIC;
             parity_check_satisfied : out STD_LOGIC;
             output : out STD_LOGIC_VECTOR (7 downto 1));
  end component;

  signal input: STD_LOGIC_VECTOR (7 downto 1);
  signal clk: STD_LOGIC;
  signal parity_check_satisfied: STD_LOGIC;
  signal output: STD_LOGIC_VECTOR (7 downto 1);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: ParityNode port map ( input                  => input,
                              clk                    => clk,
                              parity_check_satisfied => parity_check_satisfied,
                              output                 => output );

  stimulus: process
  begin
    stop_the_clock <= false;
    input <= "0101010";
    wait for 10 ns;
    input <= "1101010";
    wait for 10 ns;
    input <= "1111010";
    wait for 10 ns;
    input <= "1111110";
    wait for 10 ns;
    input <= "0001010";
    wait for 10 ns;
    input <= "0000010";
    wait for 10 ns;
    input <= "0000000";
    wait for 10 ns;
    
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
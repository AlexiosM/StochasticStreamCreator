-- Each Variable Node is connected to 6 Parity Nodes, takes signals from 5 PNs and sends response to 1 PN
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.all;
entity VN_sequential is
    Port(input_VN:in std_logic_vector(5 downto 1); 
    comparator, init, output_IM1, output_IM2 :in std_logic;
    input_IM1, input_IM2, enable_IM1, enable_IM2, in_DFF:out std_logic;
    output_EM,input_EM,update_EM:inout std_logic
    );
end VN_sequential;
architecture VN_sequential_behav of VN_sequential is
    signal and1,and2,and1not,and2not,or1,or2,mux1,mux2: std_logic;
begin
    and1 <= input_VN(5) and input_VN(4) and input_VN(3);
    and2 <= input_VN(2) and input_VN(1) and comparator;
    and1not <= not input_VN(5) and not input_VN(4) and not input_VN(3);
    and2not <= not input_VN(2) and not input_VN(1) and not comparator;
    or1 <= and1 or and1not;
    or2 <= and2 or and2not;
    mux1 <= and1 when or1 = '1' else output_IM1;
    mux2 <= and2 when or2 = '1' else output_IM2;
    input_IM1 <= and1;
    input_IM2 <= and2;
    enable_IM1 <= or1;
    enable_IM2 <= or2;
    update_EM <= init or((not mux1 and not mux2)or(mux1 and mux2));
    input_EM <= comparator when init = '1' else mux1 and mux2;
    in_DFF <= input_EM when update_EM = '1' else output_EM;
end VN_sequential_behav;
-------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.all;
entity VN_combinational is
    port(
    input_IM1, input_IM2, input_EM, enable_IM1, enable_IM2, update_EM, clk, in_DFF:in std_logic;
    random_address:in std_logic_vector(8 downto 1);
    output_IM1, output_IM2, output_EM, out_DFF :out std_logic
    );
end VN_combinational;

architecture VN_behav_combinational of VN_combinational is
component IM is
    Port (
        clk : in std_logic;
        random_address : in std_logic;
        input : in std_logic;
        enable : in std_logic;
        output : out std_logic
        );
end component;
component EM is
    Port (
        clk : in std_logic;
        random_address : in std_logic_vector(6 downto 1);
        input : in std_logic;
        update : in std_logic;
        output : out std_logic
        );
end component;

begin
    IM1:IM port map(clk=>clk,
    random_address=>random_address(7),
    input=>input_IM1,
    enable=>enable_IM1,
    output=>output_IM1);
    
    IM2:IM port map(clk=>clk,
    random_address=>random_address(8),
    input=>input_IM2,
    enable=>enable_IM2,
    output=>output_IM2);
    
    EMem:EM port map(clk=>clk,
    random_address(6 downto 1)=>random_address(6 downto 1),
    input=>input_EM,
    update=>update_EM,
    output=>output_EM);

end VN_behav_combinational;
-----------------------------------------------------------------------
-- creation of Variable Node with Distributed Random Engine inside
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.all;
entity VariableNode is port(
    clk: in std_logic;
    inputsFromPNs: in std_logic_vector(5 downto 1);
    inputFromComparator: in std_logic;
    initialization: in std_logic;
    dre_reset: in std_logic;
    dre_seed: in std_logic_vector(10 downto 1);
    outputToPN: out std_logic
);
end VariableNode;

architecture VariableNodeBehavior of VariableNode is
component LFSR is Port(
    clk : in std_logic;
    enabled : in std_logic;
    reset : in std_logic;
    seed_values : in std_logic_vector(10 downto 1);
    random_num : out std_logic_vector(10 downto 1)
);
end component;
component VN_sequential is Port(
    input_VN:in std_logic_vector(5 downto 1); 
    comparator, init, output_IM1, output_IM2 :in std_logic;
    input_IM1, input_IM2, enable_IM1, enable_IM2, in_DFF:out std_logic;
    output_EM, input_EM, update_EM:inout std_logic
);
end component;
component VN_combinational is Port(
    input_IM1, input_IM2, input_EM, enable_IM1, enable_IM2, update_EM, clk, in_DFF:in std_logic;
    random_address:in std_logic_vector(8 downto 1);
    output_IM1, output_IM2, output_EM, out_DFF :out std_logic
);
end component;
signal input_IM1, input_IM2, input_EM, output_IM1, output_IM2, output_EM, enable_IM1, enable_IM2, update_EM, in_DFF: std_logic;
signal random_address_tmp: std_logic_vector(8 downto 1);
signal concatenated_address : std_logic_vector(10 downto 1);

begin
    random_address_tmp <= concatenated_address(8 downto 1);
DRE: LFSR port map ( clk=>clk,
        enabled=>'1',
        reset => dre_reset,
        seed_values => dre_seed,
        random_num => concatenated_address
);
VN_Seq: VN_sequential port map ( input_VN => inputsFromPNs, comparator => inputFromComparator, init => initialization,
        output_IM1 => output_IM1,output_IM2 => output_IM2,
        input_IM1 => input_IM1, input_IM2 => input_IM2, enable_IM1 => enable_IM1, enable_IM2 => enable_IM2, in_DFF => in_DFF
);
VN_Comb: VN_combinational port map ( input_IM1=>input_IM1, input_IM2=>input_IM2, input_EM=>input_EM, 
        enable_IM1=>enable_IM1, enable_IM2=>enable_IM2, update_EM=>update_EM, clk=>clk, in_DFF=>in_DFF,
        random_address=>random_address_tmp,
        output_IM1=>output_IM1, output_IM2=>output_IM2, output_EM=>output_EM, 
        out_DFF=>outputToPN
        );
end VariableNodeBehavior;
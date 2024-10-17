library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
  Port (  clk : in STD_LOGIC;
          WD : in STD_LOGIC_VECTOR (31 downto 0);
          RegWrite : in STD_LOGIC;
          Instr : in STD_LOGIC_VECTOR (25 downto 0);
          EN : in STD_LOGIC;
          ExtOp : in STD_LOGIC;
          RD1 : out STD_LOGIC_VECTOR (31 downto 0);
          RD2 : out STD_LOGIC_VECTOR (31 downto 0);
          Ext_Imm : out STD_LOGIC_VECTOR ( 31 downto 0);
          func : out STD_LOGIC_VECTOR (5 downto 0);
          sa : out STD_LOGIC_VECTOR (4 downto 0); 
          rt : out STD_LOGIC_VECTOR (4 downto 0);
          rd : out STD_LOGIC_VECTOR (4 downto 0);
          wa : in STD_LOGIC_VECTOR (4 downto 0)
         );
end ID;

architecture Behavioral of ID is

type reg is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal RF : reg := (others => X"00000000");
signal WriteAddress : STD_LOGIC_VECTOR (4 downto 0);
signal RA1: STD_LOGIC_VECTOR (4 downto 0);
signal RA2: STD_LOGIC_VECTOR (4 downto 0);

begin
    process(clk)
    begin
        if falling_edge(clk) then 
            if EN = '1' and RegWrite = '1' then 
                RF(conv_integer(WriteAddress)) <= WD; 
            end if;
        end if;
    end process;


WriteAddress <= WA;

with ExtOp select
                Ext_Imm <= X"0000" & Instr(15 downto 0) when '0',
                           Instr(15) & Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) &Instr(15) & Instr(15) & Instr(15 downto 0) when '1';
 
 RA1 <= Instr(25 downto 21);
 RA2 <= Instr(20 downto 16);
 RD1 <= RF(conv_integer(RA1));
 RD2 <= RF(conv_integer(RA2));

func <= Instr(5 downto 0);
sa <= Instr(10 downto 6);

rt <= Instr(20 downto 16);
rd <= Instr(15 downto 11); 
               
end Behavioral;

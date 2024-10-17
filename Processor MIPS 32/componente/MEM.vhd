
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
  Port ( MemWrite : in STD_LOGIC;
         ALUResIn : in STD_LOGIC_VECTOR (31 downto 0);
         RD2 : in STD_LOGIC_VECTOR (31 downto 0);
         CLK : in STD_LOGIC;
         EN : in STD_LOGIC;
         MemData : out STD_LOGIC_VECTOR (31 downto 0);
         ALUResOut : out STD_LOGIC_VECTOR (31 downto 0)
   );
end MEM;


architecture Behavioral of MEM is
type memory is array(0 to 63) of STD_LOGIC_VECTOR (31 downto 0);
signal MEM : memory := (X"0000000C", -- 12
                        X"00000008", -- 8
                        X"7FFFFFFF", -- 2,147,483,647
                        X"00000002", -- 2
                        X"0000000F", -- 15
                        X"00000005", -- 5
                        X"0000002A", -- 42
                        X"00000007", -- 7
                        X"0000005D", -- 93
                        X"0000000B", -- 11
                        X"0000000A", -- 10
                        others => X"00000000");

begin

process(CLK)
begin
    if rising_edge(CLK) then 
        if EN = '1' and MemWrite = '1' then
            MEM(conv_integer(ALUResIn(7 downto 2))) <= RD2;
         end if;
     end if;
end process;

MemData <= MEM(conv_integer(ALUResIn(7 downto 2)));
ALUResOut <= ALUResIn;

end Behavioral;

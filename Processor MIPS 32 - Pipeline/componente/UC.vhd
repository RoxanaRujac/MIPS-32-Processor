
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UC is
  Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
         RegDst : out STD_LOGIC;
         ExtOp : out STD_LOGIC;
         ALUSrc : out STD_LOGIC;
         Branch : out STD_LOGIC;
         Jump : out STD_LOGIC;
         ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
         MemWrite : out STD_LOGIC;
         MemtoReg : out STD_LOGIC;
         RegWrite : out STD_LOGIC;
         Br_GEZ : out STD_LOGIC);
end UC;

architecture Behavioral of UC is

begin

process(Instr)
begin
    RegDst <= '0';
    ExtOp <= '0';
    ALUSrc <= '0';
    Branch <= '0';
    Jump <= '0';
    ALUOp <= "00";
    MemWrite <= '0';
    MemtoReg <= '0';
    RegWrite <= '0';
    Br_GEZ <= '0';
    
    case Instr is
                when "000000" => --R type
                                RegDst <= '1'; RegWrite <= '1';
                when "000001" => --addi
                                ExtOp <= '1'; ALUSrc <= '1'; RegWrite <= '1'; ALUOp <= "01"; 
                when "000010" => --lw
                                ExtOp <= '1'; ALUSrc <= '1'; MemtoReg <= '1'; RegWrite <= '1'; ALUOp <= "01";
                when "000011" => --sw
                                ExtOp <= '1'; ALUSrc <= '1'; MemWrite <= '1'; ALUOp <= "01";
                when "000100" => --beq
                                ExtOp <= '1'; Branch <= '1'; ALUOp <= "10";
                when "000101" => --bgez
                                ExtOp <= '1'; Br_GEZ <= '1'; ALUOp <= "10";
                when "000110" => --slti
                                ExtOp <= '1'; RegWrite <= '1'; ALUOp <= "10";
                when "000111" => --jump
                                Jump <= '1';
                when others => RegDst <= 'X';
                               ExtOp <= 'X';
                               ALUSrc <= 'X';
                               Branch <= 'X';
                               Jump <= 'X';
                               ALUOp <= "XX";
                               MemWrite <= 'X';
                               MemtoReg <= 'X';
                               RegWrite <= 'X';
                               Br_GEZ <= 'X';
    end case;                            
         
         
end process;

end Behavioral;

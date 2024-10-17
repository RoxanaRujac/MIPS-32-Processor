library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test_env is
  Port ( clk : in STD_LOGIC;
         btn : in STD_LOGIC_VECTOR (4 downto 0);
         sw : in STD_LOGIC_VECTOR (15 downto 0);
         led : out STD_LOGIC_VECTOR (12 downto 0);
         an : out STD_LOGIC_VECTOR (7 downto 0);
         cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

---------------------------------------componente necesare-------------------------------------------------------------------
component MPG is  
Port (   enable : out STD_LOGIC;
         btn : in STD_LOGIC;
         clk : in STD_LOGIC);
end component;

component SSD is 
 Port ( clk : in STD_LOGIC;
          digits : in STD_LOGIC_VECTOR(31 downto 0);
          an : out STD_LOGIC_VECTOR(7 downto 0);
          cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component EX is
  Port ( RD1 : in STD_LOGIC_VECTOR(31 downto 0);
         RD2 : in STD_LOGIC_VECTOR (31 downto 0);
         ALUSrc : in STD_LOGIC;
         Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
         sa : in STD_LOGIC_VECTOR (4 downto 0);
         func : in STD_LOGIC_VECTOR (5 downto 0);
         ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
         PCplus4 : in STD_LOGIC_VECTOR (31 downto 0);
         BranchAdress : out STD_LOGIC_VECTOR (31 downto 0);
         ALURes : out STD_LOGIC_VECTOR (31 downto 0);
         Zero : out STD_LOGIC;
         GEZ : out STD_LOGIC
        );
end component;

component MEM is
  Port ( MemWrite : in STD_LOGIC;
         ALUResIn : in STD_LOGIC_VECTOR (31 downto 0);
         RD2 : in STD_LOGIC_VECTOR (31 downto 0);
         CLK : in STD_LOGIC;
         EN : in STD_LOGIC;
         MemData : out STD_LOGIC_VECTOR (31 downto 0);
         ALUResOut : out STD_LOGIC_VECTOR (31 downto 0)
   );
end component;

component UC is
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
end component;

component ID is
  Port (  clk : in STD_LOGIC;
          WD : in STD_LOGIC_VECTOR (31 downto 0);
          RegWrite : in STD_LOGIC;
          Instr : in STD_LOGIC_VECTOR (25 downto 0);
          RegDst : in STD_LOGIC;
          EN : in STD_LOGIC;
          ExtOp : in STD_LOGIC;
          RD1 : out STD_LOGIC_VECTOR (31 downto 0);
          RD2 : out STD_LOGIC_VECTOR (31 downto 0);
          Ext_Imm : out STD_LOGIC_VECTOR ( 31 downto 0);
          func : out STD_LOGIC_VECTOR (5 downto 0);
          sa : out STD_LOGIC_VECTOR (4 downto 0) 
         );
end component;

component IFetch is
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        branch_adress : in std_logic_vector (31 downto 0);
        PCSrc : in std_logic;
        jump_adress : in std_logic_vector (31 downto 0);
        jump : in std_logic;
        instruction : out std_logic_vector (31 downto 0);
        pc : out std_logic_vector (31 downto 0)
        );
end component;

---------------------------------semnale--------------------------------------------------------------------------------------

--pentru mpg
signal en0 : std_logic;


--pentru iFetch
signal BranchAdress : STD_LOGIC_VECTOR (31 downto 0); --iese din EX
signal PCSrc : STD_LOGIC; --iese dintr un sau
signal JumpAdress : STD_LOGIC_VECTOR (31 downto 0);
signal PCplus4 : STD_LOGIC_VECTOR (31 downto 0);
--signal Jump1 : STD_LOGIC;
signal Instruction : STD_LOGIC_VECTOR (31 downto 0);


--pentru UC
signal RegDst :  STD_LOGIC;
signal ExtOp : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal Branch :  STD_LOGIC;
signal Jump : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);
signal MemWrite : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal RegWrite : STD_LOGIC;
signal Br_GEZ : STD_LOGIC;


--pentru ID
signal WD : STD_LOGIC_VECTOR (31 downto 0);
signal RD1 : STD_LOGIC_VECTOR (31 downto 0);
signal RD2 : STD_LOGIC_VECTOR (31 downto 0);
signal Ext_Imm : STD_LOGIC_VECTOR (31 downto 0);
signal func : STD_LOGIC_VECTOR (5 downto 0);
signal sa : STD_LOGIC_VECTOR (4 downto 0);

--pentru EX
signal Zero : STD_LOGIC;
signal ALURes : STD_LOGIC_VECTOR (31 downto 0);
signal GEZ : STD_LOGIC;

--pentru MEM
signal ALUResOut : STD_LOGIC_VECTOR (31 downto 0);
signal MemData: STD_LOGIC_VECTOR (31 downto 0);

--pentru SSD
signal Digits : STD_LOGIC_VECTOR (31 downto 0);

begin 


-----------------------------port map-arile-------------------------------------------------------------------------------------
 monopulse: MPG port map(en0, btn(0), clk);
 fetch : IFetch port map(clk, btn(1), en0, BranchAdress, PCSrc, JumpAdress, Jump, Instruction, PCplus4);

--calcularea adresei de jump + PcSrc
JumpAdress <= PCplus4(31 downto 28) & Instruction(25 downto 0) & "00";
PCSrc <= Branch and Zero;
  
 control_unit: UC port map (Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite, Br_GEZ);
 led(9 downto 0) <= ALUOp & RegDst & ALUSrc & Branch & Br_GEZ & Jump & MemWrite & MemtoReg & RegWrite;

 instruction_decode: ID port map (clk, WD, RegWrite, Instruction(25 downto 0), RegDst, en0, ExtOp, RD1, RD2, Ext_Imm, func, sa);
 execute: EX port map (RD1, RD2, ALUSrc, Ext_Imm, sa, func, ALUOp, PCplus4, BranchAdress, ALURes, Zero, GEZ);
 memory : MEM port map (MemWrite, ALURes, RD2, clk, en0, MemData, ALUResOut);
  
 --Write-Back
 with MemtoReg select WD <= ALUResOut when '0',
                            MemData when '1',
                            (others => 'X') when others; 
 
 --mux ssd
 with sw(7 downto 5) select Digits <= Instruction when "000",
                                      PCplus4 when "001",
                                      RD1 when "010",
                                      RD2 when "011",
                                      Ext_Imm when "100",
                                      ALURes when "101",
                                      MemData when "110",
                                      WD when "111",
                                      (others => 'X') when others;
 
 display: SSD port map (clk, Digits, an, cat);
 
end Behavioral;
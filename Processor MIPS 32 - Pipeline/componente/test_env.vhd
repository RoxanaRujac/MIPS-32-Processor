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

----------------------------componente---------------------------------------------------------------------
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
         GEZ : out STD_LOGIC;
         rt : in STD_LOGIC_VECTOR (4 downto 0);
         rd : in STD_LOGIC_VECTOR (4 downto 0);
         RegDst : in STD_LOGIC;
         rWA : out STD_LOGIC_VECTOR (4 downto 0)
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


--------------------------------------semnale--------------------------------------------------------------------------

--pentru mpg
signal en0 : std_logic;


--pentru iFetch
signal BranchAdress : STD_LOGIC_VECTOR (31 downto 0); --iese din EX
signal PCSrc : STD_LOGIC; --iese dintr un sau
signal JumpAdress : STD_LOGIC_VECTOR (31 downto 0);
signal PCplus4 : STD_LOGIC_VECTOR (31 downto 0);
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
signal rt : std_logic_vector(4 downto 0);
signal rd : std_logic_vector(4 downto 0);

--pentru EX
signal Zero : STD_LOGIC;
signal ALURes : STD_LOGIC_VECTOR (31 downto 0);
signal GEZ : STD_LOGIC;
signal rWA : STD_LOGIC_VECTOR(4 downto 0);

--pentru MEM
signal ALUResOut : STD_LOGIC_VECTOR (31 downto 0);
signal MemData: STD_LOGIC_VECTOR (31 downto 0);

--pentru SSD
signal Digits : STD_LOGIC_VECTOR (31 downto 0);


----------------------semnale auxiliare pipeline---------------------------------------------------------------------------------------------------------

--IF->ID
signal Instruction_IF_ID : STD_LOGIC_VECTOR(31 downto 0);
signal PCplus4_IF_ID : STD_LOGIC_VECTOR(31 downto 0);

--ID->EX
signal RegDst_ID_EX : STD_LOGIC;
signal ALUSrc_ID_EX : STD_LOGIC;
signal Branch_ID_EX : STD_LOGIC;
signal ALUOp_ID_EX : STD_LOGIC_VECTOR(1 downto 0);
signal MemWrite_ID_EX : STD_LOGIC;
signal MemtoReg_ID_EX : STD_LOGIC;
signal RegWrite_ID_EX : STD_LOGIC;
signal RD1_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
signal RD2_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
signal Ext_Imm_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
signal func_ID_EX : STD_LOGIC_VECTOR(5 downto 0);
signal sa_ID_EX : STD_LOGIC_VECTOR(4 downto 0);
signal rd_ID_EX : STD_LOGIC_VECTOR(4 downto 0);
signal rt_ID_EX : STD_LOGIC_VECTOR(4 downto 0);
signal PCplus4_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
signal BranchAddress_ID_EX : STD_LOGIC_VECTOR (31 downto 0);

--EX->MEM
signal Branch_EX_MEM : STD_LOGIC;
signal MemWrite_EX_MEM : STD_LOGIC;
signal MemtoReg_EX_MEM : STD_LOGIC;
signal RegWrite_EX_MEM : STD_LOGIC;
signal Zero_EX_MEM : STD_LOGIC;
signal BranchAddress_EX_MEM : STD_LOGIC_VECTOR(31 downto 0);
signal ALURes_EX_MEM : STD_LOGIC_VECTOR(31 downto 0);
signal WA_EX_MEM : STD_LOGIC_VECTOR(4 downto 0);
signal RD2_EX_MEM : STD_LOGIC_VECTOR(31 downto 0);  

--MEM->WB
signal MemtoReg_MEM_WB : STD_LOGIC;
signal RegWrite_MEM_WB : STD_LOGIC;
signal ALURes_MEM_WB : STD_LOGIC_VECTOR(31 downto 0);
signal MemData_MEM_WB : STD_LOGIC_VECTOR(31 downto 0);
signal WA_MEM_WB : STD_LOGIC_VECTOR(4 downto 0);

begin 

------------------------------port map-arile-------------------------------------------------------------------------------------------------------
 
 
 monopulse: MPG port map(en0, btn(0), clk);
 fetch : IFetch port map(clk, btn(1), en0, BranchAddress_EX_MEM, PCSrc, JumpAdress, Jump, Instruction, PCplus4);

JumpAdress <= PCplus4_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";
  
 control_unit: UC port map (Instruction_IF_ID(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite, Br_GEZ);
 led(9 downto 0) <= ALUOp & RegDst & ALUSrc & Branch & Br_GEZ & Jump & MemWrite & MemtoReg & RegWrite;

 instruction_decode: ID port map (clk, WD, RegWrite_MEM_WB, Instruction_IF_ID(25 downto 0), en0, ExtOp, RD1, RD2, Ext_Imm, func, sa, rt, rd, WA_MEM_WB);
 execute: EX port map (RD1_ID_EX, RD2_ID_EX, ALUSrc_ID_EX, Ext_Imm_ID_EX, sa_ID_EX, func_ID_EX, ALUOp_ID_EX, PCplus4_ID_EX, BranchAdress, ALURes, Zero, GEZ, rd_ID_EX, rt_ID_EX, RegDst_ID_EX, rWA);
 memory : MEM port map (MemWrite_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM, clk, en0, MemData, ALUResOut);
  
 PCSrc <= Branch_EX_MEM and Zero_EX_MEM;
 
 --mux mic
 with MemtoReg_MEM_WB select WD <= ALURes_MEM_WB when '0',
                            MemData_MEM_WB when '1',
                            (others => 'X') when others; 
 
 --mux mare
 with sw(7 downto 5) select Digits <= Instruction when "000",
                                      PCplus4 when "001",
                                      RD1_ID_EX when "010",
                                      RD2_ID_EX when "011",
                                      Ext_Imm_ID_EX when "100",
                                      ALURes when "101",
                                      MemData when "110",
                                      WD when "111",
                                      (others => 'X') when others;
 
 display: SSD port map (clk, Digits, an, cat);
 
 
 -----------------------registre---------------------------------------------------------------------------------------------
 
 --registrul IF-ID
 process(clk) 
 begin
    if rising_edge(clk) then
            if en0 = '1' then
                Instruction_IF_ID <= Instruction;
                PCplus4_IF_ID <= PCplus4;
            end if;
    end if;
end process;


--registrul ID-EX
process(clk) 
 begin
    if rising_edge(clk) then
            if en0 = '1' then
                PCplus4_ID_EX <= PCplus4_IF_ID;
                RD1_ID_EX <= RD1;
                RD2_ID_EX <= RD2;
                Ext_Imm_ID_EX <= Ext_Imm;
                func_ID_EX <= func;
                sa_ID_EX <= sa;
                rd_ID_EX <= rd;
                rt_ID_EX <= rt;
                RegDst_ID_EX <= RegDst;
                ALUSrc_ID_EX <= ALUSrc;
                Branch_ID_EX <= Branch;
                ALUOp_ID_EX <= ALUOp;
                MemWrite_ID_EX <= MemWrite;
                MemtoReg_ID_EX <= MemtoReg;
                RegWrite_ID_EX <= RegWrite;
            end if;
    end if;
end process;

 
--registrul EX-MEM
 process(clk) 
 begin
    if rising_edge(clk) then
            if en0 = '1' then
                 Branch_EX_MEM <= Branch_ID_EX;
                 Zero_EX_MEM <= Zero;
                 ALURes_EX_MEM <= ALURes;
                 RD2_EX_MEM <= RD2_ID_EX;
                 BranchAddress_EX_MEM <= BranchAdress;
                 MemWrite_EX_MEM <= MemWrite_ID_EX;
                 MemtoReg_EX_MEM <= MemtoReg_ID_EX;
                 RegWrite_EX_MEM <= RegWrite_ID_EX;
                 WA_EX_MEM <= rWA;
            end if;
    end if;
end process;


--registrul MEM-WB
process(clk) 
 begin
    if rising_edge(clk) then
            if en0 = '1' then
                ALURes_MEM_WB <= ALUResOut;
                MemData_MEM_WB <= MemData;
                MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
                RegWrite_MEM_WB <= RegWrite_EX_MEM;
                WA_MEM_WB <= WA_EX_MEM;
            end if;
    end if;
end process;


end Behavioral;
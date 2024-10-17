library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
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
end IFetch;

architecture Behavioral of IFetch is

type memRom is array (0 to 31) of std_logic_vector (31 downto 0);

--S? se determine valoarea impara minima dintr-un ?ir de N numere stocate în
--memorie începând cu adresa A (A?12). A ?i N se citesc de la adresele 0, respectiv
--4. Rezultatul se va scrie în memorie la adresa 8.

signal rom : memRom := ( B"000000_00000_00000_00001_00000_000110",	    --0:	xor $1, $0, $0	 X"00000806"     initializarea contorului cu 0
                         B"000010_00000_00010_0000000000001000",		--1:	lw  $2, 8($0) 	 X"08020008"     initializez minimul impar cu cel mai mare numar
                         B"000010_00000_00011_0000000000000100",		--2:	lw  $3, 4($0)	 X"08030004"	 am citit n de la adresa 4 (numarul de numere stocate)
                         B"000010_00000_00100_0000000000000000",		--3:	lw  $4, 0($0)	 X"08040000"     citesc adresa de inceput a sirului A de la adresa 0 (pointer spre inceputul sirului)
                         B"000001_00000_00101_0000000000000000",	    --4:	addi $5, $0, 0	 X"04050000"     folosesc $5 pentru a parcurge sirul ($5 - indexul sirului, A[index])
                                                                        --bucla
                         B"000100_00001_00011_0000000000001010",		--5:	beq $1, $3, 10	 X"1023000A"     verific daca contorul = n si daca da sar la finalul buclei
                         B"000010_00101_00110_0000000000001100",		--6:	lw  $6, 12($5)	 X"08A6000C"	 luam elementul curent $6 = A[index]
                         B"000001_00000_00111_0000000000000001",		--7:	addi $7, $0, 1	 X"04070001"     incarc valoarea 1 in registrul 7
                         B"000000_00110_00111_01000_00000_000100",	    --8:	and $8, $6, $7	 X"00C74004"	 and intre numarul curent si valoarea 1 in $8
                         B"000100_01000_00000_0000000000000011",		--9:	beq $8, $0, 3	 X"11000003"	 daca rezultatul din $8 e 0 atunci e nr par si sarim la instructiunile de incrementare
                         B"000000_00110_00010_01001_00000_000111",	    --10:	slt $9, $6, $2	 X"00C24807"     verifica daca numarul actual (impar) e mai mic decat minimul actual
                         B"000100_01001_00000_0000000000000001",		--11:	beq $9, $0, 1	 X"11200001"	 daca nr nu este mai mic decat minimul curent sarim la instructiunile de incrementare
                         B"000000_00110_00000_00010_00000_000000",		--12:	add $2, $6, $0	 X"00C01000"     salvam minimul curent in $2
                         B"000001_00001_00001_0000000000000001",		--13:	addi $1, $1, 1	 X"04210001"     incrementam contorul
                         B"000001_00101_00101_0000000000000100",		--14:	addi $5, $5, 4	 X"04A50004"     actualizam pozitia din sir
                                                                        --afara
                         B"000111_00000000000000000000000101",		    --15:	j 5			     X"01C000005"    revine la inceputul buclei
                         B"000011_00000_00010_0000000000001000",		--16:	sw $2, 8($0)	 X"00C020008"    pune in memorie la adresa 8 rezultatul -> minimul impar
                         others => X"00000000");
      
signal d: std_logic_vector(31 downto 0);
signal q: std_logic_vector(31 downto 0);
signal mux1 : std_logic_vector (31 downto 0);

begin

process(clk, rst)
begin
    if rst = '1' then
        q <= (others => '0');
    elsif rising_edge(clk) then
        if en = '1' then
            q <= d;
        end if;
    end if;
end process;


with PCSrc SELECT mux1 <= q + 4 when '0',
                         branch_adress when '1';

with Jump SELECT d <= mux1 when '0',
                      jump_adress when '1';                         

pc <= q + X"00000004";

instruction <= rom(conv_integer(q(6 downto 2)));

end Behavioral;

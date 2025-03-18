----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_CNT
-- Module Name      : Gen_CNT
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for an incremental counter
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 516 MHz
-- Area  Estimation : 8 LUTs + 8 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_CNT is
	generic (
				DIGIT : integer := 8);
	port    (
				CLK  : in  std_logic;
				CE   : in  std_logic;
				ACLR : in  std_logic;
				Q    : out std_logic_vector (DIGIT-1 downto 0));
end Gen_CNT;

architecture Behavioral of Gen_CNT is

	signal COUNT : std_logic_vector (DIGIT-1 downto 0) := (others => '0');

begin

	process (CLK , ACLR)
	begin
		if (ACLR = '1') then
			COUNT <= (others => '0');
		elsif (rising_edge(CLK)) then
			if (CE = '1') then 
				COUNT <= COUNT + 1;
			end if;
		end if;
	end process;
	Q <= COUNT;

end Behavioral;
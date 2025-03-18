----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Sort_Permit
-- Module Name      : Gen_Sort_Permit
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for the sort's permissions
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 6 LUTs + 1 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/06/13
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Sort_Permit is
	generic (
				DATA_WIDTH  : integer := 8);
	port    (
				DATA1_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA2_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				CE          : in  std_logic;
				NEXT_PERMIT : in  std_logic;
				COMPARE_IN  : in  std_logic;
				COMPARE_OUT : out std_logic;
				PERMIT      : out std_logic);
end Gen_Sort_Permit;

architecture Behavioral of Gen_Sort_Permit is
	
	signal Comp , Perm : std_logic := '0';
	
begin
	
	Comp        <= '1' when DATA2_IN < DATA1_IN else '0';
	COMPARE_OUT <= Comp and CE;
	PERMIT      <= Perm and CE;
	
	process (NEXT_PERMIT)
	begin
		if (rising_edge(NEXT_PERMIT)) then
			Perm <= not(COMPARE_IN) and Comp;
		end if;
	end process;
	
end Behavioral;
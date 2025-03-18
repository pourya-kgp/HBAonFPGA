----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Comp_Eq
-- Module Name      : Gen_Comp_Eq
-- HDL Standard     : VHDL
-- Approach         : Combinatorial
-- Description      : Generic core for determining that two values are equal
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 3 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Comp_Eq is
	generic  (
				DATA_WIDTH : integer := 8);
	port     (
				A 	: in  std_logic_vector (DATA_WIDTH-1 downto 0);
				B 	: in  std_logic_vector (DATA_WIDTH-1 downto 0);
				EQ	: out std_logic);
end Gen_Comp_Eq;

architecture Combinatorial of Gen_Comp_Eq is
begin

	EQ <= '1' when A = B else '0';

end Combinatorial;
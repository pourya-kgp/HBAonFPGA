----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Bit_Comp_Eq
-- Module Name      : Bit_Comp_Eq
-- HDL Standard     : VHDL
-- Approach         : Combinatorial
-- Description      : Comparing two bits and determining whether they are equal
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 1 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Bit_Comp_Eq is
	port (
			A  : in  std_logic;
			B  : in  std_logic;
			EQ : out std_logic);
end Bit_Comp_Eq;

architecture Combinatorial of Bit_Comp_Eq is

begin
	
	EQ <= '1' when A = B else '0';
	
end Combinatorial;
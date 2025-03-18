----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Bit_Mux2_1
-- Module Name      : Bit_Mux2_1
-- HDL Standard     : VHDL
-- Approach         : Combinatorial
-- Description      : 1-Bit 2x1 multiplexer
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

entity Bit_Mux2_1 is
	port (
			S  : in  std_logic;
			D0 : in  std_logic;
			D1 : in  std_logic;
			O  : out std_logic);
end Bit_Mux2_1;

architecture Combinatorial of Bit_Mux2_1 is
begin
	
	O <=  D0 when S = '0' else	D1;
	
end Combinatorial;
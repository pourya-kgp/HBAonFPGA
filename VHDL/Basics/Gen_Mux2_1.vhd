----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Mux2_1
-- Module Name      : Gen_Mux2_1
-- HDL Standard     : VHDL
-- Approach         : Combinatorial
-- Description      : Generic core for 2x1 multiplexer
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 8 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Mux2_1 is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				S          : in  std_logic;
				D0         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				D1         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				O          : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_Mux2_1;

architecture Combinatorial of Gen_Mux2_1 is
begin

	O <= D0 when S = '0' else D1;

end Combinatorial;
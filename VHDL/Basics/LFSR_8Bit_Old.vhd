----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : LFSR_8Bit_Old
-- Module Name      : LFSR_8Bit_Old
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : 8-Bit Linear Feedback Shift-Register (LFSR)
-- Comments         : Xilinx application note 052 July 7,1996 (Version 1.1)
-- Dependencies     : 
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 732 MHz
-- Area  Estimation : 1 LUTs + 8 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LFSR_8Bit_Old is
	port (
			CLK   : in  std_logic;
			RESET : in  std_logic;
			CE    : in  std_logic;
			LFSR  : out std_logic_vector (7 downto 0));
end LFSR_8Bit_Old;

architecture Behavioral of LFSR_8Bit_Old is
	
	-- For a normal LFSR sequential counting, the starting value (seed) must be less or equal to 7
	signal Linear_Feedback : std_logic := '0';
	signal Count           : std_logic_vector (7 downto 0) := X"01";
	
begin
	
	Linear_Feedback <= Count(7) xnor Count(5) xnor Count(4) xnor Count(3);
	LFSR            <= Count;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			Count <= X"01";
		elsif (rising_edge(CLK)) then
			if (CE = '1') then
				Count <= Count(6 downto 0) & Linear_Feedback;
			end if;
		end if;
	end process;
	
end Behavioral;
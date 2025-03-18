----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : LFSR_8Bit
-- Module Name      : LFSR_8Bit
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
-- Revision Date    : 2024/05/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LFSR_8Bit is 
	port (
			CLK   : in  std_logic;
			RESET : in  std_logic;
			CE    : in  std_logic;
			LFSR  : out std_logic_vector (7 downto 0));
end LFSR_8Bit;

architecture Behavioral of LFSR_8Bit is
	
	-- For a normal LFSR sequential counting, the starting value (seed) must be less or equal to 7
	signal Count : std_logic_vector (7 downto 0) := X"01";
	
begin
	
	process (CLK , RESET)
	begin 
		if (RESET = '1') then 
			Count <= X"01";
		elsif (rising_edge(CLK) and CE = '1') then 
			Count <= Count(6 downto 0) & (Count(7) xnor Count(5) xnor Count(4) xnor Count(3));
		end if;
	end process;
	
	LFSR <= Count;
	
end Behavioral;
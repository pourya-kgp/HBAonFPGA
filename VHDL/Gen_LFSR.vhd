----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_LFSR
-- Module Name      : Gen_LFSR
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for 8-Bit LFSR (Linear Feedback Shift Register)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 460 MHz
-- Area  Estimation : 10 LUTs + 8 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/04
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_LFSR is 
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				CITIES     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				LFSR       : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_LFSR;

architecture Behavioral of Gen_LFSR is
	
	-- For a normal LFSR sequential counting, the starting value (seed) must be less or equal to 7
	signal Count  : std_logic_vector (DATA_WIDTH-1 downto 0) := conv_std_logic_vector (1 , DATA_WIDTH);
	
	-- Constants
	constant Zero : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			Count <= conv_std_logic_vector (1 , DATA_WIDTH);
		elsif (rising_edge(CLK) and CE = '1') then
			if    (CITIES < 2**3) then
				Count <= Zero(DATA_WIDTH-1 downto 3) & Count(1 downto 0) & (Count(2) xnor Count(1));          -- 3 bit LFSR
			elsif (CITIES < 2**4) then
				Count <= Zero(DATA_WIDTH-1 downto 4) & Count(2 downto 0) & (Count(3) xnor Count(2));          -- 4 bit LFSR
			elsif (CITIES < 2**5) then
				Count <= Zero(DATA_WIDTH-1 downto 5) & Count(3 downto 0) & (Count(4) xnor Count(2));          -- 5 bit LFSR
			elsif (CITIES < 2**6) then
				Count <= Zero(DATA_WIDTH-1 downto 6) & Count(4 downto 0) & (Count(5) xnor Count(4));          -- 6 bit LFSR
			elsif (CITIES < 2**7) then
				Count <= Zero(DATA_WIDTH-1 downto 7) & Count(5 downto 0) & (Count(6) xnor Count(5));          -- 7 bit LFSR
			else
				Count <= Count(DATA_WIDTH-2 downto 0) & (Count(7) xnor Count(5) xnor Count(4) xnor Count(3)); -- 8 bit LFSR
			end if; 
		end if; 
	end process;
	
	LFSR <= Count;
	
end Behavioral;
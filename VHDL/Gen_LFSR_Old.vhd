----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_LFSR_Old
-- Module Name      : Gen_LFSR_Old
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
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_LFSR_Old is 
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				CITIES     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				LFSR       : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_LFSR_Old;

architecture Behavioral of Gen_LFSR_Old is
	
	-- For a normal LFSR sequential counting, the starting value (seed) must be less or equal to 7
	
	-- Signals
	signal Limit           : integer range 0 to 2**DATA_WIDTH-1;
	signal Max_Width       : integer range 3 to DATA_WIDTH;
	signal Linear_Feedback : std_logic := '0';
	signal Count           : std_logic_vector (DATA_WIDTH-1 downto 0) := conv_std_logic_vector (1 , DATA_WIDTH);
	
	-- Constants
	constant Zero          : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	Limit           <=   conv_integer (CITIES);
	
	Max_Width       <=
								3 when Limit < 2**3 else
								4 when Limit < 2**4 else
								5 when Limit < 2**5 else
								6 when Limit < 2**6 else
								7 when Limit < 2**7 else
								8;
	
								with Max_Width select
	Linear_Feedback <=
								Count(2) xnor Count(1) when 3,
								Count(3) xnor Count(2) when 4,
								Count(4) xnor Count(2) when 5,
								Count(5) xnor Count(4) when 6,
								Count(6) xnor Count(5) when 7,
								Count(7) xnor Count(5) xnor Count(4) xnor Count(3) when others;
	
								with Max_Width select
	LFSR            <=
								Zero(DATA_WIDTH-1 downto 3) & Count(2 downto 0) when 3,
								Zero(DATA_WIDTH-1 downto 4) & Count(3 downto 0) when 4,
								Zero(DATA_WIDTH-1 downto 5) & Count(4 downto 0) when 5,
								Zero(DATA_WIDTH-1 downto 6) & Count(5 downto 0) when 6,
								Zero(DATA_WIDTH-1 downto 7) & Count(6 downto 0) when 7,
								Count(DATA_WIDTH-1 downto 0) when others;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			Count <= conv_std_logic_vector (1 , DATA_WIDTH);
		elsif (rising_edge(CLK)) then
			if (CE = '1') then
				Count <= Count(DATA_WIDTH-2 downto 0) & Linear_Feedback;
			end if; 
		end if; 
	end process;
	
end Behavioral;
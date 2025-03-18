----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Sort_Permit_TB
-- Module Name      : Gen_Sort_Permit_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core of the sort's permission
-- Comments         : UUT => Gen_Sort_Permit
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/06/11
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Gen_Sort_Permit_TB is
end Gen_Sort_Permit_TB;

architecture Behavioral of Gen_Sort_Permit_TB is

	-- Generic Constants
	constant data_width : integer := 8;

	-- Component Declaration for the Unit Under Test (UUT) 
	component Gen_Sort_Permit
--		generic (
--					DATA_WIDTH  : integer := 8);
		port    (
					DATA1_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CE          : in  std_logic;
					NEXT_PERMIT : in  std_logic;
					COMPARE_IN  : in  std_logic;
					COMPARE_OUT : out std_logic;
					PERMIT      : out std_logic);
	end component;    
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal data1_in     : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data2_in     : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal ce           : std_logic := '0';
	signal next_permit  : std_logic := '0';
	signal compare_in   : std_logic := '0';
	
	-- Output signals
	signal compare_out  : std_logic := '0';
   signal permit       : std_logic := '0';
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Sort_Permit
--		generic map (
--						DATA_WIDTH  => data_width)
		port map    (
						DATA1_IN    => data1_in,
						DATA2_IN    => data2_in,
						CE          => ce,
						NEXT_PERMIT => next_permit,
						COMPARE_IN  => compare_in,
						COMPARE_OUT => compare_out,
						PERMIT      => permit);

	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Stimulus process
	stim_proc: process
   begin

		data1_in	<= conv_std_logic_vector (40 , data_width);
		data2_in	<= conv_std_logic_vector (20 , data_width);
		wait for clk_period*2;
		
		ce <= '1';
		wait for clk_period*2;
		
		next_permit <= '1';
		wait for clk_period*2;
		
		compare_in <= '1';
		wait for clk_period*2;

		next_permit <= '0';
		wait for clk_period*2;
		next_permit <= '1';
		wait for clk_period*2;

		data1_in	<= conv_std_logic_vector (20 , data_width);
		data2_in	<= conv_std_logic_vector (40 , data_width);
		compare_in <= '0';
		wait for clk_period*2;
		
		next_permit <= '0';
		wait for clk_period*2;
		
		next_permit <= '1';
		wait for clk_period*2;
		
		data1_in	<= conv_std_logic_vector (40 , data_width);
		data2_in	<= conv_std_logic_vector (20 , data_width);
		compare_in <= '0';
		next_permit <= '0';
		wait for clk_period*2;
		
		next_permit <= '1';
		wait for clk_period*2;
		
		ce <= '0';
		next_permit <= '0';
		wait for clk_period*2;

		next_permit <= '1';
		wait for clk_period*2;
		
		wait;
	end process;

end;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Edge_Detector_TB
-- Module Name      : Edge_Detector_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the rising edge detector that is based on emission delay technique
-- Comments         : UUT => Edge_Detector
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity Edge_Detector_TB is
end Edge_Detector_TB;

architecture Behavioral of Edge_Detector_TB is

	-- Component Declaration for the Unit Under Test (UUT)
	component Edge_Detector
		port (
				CLK    : in  std_logic;
				RESET  : in  std_logic;
				EDGE   : in  std_logic;
				DETECT : out std_logic);
	end component;
	
	-- Stimulus signals
	signal clk    : std_logic := '0';
	signal reset  : std_logic := '0';
	signal edge   : std_logic := '0';
	
	-- Output signals
	signal detect : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Edge_Detector
		port map (
					CLK    => clk,
					RESET  => reset,
					EDGE   => edge,
					DETECT => detect);
	
	-- Clock process
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period;
	
	-- Stimulus process
	stim_proc: process
	begin
		wait until rising_edge(clk);
		wait for clk_period*20;
		edge <= '1';
		wait for clk_period*20;
		edge <= '0';
	end process;
	
end;
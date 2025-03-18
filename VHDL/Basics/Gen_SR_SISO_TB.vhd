----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_SR_SISO_TB
-- Module Name      : Gen_SR_SISO_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for generic core of the Serial-In and Serial-Out Shift Register (SISO SR)
-- Comments         : UUT => Gen_SR_SISO
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
 
entity Gen_SR_SISO_TB is
end Gen_SR_SISO_TB;
 
architecture behavior of Gen_SR_SISO_TB is

	-- Generic Constants
	constant data_width : integer := 8;
 
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_SR_SISO
--		generic (
--					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					SR_IN      : in  std_logic;
					SR_OUT     : out std_logic);
	end component;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal sr_in        : std_logic := '0';

	-- Output signals
	signal sr_out       : std_logic := '0';

	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_SR_SISO
--		generic map (
--						DATA_WIDTH => data_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						SR_IN      => sr_in,
						SR_OUT     => sr_out);

	-- Clock process
	clk <= not(clk) after clk_period/2;
	
	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period;

	-- Stimulus process
	stim_proc: process
	begin
		wait until falling_edge(reset);
		wait until rising_edge(clk);
		wait for clk_period;
		
		sr_in <= '1';
		wait for clk_period;
		sr_in <= '0';

		wait;
	end process;

end;
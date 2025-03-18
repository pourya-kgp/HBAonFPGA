----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : LFSR_8Bit_TB
-- Module Name      : LFSR_8Bit_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for 8-Bit Linear Feedback Shift-Register (LFSR)
-- Comments         : UUT => LFSR_8Bit / LFSR_8Bit_Old
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity LFSR_8Bit_TB is
end LFSR_8Bit_TB;

architecture Behavioral of LFSR_8Bit_TB is
 
	-- Component Declaration for the Unit Under Test (UUT)
	component LFSR_8Bit -- LFSR_8Bit / LFSR_8Bit_Old
		port (
			CLK   : in  std_logic;
			RESET : in  std_logic;
			CE    : in  std_logic;
			LFSR  : out std_logic_vector (7 downto 0));
	end component;
	
	-- Stimulus signals
	signal clk      : std_logic := '0';
	signal reset    : std_logic := '0';
	signal ce       : std_logic := '0';
	
	-- Output signals
	signal lfsr     : std_logic_vector (7 downto 0);
	
	-- Expected signals
	signal exp_lfsr : std_logic_vector (7 downto 0) := X"01"; -- Initial value must be less or equal to 7
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;
	
begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: LFSR_8Bit -- LFSR_8Bit / LFSR_8Bit_Old
		port map (
					CLK   => clk,
					RESET => reset,
					CE    => ce,
					LFSR  => LFSR);

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
		wait until falling_edge(reset);
		wait for clk_period;
		wait until rising_edge(clk);		
		
		for i in 0 to 2**8-2 loop
			ce <= '1';
			wait for clk_period;
			ce <= '0';
			wait for clk_period;
			exp_lfsr <= exp_lfsr(6 downto 0) & (exp_lfsr(7) xnor exp_lfsr(5) xnor exp_lfsr(4) xnor exp_lfsr(3));
		end loop;
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (lfsr)
	begin
		if (lfsr /= exp_lfsr) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;
	
end;
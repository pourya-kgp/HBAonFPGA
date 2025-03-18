----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_LFSR_TB
-- Module Name      : Gen_LFSR_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core of 8-Bit LFSR (Linear Feedback Shift Register)
-- Comments         : UUT => Gen_LFSR / Gen_LFSR_Old
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_LFSR_TB is
end Gen_LFSR_TB;
 
architecture Behavioral of Gen_LFSR_TB is

	-- Generic Constants
	constant data_width : integer := 8;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_LFSR -- Gen_LFSR / Gen_LFSR_Old
--		generic (
--					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					CITIES     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					LFSR       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	-- Constants
	constant Zero       : std_logic_vector (data_width-1 downto 0) := (others => '0');
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal cities       : std_logic_vector (data_width-1 downto 0) := (others => '0');
	
	-- Output signals
	signal lfsr         : std_logic_vector (data_width-1 downto 0) := (others => '0');
	
	-- Expected signals
	signal exp_lfsr     : std_logic_vector (data_width-1 downto 0) := X"01";  -- Initial value must be less or equal to 7
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_LFSR -- Gen_LFSR / Gen_LFSR_Old
--		generic map (
--						DATA_WIDTH => data_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						CITIES     => cities,
						LFSR       => lfsr);
	
	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Stimulus process
	stim_proc: process
	begin
		
		for j in 3 to data_width loop -- Applying different bits for the LFSR
			
			-- Hold reset state for the specified time
			reset <= '1', '0' after rst_period;
			wait until falling_edge(reset);
			wait for clk_period;
			wait until rising_edge(clk);
		
			cities   <= conv_std_logic_vector (2**j - j , data_width);
			exp_lfsr <= conv_std_logic_vector (1        , data_width);
			
			for i in 0 to 2**j-2 loop -- Applying a full loop stimulus on the LFSR (starting with 1 and ending with 0)
			
				ce <= '1';
				wait for clk_period;
				
				if    (cities < 2**3) then
					exp_lfsr <= Zero(data_width-1 downto 3) & exp_lfsr(1 downto 0) & (exp_lfsr(2) xnor exp_lfsr(1)); -- 3 bit LFSR
				elsif (cities < 2**4) then
					exp_lfsr <= Zero(data_width-1 downto 4) & exp_lfsr(2 downto 0) & (exp_lfsr(3) xnor exp_lfsr(2)); -- 4 bit LFSR
				elsif (cities < 2**5) then
					exp_lfsr <= Zero(data_width-1 downto 5) & exp_lfsr(3 downto 0) & (exp_lfsr(4) xnor exp_lfsr(2)); -- 5 bit LFSR
				elsif (cities < 2**6) then
					exp_lfsr <= Zero(data_width-1 downto 6) & exp_lfsr(4 downto 0) & (exp_lfsr(5) xnor exp_lfsr(4)); -- 6 bit LFSR
				elsif (cities < 2**7) then
					exp_lfsr <= Zero(data_width-1 downto 7) & exp_lfsr(5 downto 0) & (exp_lfsr(6) xnor exp_lfsr(5)); -- 7 bit LFSR
				else
					exp_lfsr <= exp_lfsr(data_width-2 downto 0) & (exp_lfsr(7) xnor exp_lfsr(5) xnor exp_lfsr(4) xnor exp_lfsr(3)); -- 8 bit LFSR
				end if;

				ce <= '0';
				wait for clk_period;

			end loop;
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
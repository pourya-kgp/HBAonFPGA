----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Index_ij_TB
-- Module Name      : Gen_Index_ij_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for sequentially selecting two RAM addresses
-- Comments         : UUT => Gen_Index_ij / Gen_Index_ij_Structural / Gen_Index_ij_Behavioral
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
 
entity Gen_Index_ij_TB is
end Gen_Index_ij_TB;
 
architecture Behavioral of Gen_Index_ij_TB is

	-- Generic Constants
	constant data_width : integer := 8;

	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Index_ij_Behavioral -- Gen_Index_ij / Gen_Index_ij_Structural / Gen_Index_ij_Behavioral
--		generic (
--					DATA_WIDTH       : integer := 8);
		port    (
					CLK              : in  std_logic;
					RESET            : in  std_logic;
					CE               : in  std_logic;
					NEXT_J           : in  std_logic;
					CITIES           : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					LAST_J           : out std_logic;
					NEXT_I           : out std_logic;
					LAST_I           : out std_logic;
					ENABLE_OUT       : out std_logic;
					CURRENT_CITY_IND : out std_logic_vector (DATA_WIDTH-1 downto 0);
					NEXT_CITY_IND    : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	-- Constants
	constant city_num       : integer range 0 to 2**data_width-1 := 8;
	
	-- Stimulus signals
	signal clk              : std_logic := '0';
	signal reset            : std_logic := '0';
	signal ce               : std_logic := '0';
	signal next_j           : std_logic := '0';
	signal cities           : std_logic_vector (data_width-1 downto 0) := conv_std_logic_vector (city_num , data_width);
	
	-- Outputs
	signal next_city_ind    : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal current_city_ind : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal last_j           : std_logic := '0';
	signal next_i           : std_logic := '0';
	signal last_i           : std_logic := '0';
	signal enable_out       : std_logic := '0';
	
	-- Clock period definitions
	constant clk_period     : time := 10 ns; -- 100 MHz clock
	
	-- Reset period definitions
	constant rst_period     : time := 10*clk_period;
	
	-- NEXT_J period definitions
	constant nxt_period     : time := 11*clk_period; -- nxt_period > city_num*clk_period

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Index_ij_Behavioral -- Gen_Index_ij / Gen_Index_ij_Structural / Gen_Index_ij_Behavioral
--		generic map (
--						DATA_WIDTH       => data_width)
		port map    (
						CLK              => clk,
						RESET            => reset,
						CE               => ce,
						NEXT_J           => next_j,
						CITIES           => cities,
						LAST_J           => last_j,
						NEXT_I           => next_i,
						LAST_I           => last_i,
						ENABLE_OUT       => enable_out,
						NEXT_CITY_IND    => next_city_ind,
						CURRENT_CITY_IND => current_city_ind);

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

	-- CE Stimulus
	ce <= '0', '1' after (rst_period + 3*clk_period);

	-- Stimulus process
	stim_proc: process
	begin
		next_j <= '0';
		wait for nxt_period;
		next_j <= '1';
		wait for clk_period;
	end process;
	
end;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_RNG_City_Set_TB
-- Module Name      : Gen_RNG_City_Set_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core that generats two pseudo-random city
-- Comments         : UUT => Gen_RNG_City_Set
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/10
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
 
entity Gen_RNG_City_Set_TB is
end Gen_RNG_City_Set_TB;

architecture Behavioral of Gen_RNG_City_Set_TB is

	-- Generic Constants
	constant data_width : integer := 8;

	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_RNG_City_Set
--		generic (
--					DATA_WIDTH  : integer := 8);
		port    (
					CLK         : in  std_logic;
					RESET       : in  std_logic;
					CE          : in  std_logic;
					CITIES      : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_IND_R1 : out std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_IND_R2 : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DONE        : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**data_width-1 := 51;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal cities       : std_logic_vector (data_width-1 downto 0) := conv_std_logic_vector (city_num , data_width);

	-- Output signals
	signal city_ind_r1  : std_logic_vector(data_width-1 downto 0) := (others => '0');
	signal city_ind_r2  : std_logic_vector(data_width-1 downto 0) := (others => '0');
	signal done         : std_logic := '0';
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_RNG_City_Set
--		generic map (
--						DATA_WIDTH  => data_width)
		port map    (
						CLK         => clk,
						RESET       => reset,
						CE          => ce,
						CITIES      => cities,
						CITY_IND_R1 => city_ind_r1,
						CITY_IND_R2 => city_ind_r2,
						DONE        => done);
	
	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period; 
	
	-- Stimulus process
	stim_proc: process
	begin
		wait until falling_edge(reset);
		wait for clk_period;
		wait until rising_edge(clk);
		
		for i in 0 to (city_num-3)*(city_num-2)-(city_num-3) loop
			ce <= '1';
			wait for clk_period;
			ce <= '0';
			wait until rising_edge(done);
			wait for clk_period;
		end loop;
		
		wait;
	end process;
	
end;
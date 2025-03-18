----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Bee_TB
-- Module Name      : Gen_Bee_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core simulating the bee behavior
-- Comments         : UUT => Gen_Bee_Async / Gen_Bee_Sync
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
use ieee.std_logic_arith.all;

entity Gen_Bee_TB is
end Gen_Bee_TB;

architecture Behavioral of Gen_Bee_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant tour_width : integer := 32;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Bee_Sync -- Gen_Bee_Async / Gen_Bee_Sync
--		generic  (
--					INDX_WIDTH : integer := 8;
--					ADDR_WIDTH : integer := 11;
--					TOUR_WIDTH : integer := 32);
		port     (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					SEL        : in  std_logic_vector (2 downto 0);
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA1_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_IN   : in  std_logic_vector (TOUR_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_OUT  : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**indx_width-1 := 51;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal sel          : std_logic_vector (2 downto 0)            := (others => '0');
	signal cities       : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	signal data1_in     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal data2_in     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal fitss_in     : std_logic_vector (tour_width-1 downto 0) := (others => '0');

	-- Output signals
	signal data1_out    : std_logic_vector (indx_width-1 downto 0);
	signal data2_out    : std_logic_vector (indx_width-1 downto 0);
	signal fitss_out    : std_logic_vector (tour_width-1 downto 0);
	signal done         : std_logic;
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;
	
	-- CE period definitions
	constant ce_period  : time := clk_period;
	
begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Bee_Sync -- Gen_Bee_Async / Gen_Bee_Sync
--		generic map (
--						INDX_WIDTH => indx_width,
--						ADDR_WIDTH => addr_width,
--						TOUR_WIDTH => tour_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						SEL        => sel,
						CITIES     => cities,
						DATA1_IN   => data1_in,
						DATA2_IN   => data2_in,
						FITSS_IN   => fitss_in,
						DATA1_OUT  => data1_out,
						DATA2_OUT  => data2_out,
						FITSS_OUT  => fitss_out,
						DONE       => done);

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

		-- Single_Write
		sel <= "000";
		ce <= '1';
		wait for ce_period; 
		ce <= '0';
		wait for clk_period;
		fitss_in    <= conv_std_logic_vector (350 , tour_width);
		for i in 0 to city_num-1 loop
			data1_in <= conv_std_logic_vector (i+1 , indx_width);
			data2_in <= conv_std_logic_vector (i   , indx_width);
			wait for clk_period;
		end loop;
		wait until falling_edge(done);
		
		-- Single_Read
		sel <= "011";	
		ce <= '1';
		wait for ce_period;
		ce <= '0';
		wait until falling_edge(done); -- Duration: (city_num+2)*clk_period
		
		-- Dual_Read
		sel <= "010";
		data1_in <= conv_std_logic_vector (1 , indx_width);
		data2_in <= conv_std_logic_vector (2 , indx_width);
		ce <= '1';
		wait for ce_period;
		ce <= '0';
		wait until falling_edge(done); -- Duration: 3*clk_period
		
		-- Exchange
		sel <= "001";
		data1_in <= conv_std_logic_vector (1 , indx_width);
		data2_in <= conv_std_logic_vector (2 , indx_width);
		ce <= '1';
		wait for ce_period;
		ce <= '0';
		wait until falling_edge(done); -- Duration: 5*clk_period
		
		-- Dual_Read
		sel <= "010";
		data1_in <= conv_std_logic_vector (1 , indx_width);
		data2_in <= conv_std_logic_vector (2 , indx_width);
		ce <= '1';
		wait for ce_period;
		ce <= '0';
		wait until falling_edge(done); -- Duration: 3*clk_period
		
		-- Read_Write
		sel <= "100";
		ce <= '1';
		wait for ce_period; 
		ce <= '0';
		wait for clk_period;
		fitss_in <= conv_std_logic_vector (200 , tour_width);
		for i in 0 to city_num-1 loop
			data1_in <= conv_std_logic_vector (city_num-i , indx_width);
			data2_in <= conv_std_logic_vector (i          , indx_width);
			wait for clk_period;
		end loop;
		wait until falling_edge(done);
		fitss_in <= conv_std_logic_vector (350 , tour_width);
		
		-- Single_Read
		sel <= "011";
		ce <= '1';
		wait for ce_period;
		ce <= '0';
		wait until falling_edge(done); -- Duration: (city_num+2)*clk_period
		
		wait;
	end process;
	
end;
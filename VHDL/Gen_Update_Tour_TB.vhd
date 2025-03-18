----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Update_Tour_TB
-- Module Name      : Gen_Update_Tour_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core to update the TSP tour after a successful local 2-OPT search
-- Comments         : UUT => Gen_Update_Tour_V1 / Gen_Update_Tour_V2
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/12
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_Update_Tour_TB is
end Gen_Update_Tour_TB;

architecture Behavioral of Gen_Update_Tour_TB is
	
	-- Generic Constants
	constant data_width : integer := 8;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Update_Tour_V1 -- Gen_Update_Tour_V1 / Gen_Update_Tour_V2
--		generic (
--					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DONE_BEE   : in  std_logic;
					DATA1_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					CE_BEE     : out std_logic;
					DONE       : out std_logic);
	end component;
	
	-- Constants
	constant city_num    : integer range 0 to 2**data_width-1 := 51;
	
	-- Stimulus signals
	signal clk           : std_logic := '0';
	signal reset         : std_logic := '0';
	signal ce            : std_logic := '0';
	signal done_bee      : std_logic := '0';
	signal data1_in      : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data2_in      : std_logic_vector (data_width-1 downto 0) := (others => '0');

	-- Output signals
	signal data1_out     : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data2_out     : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal ce_bee        : std_logic := '0';
	signal done          : std_logic := '0';

	-- Expected signals
	signal exp_data1_out : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal exp_data2_out : std_logic_vector (data_width-1 downto 0) := (others => '0');
	
	-- Clock period definitions
	constant clk_period  : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period  : time := 10*clk_period;
 
begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Update_Tour_V1 -- Gen_Update_Tour_V1 / Gen_Update_Tour_V2
--		generic map (
--						DATA_WIDTH => data_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						DONE_BEE   => done_bee,
						DATA1_IN   => data1_in,
						DATA2_IN   => data2_in,
						DATA1_OUT  => data1_out,
						DATA2_OUT  => data2_out,
						CE_BEE     => ce_bee,
						DONE       => done);

	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period; 
   
	-- Stimulus process
	stim_proc1: process
	begin
		wait until falling_edge(reset);
		wait for clk_period;
		wait until rising_edge(clk);
		
		data1_in <= conv_std_logic_vector (0 , data_width);
		data2_in <= conv_std_logic_vector (0 , data_width);
		
		wait for clk_period;
		ce <= '1';
		wait until rising_edge(done);
		wait for clk_period*5;	
		ce <= '0';
		wait for clk_period;	
				
		data1_in <= conv_std_logic_vector (20 , data_width);
		data2_in <= conv_std_logic_vector (41 , data_width);
		
		wait for clk_period;
		ce <= '1';
		wait until rising_edge(done);
		wait for clk_period*5;	
		ce <= '0';
		
		wait;
	end process;	
		
	-- Stimulus process
	stim_proc2: process
	begin
		for i in 1 to (city_num-1)/2 loop
			wait until falling_edge(ce_bee);
			exp_data1_out <= data1_in + conv_std_logic_vector (i , data_width);
			exp_data2_out <= data2_in - conv_std_logic_vector (i , data_width);
			wait for clk_period;
			done_bee <= '1';
			wait for clk_period;
			done_bee <= '0';
		end loop;
		wait;
	end process;
	
	rpt_out : process (exp_data1_out)
	begin
		if (data1_out /= exp_data1_out or data2_out /= exp_data2_out) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;
	
end;
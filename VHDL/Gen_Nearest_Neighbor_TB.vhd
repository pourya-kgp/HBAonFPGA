----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_Neighbor_TB
-- Module Name      : Gen_Nearest_Neighbor_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core which specifys the nearest neighbor from the current city
-- Comments         : UUT => Gen_Nearest_Neighbor
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/07
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Gen_Nearest_Neighbor_TB is
end Gen_Nearest_Neighbor_TB;

architecture Behavioral of Gen_Nearest_Neighbor_TB is
	
	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant tour_width : integer := 32;

	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Nearest_Neighbor
--		generic (
--					INDX_WIDTH     : integer := 8;
--					ADDR_WIDTH     : integer := 11;
--					TOUR_WIDTH     : integer := 32);
		port    (
					CLK            : in    std_logic;
					RESET          : in    std_logic;
					CE             : in    std_logic;
					CE_OPT         : in    std_logic;
					CE_CNT         : in    std_logic;
					SEL            : in    std_logic_vector (1 downto 0);
					CITIES         : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					FIRST_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					SECND_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					DONE           : out   std_logic;
					TOUR           : out   std_logic_vector (INDX_WIDTH-1 downto 0);
					INDX           : out   std_logic_vector (INDX_WIDTH-1 downto 0);
					NEAREST_IND    : inout std_logic_vector (INDX_WIDTH-1 downto 0);
					DIST_MIN       : inout std_logic_vector (TOUR_WIDTH-1 downto 0);
					LAST_J         : inout std_logic;
					NEXT_I         : inout std_logic;
					LAST_I         : inout std_logic);
    end component;
	
	-- Constants
	constant city_num     : integer range 0 to 2**indx_width-1 := 51;
	
	-- Stimulus signals
	signal clk            : std_logic := '0';
	signal reset          : std_logic := '0';
	signal ce             : std_logic := '0';
	signal ce_opt         :	std_logic := '0';
	signal ce_cnt         : std_logic := '0';
	signal sel            : std_logic_vector (1 downto 0)            := (others => '0');
	signal cities         : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	signal first_city_ind : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal secnd_city_ind : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	
	-- BiDir signals
	signal nearest_ind    : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal dist_min       : std_logic_vector (tour_width-1 downto 0) := (others => '0');
	signal last_j         : std_logic := '0';
	signal next_i         : std_logic := '0';
	signal last_i         : std_logic := '0';
	
	-- Output signals
	signal tour           : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal indx           : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal done           : std_logic := '0';
	
	-- Expected signals
	signal exp_tour       : std_logic_vector (indx_width-1 downto 0) := (others => '0');

	-- Clock period definitions
	constant clk_period   : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period   : time := 10*clk_period;
	
	-- Function: read_file (This function reads a text file consisting of a distance matrix and stores it in an 1D array)
	type ram_type is array (0 to city_num**2-1) of std_logic_vector (indx_width-1 downto 0);
	
	impure function read_file (txt_file: in string ) return ram_type is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (indx_width-1 downto 0);
		variable txt_ram  : ram_type ;
	begin
		for i in ram_type'range loop
			readline (ram_file , txt_line);
			read (txt_line , txt_bit);
			txt_ram (i) := to_stdlogicvector (txt_bit);
		end loop;
		return txt_ram;
	end function;
	
	-- Read the text file and store it in a ram array
	signal ram : ram_type := read_file ("RTL_TB/TSP/eil51/eil51NNTour.txt");

begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Nearest_Neighbor
--		generic map (
--						INDX_WIDTH     => indx_width,
--						ADDR_WIDTH     => addr_width,
--						TOUR_WIDTH     => tour_width)
		port map    (
						CLK            => clk,
						RESET          => reset,
						CE             => ce,
						CE_OPT         => ce_opt,
						CE_CNT         => ce_cnt,
						SEL            => sel,
						CITIES         => cities,
						FIRST_CITY_IND => first_city_ind,
						SECND_CITY_IND => secnd_city_ind,
						TOUR           => tour,
						INDX           => indx,
						NEAREST_IND    => nearest_ind,
						DIST_MIN       => dist_min,
						LAST_J         => last_j,
						NEXT_I         => next_i,
						LAST_I         => last_i,
						DONE           => done);
	
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
		
		-- Start
		ce <= '1';
		wait for clk_period;
		
		for j in 0 to city_num-1 loop
		
			-- Sort
			sel <= "00"; -- Sort
			ce_opt <= '1';
			wait for clk_period;
			ce_opt <= '0';
			wait until falling_edge(done);
		
			-- Exchange
			sel <= "01"; -- Exchange
			first_city_ind <= conv_std_logic_vector (0  , indx_width); -- Index = 0 , City = 1
			secnd_city_ind <= conv_std_logic_vector (j  , indx_width); -- Index = j , City = j+1
			ce_opt <= '1';
			wait for clk_period;
			ce_opt <= '0';
			wait until falling_edge(done);
			
			for i in 1 to city_num-2 loop
			
				-- Compare
				sel <= "10"; -- Dual_Read
				ce_cnt <= '1';
				wait for clk_period;
				ce_cnt <= '0';
				wait until falling_edge(done);
				
				-- Exchange
				sel <= "01"; -- Exchange
				first_city_ind <= conv_std_logic_vector (i  , indx_width); -- Index = i , City = i+1
				secnd_city_ind <= nearest_ind;
				ce_opt <= '1';
				wait for clk_period;
				ce_opt <= '0';
				wait until falling_edge(done);
			
			end loop;
			
			-- Extrimly important: Two forced counting is needed (ce_cnt) because the last two number series would not be counted (49-50 and 50-0)
			sel <= "10"; -- Dual_Read
			for i in 0 to 1 loop
				ce_cnt <= '1';
				wait for clk_period;
				ce_cnt <= '0';
				wait for clk_period;
			end loop;
			
			-- Out
			wait until falling_edge(done);
			sel <= "11"; -- Single_Read
			ce_opt <= '1';
			wait for clk_period;
			ce_opt <= '0';
			
			wait for clk_period;
			wait until falling_edge(clk);
			for i in 0 to city_num-1 loop
				exp_tour <= ram (i + city_num*j);
				wait for clk_period;
			end loop;
			exp_tour <= (others => '0');
			wait until falling_edge(done);
			
		end loop;
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (exp_tour)
	begin
		if (tour /= exp_tour and time(now) > rst_period) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;
	
end;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Local_Search_TB
-- Module Name      : Gen_Local_Search_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core, which is responsible for the 2-Opt local search
-- Comments         : UUT => Gen_Local_Search
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
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Gen_Local_Search_TB is
end Gen_Local_Search_TB;

architecture Behavioral of Gen_Local_Search_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant tour_width : integer := 32;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Local_Search
--		generic (
--					INDX_WIDTH : integer := 8;
--					ADDR_WIDTH : integer := 11;
--					TOUR_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DONE_BEE   : in  std_logic;
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					ITERS_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA1_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_IN   : in  std_logic_vector (TOUR_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_OUT  : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					NEXT_DATA  : out std_logic;
					DONE       : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**indx_width-1 := 51;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal done_bee     : std_logic := '0';
	signal cities       : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	signal iters_in     : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (255 , indx_width); -- Iterations (Maximum possible iterations = 255)
	signal data1_in     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal data2_in     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal fitss_in     : std_logic_vector (tour_width-1 downto 0) := (others => '0');
	
	-- Output signals
	signal data1_out    : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal data2_out    : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal fitss_out    : std_logic_vector (tour_width-1 downto 0) := (others => '1');
	signal next_data    : std_logic := '0';
	signal done         : std_logic := '0';
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;
	
	---------- Functions ----------
	
	-- Function: read_file_indx (This function reads a text file consisting of nearest neighbor tours and stores it in an 1D array)
	type ram_type_indx is array (0 to city_num**2-1) of std_logic_vector (indx_width-1 downto 0);
	
	impure function read_file_indx (txt_file: in string ) return ram_type_indx is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (indx_width-1 downto 0);
		variable txt_ram  : ram_type_indx ;
	begin
		for i in ram_type_indx'range loop
			readline (ram_file , txt_line);
			read (txt_line , txt_bit);
			txt_ram (i) := to_stdlogicvector (txt_bit);
		end loop;
		return txt_ram;
	end function;
	
	-- Function: read_file_tour (This function reads a text file consisting of nearest neighbor tours' length and stores it in an 1D array)
	type ram_type_tour is array (0 to city_num-1) of std_logic_vector (tour_width-1 downto 0);
	
	impure function read_file_tour (txt_file: in string ) return ram_type_tour is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (tour_width-1 downto 0);
		variable txt_ram  : ram_type_tour ;
	begin
		for i in ram_type_tour'range loop
			readline (ram_file , txt_line);
			read (txt_line , txt_bit);
			txt_ram (i) := to_stdlogicvector (txt_bit);
		end loop;
		return txt_ram;
	end function;
	
	---------- RAMs ----------
	
	-- Read the text file and store it in a ram array
	signal ram_indx : ram_type_indx := read_file_indx ("RTL_TB/TSP/eil51/eil51NNTour.txt");
		
	-- Read the text file and store it in a ram array
	signal ram_tour : ram_type_tour := read_file_tour ("RTL_TB/TSP/eil51/eil51NNTourLength.txt");
	
begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Local_Search
--		generic map (
--						INDX_WIDTH => indx_width,
--						ADDR_WIDTH => addr_width,
--						TOUR_WIDTH => tour_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						DONE_BEE   => done_bee,
						CITIES     => cities,
						ITERS_IN   => iters_in,
						DATA1_IN   => data1_in,
						DATA2_IN   => data2_in,
						FITSS_IN   => fitss_in,
						DATA1_OUT  => data1_out,
						DATA2_OUT  => data2_out,
						FITSS_OUT  => fitss_out,
						NEXT_DATA  => next_data,
						DONE       => done);
	
   -- Clock process
	clk <= not(clk) after clk_period/2;

	-- Stimulus process
	stim_proc: process
	begin

--		for k in 0 to city_num-1 loop	-- To check the reset functionality or start the RNG module for every new path
		-- Hold reset state for the specified time
		reset <= '1', '0' after rst_period;
		wait until falling_edge(reset);
		wait for clk_period;
		wait until rising_edge(clk);
		for k in 0 to city_num-1 loop	-- To check the functionality without resetting the whole module or the RNG module	

			wait for clk_period*10;
			ce <= '1';
			wait for clk_period;
			fitss_in <= ram_tour (k);
			
			for j in 1 to conv_integer (iters_in) loop
				for i in 0 to 1 loop
					-- Dual read sets from the bee
					wait until falling_edge(next_data);
					data1_in <= ram_indx (k*city_num + conv_integer (data1_out));
					data2_in <= ram_indx (k*city_num + conv_integer (data2_out));
					wait for clk_period;
					done_bee <= '1';
					wait for clk_period;
					done_bee <= '0';
				end loop;
			end loop;
			
			wait until rising_edge(done);
			wait for clk_period;
			ce <= '0';
		end loop;

		wait;
	end process;
	
end;
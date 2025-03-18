----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_Neighbor_Tour_TB
-- Module Name      : Gen_Nearest_Neighbor_Tour_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core that determines the nearest neighbor tour for the TSP
-- Comments         : UUT => Gen_Nearest_Neighbor_Tour
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
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Gen_Nearest_Neighbor_Tour_TB is
end Gen_Nearest_Neighbor_Tour_TB;
 
architecture Behavioral of Gen_Nearest_Neighbor_Tour_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant tour_width : integer := 32;

	-- Component Declaration for the Unit Under Test (UUT)
   component Gen_Nearest_Neighbor_Tour
--		generic (
--					INDX_WIDTH  : integer := 8;
--					ADDR_WIDTH  : integer := 11;
--					TOUR_WIDTH  : integer := 32);
		port    (
					CLK         : in  std_logic;
					RESET       : in  std_logic;
					CE          : in  std_logic;
					NEXT_TOUR   : in  std_logic;
					SEND_TOUR   : in  std_logic;
					CITIES      : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					TOUR        : out std_logic_vector (INDX_WIDTH-1 downto 0);
					INDX        : out std_logic_vector (INDX_WIDTH-1 downto 0);
					TOUR_LENGTH : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					DONE        : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**indx_width-1 := 51;
	constant zero_indx  : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	constant zero_tour  : std_logic_vector (tour_width-1 downto 0) := (others => '0');

	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal next_tour    : std_logic := '0';
	signal send_tour    : std_logic := '0';
	signal cities       : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	
	-- Output signals
	signal tour         : std_logic_vector(indx_width-1 downto 0);
	signal indx         : std_logic_vector(indx_width-1 downto 0);
	signal tour_length  : std_logic_vector(tour_width-1 downto 0);
	signal done         : std_logic;
	
   -- Expected signals
	signal exp_tour     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal exp_tour_len : std_logic_vector (tour_width-1 downto 0) := (others => '0');
	
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
	uut: Gen_Nearest_Neighbor_Tour 
--		generic map (
--						INDX_WIDTH  => indx_width,
--						ADDR_WIDTH  => addr_width,
--						TOUR_WIDTH  => tour_width)
		port map    (
						CLK         => clk,
						RESET       => reset,
						CE          => ce,
						NEXT_TOUR   => next_tour,
						SEND_TOUR   => send_tour,
						CITIES      => cities,
						TOUR        => tour,
						INDX        => indx,
						TOUR_LENGTH => tour_length,
						DONE        => done);
	
	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Stimulus process
	stim_proc: process
	begin
	
		for k in 0 to 1 loop -- The loop to check the reset functionality
			
			-- Hold reset state for the specified time
			reset <= '1', '0' after rst_period;
			wait until falling_edge(reset);
			wait for clk_period;
			wait until rising_edge(clk);
			
			-- Enabling the core
			ce <= '1';
			wait for clk_period;
			
			for j in 0 to city_num-1 loop -- The loop to check all the nearest neighbor tours
				
				-- Tour Request (A single nearest neighbor tour)
				next_tour <= '1';
				wait for clk_period;
				next_tour <= '0';
				wait until rising_edge(done);
				wait for clk_period;
				
				-- Demonstrate the constructed tour on outputs
				send_tour <= '1';
				wait for clk_period;
				send_tour <= '0';
				
				-- Expected Output
				wait for clk_period;
				wait until falling_edge(clk);
				exp_tour_len <= ram_tour (j);
				for i in 0 to city_num-1 loop
					exp_tour <= ram_indx (i + city_num*j);
					wait for clk_period;
				end loop;
				wait until falling_edge(done);
				exp_tour_len <= (others => '0');
				exp_tour     <= (others => '0');
			
			end loop;
			
			-- Disabling the core
			ce <= '0';
			
		end loop;
	
		wait;
	end process;
	
	---------- Report processes ----------

	rpt_out1 : process (exp_tour)
	begin
		if (tour /= exp_tour and exp_tour /= zero_indx and time(now) > rst_period) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" Tour: An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" Tour: An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out1;
	
	rpt_out2 : process (exp_tour_len)
	begin
		if (tour_length /= exp_tour_len and tour_length /= zero_tour and time(now) > rst_period) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" Tour Length: An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" Tour Length: An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out2;

end;
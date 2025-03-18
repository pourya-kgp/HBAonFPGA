----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Euclidean_Distance_TB
-- Module Name      : Gen_Euclidean_Distance_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core calculating the Euclidean distance between two points on the 2D page
-- Comments         : UUT => Gen_Euclidean_Distance
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/10
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Gen_Euclidean_Distance_TB is
end Gen_Euclidean_Distance_TB;

architecture Behavioral of Gen_Euclidean_Distance_TB is

	-- Generic Constants
	constant data_width : integer := 24;
	constant dist_width : integer := 32;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Euclidean_Distance
--	generic  (
--				DATA_WIDTH : integer := 24;
--				DIST_WIDTH : integer := 32);
	port     (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				DATA_X1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_X2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_Y1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_Y2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				E_DIST     : out std_logic_vector (DIST_WIDTH-1 downto 0);
				DONE       : out std_logic);
    end component;
	
	-- Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant city_num   : integer := 51;

	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal data_x1      : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data_x2      : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data_y1      : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal data_y2      : std_logic_vector (data_width-1 downto 0) := (others => '0');

	-- Output signals
	signal e_dist       : std_logic_vector (dist_width-1 downto 0) := (others => '1');
	signal done         : std_logic;

	-- Expected signals
	signal exp_dist     : std_logic_vector (dist_width-1 downto 0) := (others => '1');

	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

	---------- Functions ----------

	-- Function: read_file (This function reads a text file consisting of the X/Y coordinates of a database and stores it in a 1D array)
	type ram_type_data is array (0 to 2**indx_width-1) of std_logic_vector (data_width-1 downto 0);
	
	impure function read_file (txt_file: in string ) return ram_type_data is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (data_width-1 downto 0);
		variable txt_ram  : ram_type_data ;
	begin
		for i in ram_type_data'range loop
			readline (ram_file , txt_line);
			read (txt_line , txt_bit);
			txt_ram (i) := to_stdlogicvector (txt_bit);
		end loop;
		return txt_ram;
	end function;
	
	-- Function: read_file (This function reads a text file consisting of a distance matrix and stores it in a 1D array)
	type ram_type_dist is array (0 to 2**addr_width-1) of std_logic_vector (dist_width-1 downto 0);
	
	impure function read_file (txt_file: in string ) return ram_type_dist is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (dist_width-1 downto 0);
		variable txt_ram  : ram_type_dist ;
	begin
		for i in ram_type_dist'range loop
			readline (ram_file , txt_line);
			read (txt_line , txt_bit);
			txt_ram (i) := to_stdlogicvector (txt_bit);
		end loop;
		return txt_ram;
	end function;
	
	---------- RAMs ----------

	-- Read the text file and store it in a ram array
	signal ram_x    : ram_type_data := read_file ("RTL_TB/TSP/eil51/eil51X.txt");
	signal ram_y    : ram_type_data := read_file ("RTL_TB/TSP/eil51/eil51Y.txt");

	signal ram_dist : ram_type_dist := read_file ("RTL_TB/TSP/eil51/eil51Dist.txt");

begin	

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Euclidean_Distance
--		generic map (
--						DATA_WIDTH => data_width,
--						DIST_WIDTH => dist_width)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => CE,
						DATA_X1    => data_x1,
						DATA_X2    => data_x2,
						DATA_Y1    => data_y1,
						DATA_Y2    => data_y2,
						E_DIST     => e_dist,
						DONE       => DONE);
	
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
		
		for i in 1 to city_num-1 loop
			for j in 2 to city_num loop
				if (i < j) then
					data_x1 <= ram_x (i-1);
					data_x2 <= ram_x (j-1);
					data_y1 <= ram_y (i-1);
					data_y2 <= ram_y (j-1);
					exp_dist <= ram_dist ((i-1)*city_num + j - (i+1)*i/2);
					wait for clk_period;
					ce <= '1';
					wait until rising_edge(done);
					wait for clk_period;
					ce <= '0';
					-- after setting the ce to zero, 2 cycles last till the "rdy" output of the root square module falls to a low value
					wait for clk_period*2;
				end if;
			end loop;
		end loop;
		exp_dist <= (others => '1');
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (done)
	begin
		if (abs(e_dist - exp_dist) > 1 and done = '1' and time(now) > rst_period) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;

end;
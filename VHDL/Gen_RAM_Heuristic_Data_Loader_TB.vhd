----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_RAM_Heuristic_Data_Loader_TB
-- Module Name      : Gen_RAM_Heuristic_Data_Loader_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core loading an internal/external RAM with the distance matrix information
-- Comments         : UUT => Gen_RAM_Heuristic_Data_Loader
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2024/07/14
-- Revision Date    : 2024/07/14
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Gen_RAM_Heuristic_Data_Loader_TB is
end Gen_RAM_Heuristic_Data_Loader_TB;

architecture Behavioral of Gen_RAM_Heuristic_Data_Loader_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant drom_width : integer := 24;
	constant dist_width : integer := 32;

	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_RAM_Heuristic_Data_Loader
--		generic (
--					INDX_WIDTH : integer := 8;
--					ADDR_WIDTH : integer := 11;
--					DROM_WIDTH : integer := 24;
--					DIST_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DOUT       : out std_logic_vector (DIST_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer := 51;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal cities       : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	
	-- Output signals
	signal addr         : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal dout         : std_logic_vector (dist_width-1 downto 0) := (others => '1');
	signal done         : std_logic := '0';

	-- Expected signals
	signal exp_dist     : std_logic_vector (dist_width-1 downto 0) := (others => '1');

	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

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

	-- Read the text file and store it in a ram array
	signal ram_dist : ram_type_dist := read_file ("RTL_TB/TSP/eil51/eil51Dist.txt");

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_RAM_Heuristic_Data_Loader
--		generic map (
--						INDX_WIDTH => indx_width,
--						ADDR_WIDTH => addr_width,
--						DROM_WIDTH => drom_width,
--						DIST_WIDTH => dist_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						CITIES     => cities,
						ADDR       => addr,
						DOUT       => dout,
						DONE       => done);
	
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
		
		ce <= '1';
		wait until rising_edge(done);

		for i in 1 to city_num-1 loop
			for j in 2 to city_num loop
				if (i < j) then
					wait for clk_period;
					addr <= conv_std_logic_vector ((i-1)*city_num + j - (i+1)*i/2 , addr_width);
					wait for clk_period;
					exp_dist <= ram_dist ((i-1)*city_num + j - (i+1)*i/2);
				end if;
			end loop;
		end loop;

		ce <= '0';
		wait for clk_period;
		exp_dist <= (others => '1');
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (dout)
	begin
		if (abs(dout - exp_dist) > 1) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;
	
end;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : TSP_Dist_One_Port_ROM_Sync_TB
-- Module Name      : TSP_Dist_One_Port_ROM_Sync_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for single-port ROM with synchronous read (Block RAM)
-- Comments         : UUT => eil51 Database Distance matrix
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2024/04/24
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity TSP_Dist_One_Port_ROM_Sync_TB is
end TSP_Dist_One_Port_ROM_Sync_TB;

architecture Behavioral of TSP_Dist_One_Port_ROM_Sync_TB is
	
	-- Generic Constants
	constant addr_width : integer := 11;
	constant data_width : integer := 32;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component TSP_Dist_One_Port_ROM_Sync
--		generic (
--					ADDR_WIDTH : integer := 11;
--					DATA_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal addr         : std_logic_vector (addr_width-1 downto 0) := (others => '0');

	-- Output signals
	signal data         : std_logic_vector (data_width-1 downto 0) := X"FFFF_FFFF";
	
	-- Expected signals
	signal exp_addr     : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal exp_data     : std_logic_vector (data_width-1 downto 0) := X"FFFF_FFFF";
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- Function: read_file (This function reads a text file consisting of a distance matrix and stores it in a 1D array)
	type ram_type is array (0 to 2**addr_width-1) of std_logic_vector (data_width-1 downto 0);
	
	impure function read_file (txt_file: in string ) return ram_type is
		file ram_file     : text open read_mode is txt_file;
		variable txt_line : line;
		variable txt_bit  : bit_vector (data_width-1 downto 0);
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
	signal ram : ram_type := read_file ("RTL_TB/TSP/eil51/eil51Dist.txt");

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: TSP_Dist_One_Port_ROM_Sync
--		generic map (
--						ADDR_WIDTH => addr_width,
--						DATA_WIDTH => data_width)
		port map    (
						CLK        => clk,
						ADDR       => addr,
						DATA       => data);

	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Stimulus process
	stim_proc: process
	begin
		wait until rising_edge(clk);
		
		for i in ram_type'range loop
			addr <= conv_std_logic_vector (i , addr_width); -- Stimulus
			wait until rising_edge(clk);
			exp_addr <= addr;                               -- Expected
			exp_data <= ram(i);                             -- Expected
		end loop;
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (data)
	begin
		if (data /= exp_data) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;

end Behavioral;
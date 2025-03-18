----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Xilinx_Dual_Port_RAM_TB
-- Module Name      : Xilinx_Dual_Port_RAM_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for dual-port RAM with synchronous/asynchronous read (Distributed RAM)
-- Comments         : UUT => Xilinx_Dual_Port_RAM_Sync / Xilinx_Dual_Port_RAM_Async
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2024/05/01
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Xilinx_Dual_Port_RAM_TB is
end Xilinx_Dual_Port_RAM_TB;

architecture Behavioral of Xilinx_Dual_Port_RAM_TB is

	-- Generic Constants
	constant addr_width : integer := 8;
	constant data_width : integer := 8;

	-- Component Declaration for the Unit Under Test (UUT)
	component Xilinx_Dual_Port_RAM_Sync -- Xilinx_Dual_Port_RAM_Sync / Xilinx_Dual_Port_RAM_Async
--		generic (
--					ADDR_WIDTH : integer := 8;
--					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					WE         : in  std_logic;
					ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA_W     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal we           : std_logic := '0';
	signal addr_a       : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal addr_b       : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal data_w       : std_logic_vector (data_width-1 downto 0) := (others => '0');

	-- Output signals
	signal dout_a       : std_logic_vector (data_width-1 downto 0) := (others => '1');
	signal dout_b       : std_logic_vector (data_width-1 downto 0) := (others => '1');
	
	-- Expected signals
	signal exp_dout_b   : std_logic_vector (data_width-1 downto 0) := (others => '1');
	
	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Clock
	
	-- WE period definitions
	constant we_period  : time := clk_period;

	-- Function: read_file (This function reads a text file and stores it in a 1D array)
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
	signal ram : ram_type := read_file ("RTL_TB/RXM/ram.txt");

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Xilinx_Dual_Port_RAM_Sync -- Xilinx_Dual_Port_RAM_Sync / Xilinx_Dual_Port_RAM_Async
--		generic map (
--						ADDR_WIDTH => addr_width,
--						DATA_WIDTH => data_width)
		port map    (
						CLK        => clk,
						WE         => we,
						ADDR_A     => addr_a,
						ADDR_B     => addr_b,
						DATA_W     => data_w,
						DOUT_A     => dout_a,
						DOUT_B     => dout_b);

	-- Clock process
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	stim_proc: process
	begin
		wait until rising_edge(clk);
		wait for clk_period;
		
		for i in ram_type'range loop
			addr_a     <= conv_std_logic_vector (i , addr_width); -- Stimulus
--			data_w     <= conv_std_logic_vector (i , addr_width); -- Stimulus (1)
			data_w     <= ram(i);                                 -- Stimulus (2)
			we <= '1';
			wait for we_period;
			we <= '0';
			wait for we_period;
			addr_b     <= conv_std_logic_vector (i , addr_width); -- Stimulus
--			exp_dout_b <= conv_std_logic_vector (i , addr_width); -- Expected (1)
			exp_dout_b <= ram(i);                                 -- Expected (2)
		end loop;
		
		wait;
	end process;
	
	-- Report process
	rpt_out : process (dout_b)
	begin
		if (dout_b /= exp_dout_b) then
--			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;

end Behavioral;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_HBA_TB
-- Module Name      : Gen_HBA_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core of Hardware Bee Algorithm which solves the TSP
-- Comments         : UUT => Gen_HBA
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/06
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
 
entity Gen_HBA_TB is
end Gen_HBA_TB;

architecture Behavioral of Gen_HBA_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 11;
	constant tour_width : integer := 32;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_HBA
--		generic (
--					INDX_WIDTH  : integer := 8;
--					ADDR_WIDTH  : integer := 11;
--					TOUR_WIDTH  : integer := 32);
		port    (
					CLK         : in  std_logic;
					RESET       : in  std_logic;
					CE          : in  std_logic;
					TOUR        : out std_logic_vector (INDX_WIDTH-1 downto 0);
					TOUR_LENGTH : out std_logic_vector (TOUR_WIDTH-1 downto 0); 
					DONE        : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**indx_width-1 := 51;

	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	
	-- Output signals
	signal tour         : std_logic_vector (indx_width-1 downto 0);
	signal tour_length  : std_logic_vector (tour_width-1 downto 0);
	signal done         : std_logic;
	
	-- Clock period definitions
	constant clk_period : time := 9 ns; -- 111 MHz Clock
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;

begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_HBA
--		generic map (
--						INDX_WIDTH  => indx_width,
--						ADDR_WIDTH  => addr_width,
--						TOUR_WIDTH  => tour_width)
		port map    (
						CLK         => clk,
						RESET       => reset,
						CE          => ce,
						TOUR        => tour,
						TOUR_LENGTH => tour_length,
						DONE        => done);

   -- Clock
	clk <= not(clk) after clk_period/2;
	
	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period;
	
	-- Stimulus process
	stim_proc: process
	begin
		wait until falling_edge(reset);
		wait for clk_period;
		wait until rising_edge(clk);
		
		ce <= '1';
		
		wait;
	end process;

	---------- Reports & Outputs ----------

	-- Output text process
	txt_out : process (clk)
		variable line_o : line;
		variable i      : integer range 0 to 2**indx_width-1 := 0;
	begin
		
		if (falling_edge(clk)) then
			if (tour > X"00") then
				i := i + 1;
				if (i = 1) then
					write (line_o , string'("Time: "));
					write (line_o , time'image(now) , right , 10);
					write (line_o , string'(" ==> "));
					write (line_o , string'("Tour = [ "));
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" "));
				elsif (i = city_num) then
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" ] , Tour Length = "));
					write (line_o , conv_integer (tour_length));
					writeline (output , line_o); -- The differences between the two write processes
					i := 0;
				else
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" "));
				end if;
			end if;
		end if;
		
	end process txt_out;
	
	-- Write to the File process
	file_out : process (clk)
		file file_handler : text open write_mode is "Report.txt"; -- The differences between the two write processes
		variable line_o   : line;
		variable i        : integer range 0 to 2**indx_width-1 := 0;
	begin

		if (falling_edge(clk)) then
			if (tour > X"00") then
				i := i + 1;
				if (i = 1) then
					write (line_o , string'("Time: "));
					write (line_o , time'image(now) , right , 13);
					write (line_o , string'(" ==> "));
					write (line_o , string'("Tour = [ "));
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" "));
				elsif (i = city_num) then
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" ] , Tour Length = "));
					write (line_o , conv_integer (tour_length));
					writeline (file_handler , line_o); -- The differences between the two write processes
					i := 0;
				else
					write (line_o , conv_integer (tour) , left , 3);
					write (line_o , string'(" "));
				end if;
			end if;
		end if;
	
	end process;

end;
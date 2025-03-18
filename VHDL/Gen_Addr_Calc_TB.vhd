----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Addr_Calc_TB
-- Module Name      : Gen_Addr_Calc_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core that calculates the address of two cities' distance in the ROM
-- Comments         : UUT => Gen_Addr_Calc (Gen_Addr_Formula)
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/04/24
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Gen_Addr_Calc_TB is
end Gen_Addr_Calc_TB;

architecture Behavioral of Gen_Addr_Calc_TB is

	-- Generic Constants
	constant data_width : integer := 8;
	constant addr_width : integer := 11;

	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Addr_Calc
--		generic (
--					DATA_WIDTH   : integer := 8;
--					ADDR_WIDTH   : integer := 11);
		port    (
					CLK          : in  std_logic;
					RESET        : in  std_logic;
					CE           : in  std_logic;
					CITIES       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CURRENT_CITY : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					NEXT_CITY    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					RAM_ADDR     : out std_logic_vector (ADDR_WIDTH-1 downto 0);
					DONE         : out std_logic);
	end component;
	
	-- Constants
	constant city_num   : integer range 0 to 2**data_width-1 := 51;
	
	-- Stimulus signals
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	signal ce           : std_logic := '0';
	signal cities       : std_logic_vector (data_width-1 downto 0) := conv_std_logic_vector (city_num , data_width);
	signal current_city : std_logic_vector (data_width-1 downto 0) := (others => '0');
	signal next_city    : std_logic_vector (data_width-1 downto 0) := (others => '0');

	-- Output signals
	signal ram_addr     : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal done         : std_logic := '0';

	-- Expected signals
	signal exp_ram_addr : std_logic_vector (addr_width-1 downto 0) := (others => '0');
	signal exp_done     : std_logic := '0';
	signal city_min     : integer range 0 to 2**data_width-1 := 1;
	signal city_max     : integer range 0 to 2**data_width-1 := 1;
	signal part1        : integer range 0 to 2**addr_width-1 := 0;
	signal part2        : integer range 0 to 2**addr_width-1 := 0;
	signal result       : integer range 0 to 2**addr_width-1 := 0;

	-- Clock period definitions
	constant clk_period : time := 10 ns; -- 100 MHz Cloch
	
	-- CE period definitions
	constant ce_period  : time := 20*clk_period; -- 5 clock pulse is needed to calculate the ram address 
	
	-- Reset period definitions
	constant rst_period : time := 10*clk_period;
	
	-- Report period definitions
	constant rpt_period : time := 52030*clk_period;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Addr_Calc 
--		generic map (
--						DATA_WIDTH    => data_width,
--						ADDR_WIDTH    => addr_width)
		port map    (
						CLK           => clk,
						RESET         => reset,
						CE            => ce,
						CITIES        => cities,
						CURRENT_CITY  => current_city,
						NEXT_CITY     => next_city,
						RAM_ADDR      => ram_addr,
						DONE          => done);

	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- CE process
	ce <= not(ce) after ce_period/2;

	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period;

	-- Stimulus process
	stim_proc: process
	begin
		wait until falling_edge(reset);
--		wait until rising_edge(clk);
		
		for i in 1 to city_num loop
			for j in 1 to city_num loop
				
				wait until rising_edge(ce);
				current_city <= conv_std_logic_vector (i , data_width);   -- Stimulus
				-- Preventing the case i = j to happen and specifying the minimum and maximum cities for formula calculation
				if (i /= j) then
					next_city <= conv_std_logic_vector (j   , data_width); -- Stimulus
					if (i<j) then
						city_min <= i;
						city_max <= j;
					else
						city_min <= j;
						city_max <= i;
					end if;
				else
					next_city <= conv_std_logic_vector (j+1 , data_width); -- Stimulus
					if (i<(j+1)) then
						city_min <= i;
						city_max <= j+1;
					else
						city_min <= j+1;
						city_max <= i;
					end if;
				end if;
				
				-- Expected ram address formula calculation
				-- Formula: (current_city-1)*cities + next_city - ((current_city+1)*current_city)/2
				-- part1  : (current_city-1)*cities + next_city
				-- part2  : ((current_city+1)*current_city)/2;
				-- result : part1 - part2
				wait for clk_period;
				part1 <= city_min - 1;
				part2 <= city_min + 1;
				wait for clk_period;
				
				part1 <= part1 * city_num;
				part2 <= part2 * city_min;
				wait for clk_period;
				
				part1 <= part1 + city_max;
				part2 <= part2 / 2;
				wait for clk_period;
				
				result <= part1 - part2;
				wait until rising_edge(done);
				
				exp_ram_addr <= conv_std_logic_vector (result , addr_width); -- Expected
				wait for clk_period;
				exp_done <= '1';                                             -- Expected
				wait until falling_edge(done);
				exp_ram_addr <= conv_std_logic_vector (0 , addr_width);      -- Expected
				exp_done <= '0';                                             -- Expected
			
			end loop;
		end loop;
		
		wait;
	end process stim_proc;

	-- Report process
	rpt_out : process (exp_done)
	begin
		if (rising_edge(exp_done) and time(now)<rpt_period) then -- Synchronizing the report with the rising edge of exp_done signal (expected output) and limiting the reports to a specified time
			if (ram_addr /= exp_ram_addr) then
--				report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
				assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--				assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
			end if;
		end if;
	end process rpt_out;
		
end Behavioral;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_City_TB
-- Module Name      : Gen_Nearest_City_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core that specifies and saves the nearest city from
--                    the current city in the nearest neighbor search
-- Comments         : UUT => Gen_Nearest_City
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/04/21
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity Ge_Nearest_City_TB is
end Ge_Nearest_City_TB;

architecture Behavioral of Ge_Nearest_City_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	constant dist_width : integer := 32;

	-- Component declaration for the Unit Under Test (UUT)
	component Gen_Nearest_City
--		generic (
--					INDX_WIDTH : integer := 8;
--					DIST_WIDTH : integer := 32);
		port    (
					CLK           : in    std_logic;
					RESET         : in    std_logic;
					NEXT_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					DIST_BETWEEN  : in    std_logic_vector (DIST_WIDTH-1 downto 0);
					NEAREST_IND   : inout std_logic_vector (INDX_WIDTH-1 downto 0);
					DIST_MIN      : inout std_logic_vector (DIST_WIDTH-1 downto 0));
   end component;

	-- Stimulus signals
	signal clk             : std_logic := '0';
	signal reset           : std_logic := '0';
	signal next_city_ind   : std_logic_vector (indx_width-1 downto 0)   := X"FF";
	signal dist_between    : std_logic_vector (dist_width-1 downto 0)   := X"FFFF_FFFF";
--	signal lfsr            : std_logic_vector (dist_width-1 downto 0)   := X"0000_0000"; -- 32 Bit LFSR (Initial value must be less than 7)
	signal lfsr            : std_logic_vector (dist_width/2-1 downto 0) := X"0000";      -- 16 Bit LFSR (Initial value must be less than 7)

	-- Output signals
	signal nearest_ind     : std_logic_vector (indx_width-1 downto 0);
	signal dist_min        : std_logic_vector (dist_width-1 downto 0);

	-- Expected signals
	signal exp_nearest_ind : std_logic_vector (indx_width-1 downto 0) := X"FF";
	signal exp_dist_min    : std_logic_vector (dist_width-1 downto 0) := X"FFFF_FFFF";

	-- Clock period definitions
	constant clk_period    : time := 10 ns; -- 100 MHz Clock

	-- Reset period definitions
	constant rst_period    : time := 10*clk_period; -- By changing the reset period, the beginning of the value assignment to the stimulus signals can be changed

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Nearest_City
--		generic map (
--						INDX_WIDTH    => indx_width,
--						DIST_WIDTH    => dist_width)
		port map    (
						CLK           => clk,
						RESET         => reset,
						NEXT_CITY_IND => next_city_ind,
						DIST_BETWEEN  => dist_between,
						NEAREST_IND   => nearest_ind,
						DIST_MIN      => dist_min);

	-- Clock process
	clk <= not(clk) after clk_period/2;

	-- Hold reset state for the specified time
	reset <= '1', '0' after rst_period;
	
	-- Stimulus process
	stim_proc: process
	begin
		for i in 0 to 2**8-1 loop 

			wait until rising_edge(clk); -- Wait for the rising edge of the clock
--			lfsr <= lfsr(dist_width-2 downto 0) & (lfsr(0) xnor lfsr(1) xnor lfsr(21) xnor lfsr(31));    -- 32 bit LFSR
			lfsr <= lfsr(dist_width/2-2 downto 0) & (lfsr(3) xnor lfsr(12) xnor lfsr(14) xnor lfsr(15)); -- 16 bit LFSR
			
			if (time(now) > rst_period) then
				next_city_ind <= conv_std_logic_vector (i,8); -- Stimulus
--				dist_between  <= lfsr;                        -- Stimulus (32 Bit LFSR)
				dist_between  <= X"0000" & lfsr;              -- Stimulus (16 Bit LFSR)
				
				if (dist_between < exp_dist_min) then
					exp_nearest_ind <= next_city_ind;          -- Expected
					exp_dist_min    <= dist_between;           -- Expected
				end if;
			end if;

		end loop;
	end process stim_proc;
	
	-- Report process
	rpt_out : process (nearest_ind , dist_min)
	begin
		if (nearest_ind /= exp_nearest_ind or dist_min /= exp_dist_min) then
			report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
			assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--			assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
		end if;
	end process rpt_out;
	
	-- Output text process
	txt_out : process (nearest_ind , dist_min)
		variable line_o : line;
	begin
		
		write (line_o , time'image(now));                write (line_o , string'(" ==> "));
		write (line_o , string'("next_city_ind="));      write (line_o , conv_integer (next_city_ind));   -- Stimulus
		write (line_o , string'(" , nearest_ind="));     write (line_o , conv_integer (nearest_ind));     -- Stimulus
		write (line_o , string'(" , dist_between="));    write (line_o , conv_integer (dist_between));    -- Output
		write (line_o , string'(" , dist_min="));        write (line_o , conv_integer (dist_min));        -- Output
		write (line_o , string'(" , exp_nearest_ind=")); write (line_o , conv_integer (exp_nearest_ind)); -- Expected
		write (line_o , string'(" , exp_dist_min="));    write (line_o , conv_integer (exp_dist_min));    -- Expected
		writeline (output , line_o);

	end process txt_out;

end Behavioral;
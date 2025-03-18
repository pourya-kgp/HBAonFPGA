----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Tour_TB
-- Module Name      : Gen_Tour_TB
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Test bench for the generic core to hold the path of TSP and make changes to it
-- Comments         : UUT => Gen_Tour_Async / Gen_Tour_Sync
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/19
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Gen_Tour_TB is
end Gen_Tour_TB;

architecture Behavioral of Gen_Tour_TB is

	-- Generic Constants
	constant indx_width : integer := 8;
	
	-- Component Declaration for the Unit Under Test (UUT)
	component Gen_Tour_Sync -- Gen_Tour_Async / Gen_Tour_Sync
--		generic (
--					INDX_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					SEL        : in  std_logic_vector (1 downto 0);
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FIRST_IND  : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					SECND_IND  : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FIRST_CITY : out std_logic_vector (INDX_WIDTH-1 downto 0);
					SECND_CITY : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;
	
	-- Constants
	constant city_num     : integer range 0 to 2**indx_width-1 := 51;
	
	-- Stimulus signals
	signal clk            : std_logic := '0';
	signal reset          : std_logic := '0';
	signal ce             : std_logic := '0';
	signal sel            : std_logic_vector (1 downto 0)            := (others => '0');
	signal cities         : std_logic_vector (indx_width-1 downto 0) := conv_std_logic_vector (city_num , indx_width);
	signal first_ind      : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal secnd_ind      : std_logic_vector (indx_width-1 downto 0) := (others => '0');

	-- Output signals
	signal first_city     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal secnd_city     : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal done           : std_logic := '0';
	
	-- Expected signals
	signal exp_first_city : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	signal exp_secnd_city : std_logic_vector (indx_width-1 downto 0) := (others => '0');
	
	-- Clock period definitions
	constant clk_period   : time := 10 ns; -- 100 MHz Clock
	
	-- Reset period definitions
	constant rst_period   : time := 10*clk_period;
		
	-- CE period definitions
	constant ce_period    : time := clk_period;
	
begin

	-- Instantiate the Unit Under Test (UUT)
	uut: Gen_Tour_Sync -- Gen_Tour_Async / Gen_Tour_Sync
--		generic map (
--						INDX_WIDTH => indx_width)
		port map    (
						CLK        => clk,
						RESET      => reset,
						CE         => ce,
						SEL        => sel,
						CITIES     => cities,
						FIRST_IND  => first_ind,
						SECND_IND  => secnd_ind,
						FIRST_CITY => first_city,
						SECND_CITY => secnd_city,
						DONE       => done);

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
		
		for j in 0 to city_num-1 loop
			
			-- Sort
			sel <= "00";                                                      -- Stimulus
			ce <= '1';                                                        -- Stimulus
			wait for ce_period;
			ce <= '0';                                                        -- Stimulus
			wait until falling_edge(done); -- Duration: (city_num+3)*clk_period
			
			-- Dual_Read
			sel <= "10";                                                      -- Stimulus
			first_ind <= conv_std_logic_vector (0 , indx_width);              -- Stimulus
			secnd_ind <= conv_std_logic_vector (j , indx_width);              -- Stimulus
			ce <= '1';                                                        -- Stimulus
			wait for ce_period;
			ce <= '0';                                                        -- Stimulus
			exp_first_city <= conv_std_logic_vector (1   , indx_width);       -- Expected
			exp_secnd_city <= conv_std_logic_vector (j+1 , indx_width);       -- Expected
			wait until falling_edge(done); -- Duration: 3*clk_period
			exp_first_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			exp_secnd_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			
			-- Exchange
			sel <= "01";                                                      -- Stimulus
			first_ind <= conv_std_logic_vector (0 , indx_width);              -- Stimulus
			secnd_ind <= conv_std_logic_vector (j , indx_width);              -- Stimulus
			ce <= '1';                                                        -- Stimulus
			wait for ce_period;
			ce <= '0';                                                        -- Stimulus
			wait until falling_edge(done); -- Duration: 3*clk_period
			
			-- Dual_Read
			sel <= "10";                                                      -- Stimulus
			first_ind <= conv_std_logic_vector (0 , indx_width);              -- Stimulus
			secnd_ind <= conv_std_logic_vector (j , indx_width);              -- Stimulus
			ce <= '1';                                                        -- Stimulus
			wait for ce_period;
			ce <= '0';                                                        -- Stimulus
			exp_first_city <= conv_std_logic_vector (j+1 , indx_width);       -- Expected
			exp_secnd_city <= conv_std_logic_vector (1   , indx_width);       -- Expected
			wait until falling_edge(done); -- Duration: 3*clk_period
			exp_first_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			exp_secnd_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			
			-- Single_Read
			sel <= "11";                                                      -- Stimulus
			ce <= '1';                                                        -- Stimulus
			wait for ce_period;
			ce <= '0';                                                        -- Stimulus
			wait for clk_period;
			exp_first_city <= conv_std_logic_vector (j+1 , indx_width);       -- Expected
			exp_secnd_city <= conv_std_logic_vector (0   , indx_width);       -- Expected
			wait for clk_period;
			for i in 1 to city_num-1 loop
				if (i=j) then
					exp_first_city <= conv_std_logic_vector (1   , indx_width); -- Expected
				else
					exp_first_city <= conv_std_logic_vector (i+1 , indx_width); -- Expected
				end if;
				exp_secnd_city    <= conv_std_logic_vector (i   , indx_width); -- Expected
				wait for clk_period;
			end loop;
			exp_first_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			exp_secnd_city <= conv_std_logic_vector (0 , indx_width);         -- Expected
			wait until falling_edge(done); -- Duration: clk_period
			
		end loop;
		
		wait;
	end process stim_proc;
	
	-- Report process
	rpt_out : process (first_city , done)
	begin
		if (sel /= "11" and rising_edge(done)) then
			if (first_city /= exp_first_city or secnd_city /= exp_secnd_city) then
--				report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
				assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--				assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
			end if;
		elsif (sel = "11") then
			if (first_city /= exp_first_city or secnd_city /= exp_secnd_city) then
--				report time'image(now) & string'(" ==> The outputs and corresponding expected outputs do not match");
				assert false report string'(" An error is occured at ") & time'image(now) severity note;    -- Showing a note in case of an error
--				assert false report string'(" An error is occured at ") & time'image(now) severity failure; -- Halting the simulation in case of an error
			end if;
		end if;
	end process rpt_out;

end;
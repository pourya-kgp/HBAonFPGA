----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_RNG_City_Set
-- Module Name      : Gen_RNG_City_Set
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core for generating two pseudo-random city
-- Comments         : 
-- Dependencies     : Gen_LFSR
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 230 MHz
-- Area  Estimation : 107 LUTs + 49 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/23
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_RNG_City_Set is
	generic (
				DATA_WIDTH  : integer := 8);
	port    (
				CLK         : in  std_logic;
				RESET       : in  std_logic;
				CE          : in  std_logic;
				CITIES      : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				CITY_IND_R1 : out std_logic_vector (DATA_WIDTH-1 downto 0);
				CITY_IND_R2 : out std_logic_vector (DATA_WIDTH-1 downto 0);
				DONE        : out std_logic);
end Gen_RNG_City_Set;

architecture Moore_FSM of Gen_RNG_City_Set is	
	
	---------- Components ----------
	
	component Gen_LFSR is -- Gen_LFSR / Gen_LFSR_Old
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					CITIES     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					LFSR       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	-- LFSR Counter Module
	type LFSR_Ind is array (1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	
	signal LFSR_Out : LFSR_Ind                      := (others => (others => '0'));
	signal LFSR_CE  : std_logic_vector (1 downto 0) := (others => '0');
	
	-- State Machine & Control Signals
	type State is (Idle_Mode , Start , Stabilize_1 , LFSR_No_1 , Stabilize_0 , LFSR_No_0 , Dist_Calc , Lower_Range , Final);
	signal S_Curr, S_Next : State;
	
	signal Rnd1_Curr , Rnd1_Next : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Rnd2_Curr , Rnd2_Next : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Dist_Curr , Dist_Next : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	CITY_IND_R1 <= Rnd1_Curr;
	CITY_IND_R2 <= Rnd2_Curr;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr    <= Idle_Mode;
			Rnd1_Curr <= (others => '0');
			Rnd2_Curr <= (others => '0');	
		elsif (rising_edge(CLK)) then
			S_Curr    <= S_Next;
			Rnd1_Curr <= Rnd1_Next; -- First random city
			Rnd2_Curr <= Rnd2_Next; -- Second random city
			Dist_Curr <= Dist_Next; -- Distance between the two cities for checking the lower range criteria
		end if;
	end process;
	
	process (S_Curr , Rnd1_Curr , Rnd2_Curr , Dist_Curr , CE , CITIES , LFSR_Out)
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		Rnd1_Next <= Rnd1_Curr;
		Rnd2_Next <= Rnd2_Curr;
		Dist_Next <= Dist_Curr;

		-- Default assignments to prevent latches
		DONE <= '0';
		LFSR_CE <= (others => '0');
		
		case S_Curr is
			when Idle_Mode   =>
										if (CE = '1') then
											S_Next <= Start;
										else
											S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
										end if;
			
			when Start       =>
										LFSR_CE(1) <= '1'; -- Go to the next Random City (R2)
										S_Next <= Stabilize_1;
			
			when Stabilize_1 =>
										-- The LFSR_Out signal changes one clock pulse after setting the LFSR_CE signal
										S_Next <= LFSR_No_1;
			
			when LFSR_No_1   =>
										if (LFSR_Out(1) > CITIES-1) then 
											LFSR_CE(1) <= '1'; -- Go to the next Random City (R2)
											S_Next <= Stabilize_1;
										else
											S_Next <= LFSR_No_0;
										end if;
			
			when Stabilize_0 =>
										-- The LFSR_Out signal changes one clock pulse after setting the LFSR_CE signal
										S_Next <= LFSR_No_0;
			
			when LFSR_No_0   =>
										if (LFSR_Out(0) > CITIES-1) then
											LFSR_CE(0) <= '1'; -- Go to the next Random City (R1)
											S_Next <= Stabilize_0;
										elsif (LFSR_Out(1) = Zero) then -- The LFSR seed value must be 1
											LFSR_CE(0) <= '1'; -- Go to the next Random City (R1)
											S_Next <= Start;
										else
											S_Next <= Dist_Calc;
										end if;
			
			when Dist_Calc   =>
										if (LFSR_Out(0) < LFSR_Out(1)) then
											Dist_Next <= LFSR_Out(1) - LFSR_Out(0);
										else
											Dist_Next <= LFSR_Out(0) - LFSR_Out(1);
										end if;
										S_Next <= Lower_Range;
			
			when Lower_Range =>
										-- Two Random Cities must have at least 2 cities apart for 2_Opt
										if (conv_integer(Dist_Curr) >= 3) then
											if (LFSR_Out(0) < LFSR_Out(1)) then
												Rnd1_Next <= LFSR_Out(0);
												Rnd2_Next <= LFSR_Out(1);
											else
												Rnd1_Next <= LFSR_Out(1);
												Rnd2_Next <= LFSR_Out(0);
											end if;
											S_Next <= Final;
										else
											S_Next <= Start;
										end if;
			
			when Final       =>
										DONE <= '1'; -- Done output stays up till the next request
										if (CE = '1') then
											S_Next <= Start;
										else
											S_Next <= Final; -- Redundant, only for clarification purposes
										end if;
		end case;
	end process;
	
	---------- Instantiations ----------

	Generate_LFSR: for i in 0 to 1 generate
		LFSR: Gen_LFSR -- Gen_LFSR / Gen_LFSR_Old
			generic map (
							DATA_WIDTH => DATA_WIDTH)
			port map    (
							CLK        => CLK,
							RESET      => RESET,
							CE         => LFSR_CE(i),
							CITIES     => CITIES,
							LFSR       => LFSR_Out(i));
	end generate;

end Moore_FSM;
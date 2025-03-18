----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_Neighbor_Tour
-- Module Name      : Gen_Nearest_Neighbor_Tour
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core for determining the nearest neighbor tour for the TSP
-- Comments         : 
-- Dependencies     : 1 Core
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 135 MHz
-- Area  Estimation : 622 LUTs + 217 FFs + 3 RAM/FIFO + 2 DSPs (eil51 Database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Gen_Nearest_Neighbor_Tour is
	generic (
				INDX_WIDTH  : integer := 8;
				ADDR_WIDTH  : integer := 11;
				TOUR_WIDTH  : integer := 32);
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
end Gen_Nearest_Neighbor_Tour;

architecture Moore_FSM of Gen_Nearest_Neighbor_Tour is

	---------- Components ----------
	
	component Gen_Nearest_Neighbor is
		generic (
					INDX_WIDTH     : integer := 8;
					ADDR_WIDTH     : integer := 11;
					TOUR_WIDTH     : integer := 32);
		port    (
					CLK            : in    std_logic;
					RESET          : in    std_logic;
					CE             : in    std_logic;
					CE_OPT         : in    std_logic;
					CE_CNT         : in    std_logic;
					SEL            : in    std_logic_vector (1 downto 0);
					CITIES         : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					FIRST_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					SECND_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
					DONE           : out   std_logic;
					TOUR           : out   std_logic_vector (INDX_WIDTH-1 downto 0);
					INDX           : out   std_logic_vector (INDX_WIDTH-1 downto 0);
					NEAREST_IND    : inout std_logic_vector (INDX_WIDTH-1 downto 0);
					DIST_MIN       : inout std_logic_vector (TOUR_WIDTH-1 downto 0);
					LAST_J         : inout std_logic;
					NEXT_I         : inout std_logic;
					LAST_I         : inout std_logic);
	end component;	
	
	---------- Signals ----------
	
	-- State Machine & Control Signals
	type State is (Idle_Mode , Start_Sort , Done_Sort , Start_Exchange_Tour , Done_Exchange_Tour ,
						Start_Dual_Read , Done_Dual_Read , Start_Exchange_City , Done_Exchange_City ,
						Accumulator , Start_Single_Read , Done_Single_Read , Final);
	signal S_Curr , S_Next : State;
	
	signal I_Curr , I_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal T_Curr , T_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal L_Curr , L_Next : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
	
	-- Nearest_Neighbor Module
	signal CE_NN , CE_Opt , CE_Cnt                       : std_logic := '0';
	signal Done_NN , Last_J , Next_I                     : std_logic := '0';
	signal Sel                                           : std_logic_vector (1 downto 0)            := "00";
	signal First_City_Ind , Secnd_City_Ind , Nearest_Ind : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Dist_Min                                      : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
			I_Curr <= (others => '0');
			L_Curr <= (others => '0');
			T_Curr <= (others => '0'); -- Extremely crucial
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next; -- State Signal
			I_Curr <= I_Next; -- City Counter (Very important, though it's not in the sensitivity list)
			L_Curr <= L_Next; -- Tour Lenght
			T_Curr <= T_Next; -- First City Counter
		end if;
	end process;
	
--	process (S_Curr , CE , NEXT_TOUR , SEND_TOUR , Done_NN) -- The main sensitivity list that matters
	process (S_Curr , I_Curr , L_Curr , T_Curr , CE , NEXT_TOUR , SEND_TOUR , CITIES , Done_NN , Nearest_Ind , Dist_Min)
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		I_Next <= I_Curr;
		L_Next <= L_Curr;
		T_Next <= T_Curr;

		-- Default assignments to prevent latches
		CE_NN  <= '1';
		CE_Opt <= '0'; -- One Puls Width
		CE_Cnt <= '0'; -- One Puls Width
		DONE   <= '0'; -- One Puls Width for Single_Read mode
		TOUR_LENGTH    <= (others => '0');
		First_City_Ind <= (others => '0');
		Secnd_City_Ind <= (others => '0');
		
		case S_Curr is
			when Idle_Mode           =>
													Sel <= "00"; -- Sort
													CE_NN <= '0';
													I_Next <= (others => '0');
													L_Next <= (others => '0');
													if (T_Curr = CITIES) then
														T_Next <= (others => '0');
													end if;
													if (CE = '1' and NEXT_TOUR = '1') then
														S_Next <= Start_Sort;
													else
														S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
													end if;
													
			when Start_Sort          =>
													Sel <= "00"; -- Sort
													CE_Opt <= '1';
													S_Next <= Done_Sort;
			
			when Done_Sort           =>
													Sel <= "00"; -- Sort
													if (Done_NN = '1') then
														S_Next <= Start_Exchange_Tour;
													else
														S_Next <= Done_Sort; -- Redundant, only for clarification purposes
													end if;
			
			when Start_Exchange_Tour =>
													Sel <= "01"; -- Exchange
													First_City_Ind <= (others => '0'); -- Redundant, only for clarification purposes
													Secnd_City_Ind <= T_Curr;
													CE_Opt <= '1';
													S_Next <= Done_Exchange_Tour;
			
			when Done_Exchange_Tour  =>
													Sel <= "01"; -- Exchange
													First_City_Ind <= (others => '0'); -- Redundant, only for clarification purposes
													Secnd_City_Ind <= T_Curr;
													if (Done_NN = '1') then
														S_Next <= Start_Dual_Read;
													else
														S_Next <= Done_Exchange_Tour; -- Redundant, only for clarification purposes
													end if;
			
			when Start_Dual_Read     =>
													Sel <= "10"; -- Dual_Read
													CE_Cnt <= '1';
													S_Next <= Done_Dual_Read;
			
			when Done_Dual_Read      =>
													Sel <= "10"; -- Dual_Read
													if (Done_NN = '1') then
														I_Next <= I_Curr + 1;
														if (I_Curr >= CITIES-2) then
															S_Next <= Accumulator;
														else
															S_Next <= Start_Exchange_City;
														end if;
													else
														S_Next <= Done_Dual_Read; -- Redundant, only for clarification purposes
													end if;
			
			when Start_Exchange_City =>
													Sel <= "01"; -- Exchange
													First_City_Ind <= I_Curr;
													Secnd_City_Ind <= Nearest_Ind;
													CE_Opt <= '1';
													S_Next <= Done_Exchange_City;
			
			when Done_Exchange_City  =>
													Sel <= "01"; -- Exchange
													First_City_Ind <= I_Curr;
													Secnd_City_Ind <= Nearest_Ind;
													if (Done_NN = '1') then
														S_Next <= Accumulator;
													else
														S_Next <= Done_Exchange_City; -- Redundant, only for clarification purposes
													end if;
			
			when Accumulator         =>
													Sel <= "10"; -- Dual_Read
													L_Next <= L_Curr + Dist_Min;
													if (I_Curr < CITIES) then
														S_Next <= Start_Dual_Read;
													else
														S_Next <= Start_Single_Read;
													end if;
			
			when Start_Single_Read   =>
													Sel  <= "11"; -- Single_Read
													DONE <= '1';  -- It's One as Long as Send Tour request (Single_Read mode)
													if (SEND_TOUR = '1') then 
														CE_Opt <= '1'; -- Put the data on output ports after 2 clock pulse (Tour Module)
														S_Next <= Done_Single_Read;
													else
														S_Next <= Start_Single_Read; -- Redundant, only for clarification purposes
													end if;
			
			when Done_Single_Read    =>
													Sel  <= "11"; -- Single_Read
													TOUR_LENGTH <= L_Curr;
													if (Done_NN = '1') then
														T_Next <= T_Curr + 1;
														S_Next <= final;
													else
														S_Next <= Done_Single_Read; -- Redundant, only for clarification purposes
													end if;
			
			when Final               =>
													Sel  <= "11"; -- Single_Read
													DONE <= '1';
													S_Next <= Idle_Mode;
		end case;
	end process;

	---------- Instantiations ----------

	Nearest_Neighbor: Gen_Nearest_Neighbor
		generic map (
						INDX_WIDTH     => INDX_WIDTH,
						ADDR_WIDTH     => ADDR_WIDTH,
						TOUR_WIDTH     => TOUR_WIDTH)
		port map    (
						CLK            => CLK,
						RESET          => RESET,
						CE             => CE_NN,  -- Counter Module Chip Enable
						CE_OPT         => CE_Opt, -- Tour Module Chip Enable
						CE_CNT         => CE_Cnt, -- Next J in Counter Module
						SEL            => Sel,    -- Tour Module Mode Selection (Sort, Exchange, Dual_Real, Single Read)
						CITIES         => CITIES,
						FIRST_CITY_IND => First_City_Ind,
						SECND_CITY_IND => Secnd_City_Ind,
						DONE           => Done_NN,
						TOUR           => TOUR,
						INDX           => INDX,
						NEAREST_IND    => Nearest_Ind,
						DIST_MIN       => Dist_Min,
						LAST_J         => Last_J,
						NEXT_I         => Next_I,
						LAST_I         => open);

end Moore_FSM;
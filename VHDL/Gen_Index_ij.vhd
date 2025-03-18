----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Index_ij
-- Module Name      : Gen_Index_ij
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core for sequentially selecting two RAM addresses
-- Comments         : 
-- Dependencies     : 6 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 511 MHz
-- Area  Estimation : 46 LUTs + 18 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/05
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Index_ij is
	generic (
				DATA_WIDTH       : integer := 8);
	port    (
				CLK              : in  std_logic;
				RESET            : in  std_logic;
				CE               : in  std_logic;
				NEXT_J           : in  std_logic;
				CITIES           : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				LAST_J           : out std_logic;
				NEXT_I           : out std_logic;
				LAST_I           : out std_logic;
				ENABLE_OUT       : out std_logic;
				CURRENT_CITY_IND : out std_logic_vector (DATA_WIDTH-1 downto 0);
				NEXT_CITY_IND    : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_Index_ij;

architecture Structural of Gen_Index_ij is

	---------- Components ----------
	
	component Gen_CNT is
		generic (
					DIGIT : integer := 8);
		port    (
					CLK   : in  std_logic;
					CE    : in  std_logic;
					ACLR  : in  std_logic;
					Q     : out std_logic_vector (DIGIT-1 downto 0));
	end component;
	
	component Gen_Comp_eq is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					EQ         : out std_logic);
	end component;
	
	component Gen_Comp_Less is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					MIN        : out std_logic_vector (DATA_WIDTH-1 downto 0);
					AgB        : out std_logic);
	end component;
	
	component Bit_Mux2_1 is
		port (
				S  : in  std_logic;
				D0 : in  std_logic;
				D1 : in  std_logic;
				O  : out std_logic);
	end component;
	
	component Edge_Detector is
		port (
				CLK    : in  std_logic;
				RESET  : in  std_logic;
				EDGE   : in  std_logic;
				DETECT : out std_logic);
	end component;

	component Bit_Flipflop_D_Async is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic);
	end component;
	
	---------- Signals ----------
	
	signal Cnt_In      : std_logic := '0'; -- The signal between the Multiplexer output and the counter clock input
	signal Cnt_CE      : std_logic := '0'; -- First counter's CE signal (CNT1), which is made synchronous with the NEXT_J input
	signal Aclr1       : std_logic := '0'; -- Asynchronous Clear of the first counter corresponding to NEXT_CITY_IND
	signal Aclr2       : std_logic := '0'; -- Asynchronous Clear of the first counter corresponding to CURRENT_CITY_IND
	signal Aclr3       : std_logic := '0'; -- Asynchronous Clear of the D Flip-Flop
	signal Nxt_I       : std_logic := '0'; -- The output of the first  parity comparison module (Eq1), which is connected to the clock input of the first counter (CNT1)
	signal End_I       : std_logic := '0'; -- The output of the second parity comparison module (Eq2), which is connected to the OR gate connected to the second counter (CNT2)
	signal Lst_J       : std_logic := '0'; -- The output of the third  parity comparison module (Eq3), which is connected directly to the NEXT_J output
	signal Lst_I       : std_logic := '0'; -- The output of the fourth parity comparison module (Eq4), which is connected directly to the LAST_I output
	signal Mux_Sel     : std_logic := '0'; -- Multiplexer select input
	signal Enable      : std_logic := '0'; -- Quantitative comparison module output (Less)
	signal Enable_Edge : std_logic := '0'; -- Edge detection module output
	signal Current_Ind : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0'); -- Connected directly to CURRENT_CITY_IND output
	signal Next_Ind    : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0'); -- Connected directly to NEXT_CITY_IND output
	
	signal Cities_Sub1 : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0'); -- Constant (Cities -1)
	
begin
	
	Cities_Sub1 <= CITIES - 1;
	
	LAST_I <= Lst_I;
	LAST_J <= Lst_J;
	
	CURRENT_CITY_IND <= Current_Ind;
	NEXT_CITY_IND    <= Next_Ind;
	
	Aclr1 <= RESET or Nxt_I;
	Aclr2 <= RESET or End_I;
	Aclr3 <= RESET or not (NEXT_J);
	
	Mux_Sel <= Enable or (Lst_J and Lst_I);
	
	ENABLE_OUT <= Enable_Edge or (Enable and NEXT_J);
	
	---------- Instantiations ----------
	
	CNT1: Gen_CNT
		generic map (
						DIGIT => DATA_WIDTH)
		port map    (
						CLK   => Cnt_In,
						CE    => Cnt_CE,
						ACLR  => Aclr1,
						Q     => Next_Ind);
	
	CNT2: Gen_CNT
		generic map (
						DIGIT => DATA_WIDTH)
		port map    (
						CLK   => Nxt_I,
						CE    => CE,
						ACLR  => Aclr2,
						Q     => Current_Ind);
	
	Eq1: Gen_Comp_eq
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => Next_Ind,
						B          => CITIES,
						EQ         => Nxt_I);
	
	Eq2: Gen_Comp_eq
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => Current_Ind,
						B          => Cities,
						EQ         => End_I);
	
	Eq3: Gen_Comp_eq
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => Next_Ind,
						B          => Cities_Sub1,
						EQ         => Lst_J);
	
	Eq4: Gen_Comp_eq
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => Current_Ind,
						B          => Cities_Sub1,
						EQ         => Lst_I);
	
	Less: Gen_Comp_Less
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => Next_Ind,
						B          => Current_Ind,
						MIN        => open,
						AgB        => Enable);
	
	B_Mux: Bit_Mux2_1
		port map (
					S  => Mux_Sel,
					D0 => CLK,
					D1 => NEXT_J,
					O  => Cnt_In);
	
	Edge_Detect: Edge_Detector
		port map (
					CLK    => CLK,
					RESET  => RESET,
					EDGE   => Enable,
					DETECT => Enable_Edge);
	
	D_FF_Next_I: Bit_Flipflop_D_Async
		port map (
					CLK   => Nxt_I,
					RESET => Aclr3,
					D_IN  => Nxt_I,
					D_OUT => NEXT_I);
	
	D_FF_Cnt1_CE: Bit_Flipflop_D_Async
		port map (
					CLK   => NEXT_J,
					RESET => RESET,
					D_IN  => CE,
					D_OUT => Cnt_CE);
		
end Structural;
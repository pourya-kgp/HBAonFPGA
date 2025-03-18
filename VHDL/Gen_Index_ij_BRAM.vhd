----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Index_ij_BRAM
-- Module Name      : Gen_Index_ij_BRAM
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core for sequentially selecting two RAM addresses
-- Comments         : 
-- Dependencies     : 5 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 511 MHz
-- Area  Estimation : 39 LUTs + 16 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/14
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Index_ij_BRAM is
	generic (
				DATA_WIDTH       : integer := 8);
	port    (
				CLK              : in    std_logic;
				RESET            : in    std_logic;
				CE               : in    std_logic;
				NEXT_DATA        : in    std_logic;
				CITIES           : in    std_logic_vector (DATA_WIDTH-1 downto 0);
				DONE             : out   std_logic;
				ENABLE_OUT       : inout std_logic;
				CURRENT_CITY_IND : inout std_logic_vector (DATA_WIDTH-1 downto 0);
				NEXT_CITY_IND    : inout std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_Index_ij_BRAM;

architecture Structural of Gen_Index_ij_BRAM is

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
	
	component Gen_Comp is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					MAX        : out std_logic_vector (DATA_WIDTH-1 downto 0);
					MIN        : out std_logic_vector (DATA_WIDTH-1 downto 0);
					AgB        : out std_logic;
					AeB        : out std_logic;
					AlB        : out std_logic);
	end component;
	
	component Bit_Mux2_1 is
		port (
				S  : in  std_logic;
				D0 : in  std_logic;
				D1 : in  std_logic;
				O  : out std_logic);
	end component;
	
	component Bit_Flipflop_D_Async is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic := '0');
	end component;
	
	---------- Signals ----------
	
	signal Cnt1_In : std_logic := '0';
	signal Next_I  : std_logic := '0';
	signal Last_I  : std_logic := '0';
	signal Aclr1   : std_logic := '0';
	signal Aclr2   : std_logic := '0';
	signal Is_I_0  : std_logic := '0';
	signal Is_J_0  : std_logic := '0';
	signal Mux_Sel : std_logic := '0';
	
	signal Cities_Sub1 : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	constant Zero_Indx : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin

	Cities_Sub1 <= CITIES - 1;

	Aclr1 <= Next_I or RESET;
	Aclr2 <= Last_I or RESET;
	
	Mux_Sel <= ENABLE_OUT or (Is_I_0 and Is_J_0);

	---------- Instantiations ----------

	CNT1 : Gen_CNT
		generic map (
						DIGIT => DATA_WIDTH)
		port map    (
						CLK   => Cnt1_In,
						CE    => CE,
						ACLR  => Aclr1,
						Q     => NEXT_CITY_IND);
						
	CNT2 : Gen_CNT
		generic map (
						DIGIT => DATA_WIDTH)
		port map    (
						CLK   => Next_I,
						CE    => CE,
						ACLR  => Aclr2,
						Q     => CURRENT_CITY_IND);

	Eq1 : Gen_Comp_eq
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => NEXT_CITY_IND,
						B          => CITIES,
						EQ         => Next_I);

	Eq2 : Gen_Comp_eq
		generic map ( 
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => CURRENT_CITY_IND,
						B          => Cities_Sub1,
						EQ         => Last_I);

	Eq_I_0 : Gen_Comp_eq
		generic map ( 
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => CURRENT_CITY_IND,
						B          => Zero_Indx,
						EQ         => Is_I_0);

	Eq_J_0 : Gen_Comp_eq
		generic map ( 
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => NEXT_CITY_IND,
						B          => Zero_Indx,
						EQ         => Is_J_0);

	Comp : Gen_Comp
		generic map ( 
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => NEXT_CITY_IND,
						B          => CURRENT_CITY_IND,
						MAX        => open,
						MIN        => open,
						AgB        => ENABLE_OUT,
						AeB        => open,
						AlB        => open);

	B_Mux: Bit_Mux2_1
		port map (
					S  => Mux_Sel,
					D0 => CLK,
					D1 => NEXT_DATA,
					O  => Cnt1_In);
	
	D_FF_Bit: Bit_Flipflop_D_Async
		port map (
					CLK   => Last_I,
					RESET => RESET,
					D_IN  => '1',
					D_OUT => DONE);
	
end Structural;
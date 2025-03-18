----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Index_ij_Structural
-- Module Name      : Gen_Index_ij_Structural
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core for sequentially selecting two RAM addresses + case LAST_I
-- Comments         : 
-- Dependencies     : 3 cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 511 MHz
-- Area  Estimation : 52 LUTs + 19 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/05
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Index_ij_Structural is
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
end Gen_Index_ij_Structural;

architecture Structural of Gen_Index_ij_Structural is

	---------- Components ----------
	
	component Gen_Index_ij is
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
	end component;

	component Gen_Mux2_1 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic;
					D0         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					O          : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component Bit_Mux2_1 is
		port (
				S  : in  std_logic;
				D0 : in  std_logic;
				D1 : in  std_logic;
				O  : out std_logic);
	end component;
	
	---------- Signals ----------
	
	signal Nxt_I    : std_logic := '0';
	signal Lst_I    : std_logic := '0';
	signal Lst_J    : std_logic := '0';
	signal Enable   : std_logic := '0';
	
	signal Next_Ind : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero   : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	NEXT_I <= Nxt_I;
	LAST_I <= Lst_I;
	
	---------- Instantiations ----------
	
	Index_ij: Gen_Index_ij
		generic map (
						DATA_WIDTH       => DATA_WIDTH)
		port map    (
						CLK              => CLK,
						RESET            => RESET,
						CE               => CE,
						NEXT_J           => NEXT_J,
						CITIES           => CITIES,
						LAST_J           => Lst_J,
						NEXT_I           => Nxt_I,
						LAST_I           => Lst_I,
						ENABLE_OUT       => Enable,
						NEXT_CITY_IND    => Next_Ind,
						CURRENT_CITY_IND => CURRENT_CITY_IND);

	Mux: Gen_Mux2_1
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						S          => Lst_I,
						D0         => Next_Ind,
						D1         => Zero,
						O          => NEXT_CITY_IND);
	
	B_Mux_Enable: Bit_Mux2_1
		port map (
					S  => Lst_I,
					D0 => Enable,
					D1 => Nxt_I,
					O  => ENABLE_OUT);
						
	B_Mux_LastJ: Bit_Mux2_1
		port map (
					S  => Lst_I,
					D0 => Lst_J,
					D1 => '1',
					O  => LAST_J);
					
end Structural;
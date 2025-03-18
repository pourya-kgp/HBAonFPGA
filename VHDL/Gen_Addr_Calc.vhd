----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Addr_Calc
-- Module Name      : Gen_Addr_Calc
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core to calculate the address of two cities' distance in the ROM (distance matrix)
-- Comments         : 
-- Dependencies     : 2 cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 199 MHz
-- Area  Estimation : 104 LUTs + 53 FFs + 2 DSPs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Addr_Calc is
	generic (
				DATA_WIDTH   : integer := 8;
				ADDR_WIDTH   : integer := 11);
	port    (
				CLK          : in  std_logic;
				RESET        : in  std_logic;
				CE           : in  std_logic;
				CITIES       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				CURRENT_CITY : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				NEXT_CITY    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				RAM_ADDR     : out std_logic_vector (ADDR_WIDTH-1 downto 0);
				DONE         : out std_logic);
end Gen_Addr_Calc;

architecture Structural of Gen_Addr_Calc is

	---------- Components ----------
	
	component Gen_Addr_Formula is
		generic (
					DATA_WIDTH   : integer := 8;
					ADDR_WIDTH   : integer := 11);
		port    (
					CLK          : in  std_logic;
					RESET        : in  std_logic;
					CE           : in  std_logic;
					CITIES       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_MIN     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_MAX     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					ADDR_FORMULA : out std_logic_vector (ADDR_WIDTH-1 downto 0);
					DONE         : out std_logic);
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

	---------- Signals ----------
	
	signal City_Min : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal City_Max : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	Addr_F: Gen_Addr_Formula 
		generic map (
						DATA_WIDTH   => DATA_WIDTH,
						ADDR_WIDTH   => ADDR_WIDTH) 
		port map    (
						CLK          => CLK,
						RESET        => RESET,
						CE           => CE,
						CITIES       => CITIES,
						CITY_MIN     => City_Min,
						CITY_MAX     => City_Max,
						ADDR_FORMULA => RAM_ADDR,
						DONE         => DONE);
		
	Comp: Gen_Comp 
		generic map (
						DATA_WIDTH => DATA_WIDTH)
		port map    (
						A          => CURRENT_CITY,
						B          => NEXT_CITY,
						MIN        => City_Min,
						MAX        => City_Max,
						AgB        => open,
						AeB        => open,
						AlB        => open);
end Structural;
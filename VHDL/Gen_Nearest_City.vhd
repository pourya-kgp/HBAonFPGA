----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_City
-- Module Name      : Gen_Nearest_City
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core for specifying and saving the nearest city from the current city
--                    in the nearest neighbor search
-- Comments         : 
-- Dependencies     : 3 cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 326 MHz
-- Area  Estimation : 72 LUTs + 40 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Nearest_City is
	generic (
				INDX_WIDTH    : integer := 8;
				DIST_WIDTH    : integer := 32);
	port    (
				CLK           : in    std_logic;
				RESET         : in    std_logic;
				NEXT_CITY_IND : in    std_logic_vector (INDX_WIDTH-1 downto 0);
				DIST_BETWEEN  : in    std_logic_vector (DIST_WIDTH-1 downto 0);
				NEAREST_IND   : inout std_logic_vector (INDX_WIDTH-1 downto 0);
				DIST_MIN      : inout std_logic_vector (DIST_WIDTH-1 downto 0));
end Gen_Nearest_City;

architecture Structural of Gen_Nearest_City is

	---------- Components ----------
	
	component Gen_Comp_Less is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					MIN        : out std_logic_vector (DATA_WIDTH-1 downto 0);
					AgB        : out std_logic);
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

	component Gen_SR_PIPO is
		generic (
					DATA_WIDTH : integer := 8);
		port	  (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					INPUT      : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					OUTPUT     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	signal Mux_Sel   : std_logic;
	signal Indx_Less : std_logic_vector (INDX_WIDTH-1 downto 0);
	signal Dist_Less : std_logic_vector (DIST_WIDTH-1 downto 0);

begin

	---------- Instantiations ----------

	Comp_L: Gen_Comp_Less
		generic map	(
						DATA_WIDTH => DIST_WIDTH)
		port map    (
						A          => DIST_MIN,
						B          => DIST_BETWEEN,
						MIN        => Dist_Less,
						AgB        => Mux_Sel);

	Mux: Gen_Mux2_1
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => Mux_Sel,
						D0         => NEAREST_IND,
						D1         => NEXT_CITY_IND,
						O          => Indx_Less);

	PIPO_Dist: Gen_SR_PIPO
		generic map (
						DATA_WIDTH => DIST_WIDTH)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => Mux_Sel,
						INPUT      => Dist_Less,
						OUTPUT     => DIST_MIN);

	PIPO_Indx: Gen_SR_PIPO
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => Mux_Sel,
						INPUT      => Indx_Less,
						OUTPUT     => NEAREST_IND);

end Structural;
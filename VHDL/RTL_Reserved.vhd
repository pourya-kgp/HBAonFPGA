----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : RTL_Extra
-- Module Name      : RTL_Extra
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : A core to collect the miscellaneous cores for better access and more order in the hierarchy. 
-- Comments         : ---
-- Dependencies     : ---
-- Target Devices   : ---
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ---
-- Module Version   : ---
-- Creation Date    : 2024/07/09
-- Revision Date    : 2024/07/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RTL_Reserved is
end RTL_Reserved;

architecture Idle of RTL_Reserved is

	---------- Components ----------

	component Gen_Index_ij_Structural is
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

	component Gen_Tour_Async is
		generic (
					INDX_WIDTH : integer := 8);
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

	component Gen_Bee_Async is
		generic (
					INDX_WIDTH : integer := 8;
					ADDR_WIDTH : integer := 11;
					TOUR_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					SEL        : in  std_logic_vector (2 downto 0);
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA1_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_IN   : in  std_logic_vector (TOUR_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_OUT  : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;

	component Gen_Update_Tour_V2 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DONE_BEE   : in  std_logic;
					DATA1_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					CE_BEE     : out std_logic;
					DONE       : out std_logic);
	end component;

	component Gen_Heuristic_Data_Constructor_P1
		generic (
					INDX_WIDTH : integer := 8;
					ADDR_WIDTH : integer := 11;
					DROM_WIDTH : integer := 24;
					DIST_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					NEXT_ADDR  : in  std_logic;
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					RAM_ADDR   : out std_logic_vector (ADDR_WIDTH-1 downto 0);
					RAM_DATA   : out std_logic_vector (DIST_WIDTH-1 downto 0);
					WE         : out std_logic;
					DONE       : out std_logic);
	end component;

	component Gen_LFSR_Old is 
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					CITIES     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					LFSR       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component LFSR_8Bit is 
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				CE    : in  std_logic;
				LFSR  : out std_logic_vector (7 downto 0));
	end component;

	component LFSR_8Bit_Old is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				CE    : in  std_logic;
				LFSR  : out std_logic_vector (7 downto 0));
	end component;

	---------- Signals ----------
	
	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 16;
	constant drom_width : integer := 24;
	constant tour_width : integer := 32;
	
begin

	---------- Instantiations ----------

	Index_ij_Structural: Gen_Index_ij_Structural
		generic map (
						DATA_WIDTH       => indx_width)
		port map    (
						CLK              => open,
						RESET            => open,
						CE               => open,
						NEXT_J           => open,
						CITIES           => open,
						LAST_J           => open,
						NEXT_I           => open,
						LAST_I           => open,
						ENABLE_OUT       => open,
						NEXT_CITY_IND    => open,
						CURRENT_CITY_IND => open);

	Tour_Async: Gen_Tour_Async
		generic map (
						INDX_WIDTH => indx_width)
		port map    (
						CLK        => open,
						RESET      => open,
						CE         => open,
						SEL        => open,
						CITIES     => open,
						FIRST_IND  => open,
						SECND_IND  => open,
						FIRST_CITY => open,
						SECND_CITY => open,
						DONE       => open);
	
	Bee_Async: Gen_Bee_Async
		generic map (
						INDX_WIDTH => indx_width,
						ADDR_WIDTH => addr_width,
						TOUR_WIDTH => tour_width)
		port map    (
						CLK        => open,
						RESET      => open,
						CE         => open,
						SEL        => open,
						CITIES     => open,
						DATA1_IN   => open,
						DATA2_IN   => open,
						FITSS_IN   => open,
						DATA1_OUT  => open,
						DATA2_OUT  => open,
						FITSS_OUT  => open,
						DONE       => open);

	Update_Tour_V2: Gen_Update_Tour_V2
		generic map (
						DATA_WIDTH => indx_width)
		port map    (
						CLK        => open,
						RESET      => open,
						CE         => open,
						DONE_BEE   => open,
						DATA1_IN   => open,
						DATA2_IN   => open,
						DATA1_OUT  => open,
						DATA2_OUT  => open,
						CE_BEE     => open,
						DONE       => open);

	Dist_Mat_Const: Gen_Heuristic_Data_Constructor_P1
		generic map (
						INDX_WIDTH => INDX_WIDTH,
						ADDR_WIDTH => ADDR_WIDTH,
						DROM_WIDTH => DROM_WIDTH,
						DIST_WIDTH => DIST_WIDTH)
		port map    (
						CLK        => open,
						RESET      => open,
						CE         => open,
						NEXT_ADDR  => open,
						CITIES     => open,
						RAM_ADDR   => open,
						RAM_DATA   => open,
						WE         => open,
						DONE       => open);

	LFSR_Old: Gen_LFSR_Old
		generic map (
						DATA_WIDTH => indx_width)
		port map    (
						CLK        => open,
						RESET      => open,
						CE         => open,
						CITIES     => open,
						LFSR       => open);

	LFSR_8: LFSR_8Bit
		port map (
					CLK   => open,
					RESET => open,
					CE    => open,
					LFSR  => open);

	LFSR_8_Old: LFSR_8Bit_Old
		port map (
					CLK   => open,
					RESET => open,
					CE    => open,
					LFSR  => open);
	
end Idle;
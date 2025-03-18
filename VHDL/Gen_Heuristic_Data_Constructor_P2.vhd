----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Heuristic_Data_Constructor_P2
-- Module Name      : Gen_Heuristic_Data_Constructor_P2
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core to construct the distances matrix on the RAM (RAM address and corresponding distance)
-- Comments         : Based on synchronous dual port ROM
-- Dependencies     : 6 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 147 MHz
-- Area  Estimation : 803 LUTs + 754 FFs + 2 RAM/FIFO + 6 DSPs (eil51 database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/15
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Heuristic_Data_Constructor_P2 is
	generic  (
				INDX_WIDTH : integer := 8;
				ADDR_WIDTH : integer := 11;
				DROM_WIDTH : integer := 24;
				DIST_WIDTH : integer := 32);
	port     (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				NEXT_ADDR  : in  std_logic;
				CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
				RAM_ADDR   : out std_logic_vector (ADDR_WIDTH-1 downto 0);
				RAM_DATA   : out std_logic_vector (DIST_WIDTH-1 downto 0);
				WE         : out std_logic;
				DONE       : out std_logic);
end Gen_Heuristic_Data_Constructor_P2;

architecture Structural of Gen_Heuristic_Data_Constructor_P2 is
	
	---------- Components ----------
	
	component Gen_Index_ij_BRAM is
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
	end component;
	
	component Gen_Addr_Calc is
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
	end component;
	
	component Gen_Euclidean_Distance is
		generic (
					DATA_WIDTH : integer := 24;
					DIST_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DATA_X1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA_X2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA_Y1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA_Y2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					E_DIST     : out std_logic_vector (DIST_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;

	component TSP_X_Dual_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 24);
		port    (
					CLK        : in  std_logic;
					ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component TSP_Y_Dual_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 24);
		port    (
					CLK        : in  std_logic;
					ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component Bit_Flipflop_D_Async is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic := '0');
	end component;

	component Bit_Flipflop_D_Async_FallEdge is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic := '0');
	end component;
	
	---------- Signals ----------
	
	-- Index_ij Module
	signal Current_City_Ind : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Next_City_Ind    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Enable_Out       : std_logic := '0';

	-- Address Calculator Module
	signal City_I    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal City_J    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Addr_Done : std_logic := '0';

	-- Euclidean Distance Calculator Module
	signal Data_X1   : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');
	signal Data_X2   : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');
	signal Data_Y1   : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');
	signal Data_Y2   : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');
	signal Dist_Done : std_logic := '0';

	-- Misc
	signal D_FF_NA_Rst : std_logic := '0';
	signal D_FF_NA_Out : std_logic := '0';
	signal Next_Enable : std_logic := '0';
	signal Nx_En_Delay : std_logic := '0';
	signal CE_Com_Rst  : std_logic := '0';
	signal CE_Com      : std_logic := '0';

begin
	
	City_I <= Current_City_Ind + 1;
	City_J <= Next_City_Ind    + 1;
	WE     <= Addr_Done and Dist_Done;

	-- Flip-flop controller logical gates
	Next_Enable <= D_FF_NA_Out and Enable_Out;
	D_FF_NA_Rst <= Nx_En_Delay or  RESET;
	CE_Com_Rst  <= NEXT_ADDR   or  RESET;

	---------- Instantiations ----------
	
	BRAM_Index_ij: Gen_Index_ij_BRAM
		generic map (
						DATA_WIDTH       => INDX_WIDTH)
		port map    (
						CLK              => CLK,
						RESET            => RESET,
						CE               => CE,
						NEXT_DATA        => NEXT_ADDR,
						CITIES           => CITIES,
						ENABLE_OUT       => Enable_Out,
						DONE             => DONE,
						CURRENT_CITY_IND => Current_City_Ind,
						NEXT_CITY_IND    => Next_City_Ind);	
	
	BRAM_Addr_Calc: Gen_Addr_Calc
		generic map (
						DATA_WIDTH   => INDX_WIDTH,
						ADDR_WIDTH   => ADDR_WIDTH)
		port map    (
						CLK          => CLK,
						RESET        => RESET,
						CE           => CE_Com,
						CITIES       => CITIES,
						CURRENT_CITY => City_I, -- City number >= 1
						NEXT_CITY    => City_J, -- City number >= 1
						RAM_ADDR     => RAM_ADDR,
						DONE         => Addr_Done);
	
	Euclidean_Dist: Gen_Euclidean_Distance
		generic map (
						DATA_WIDTH => DROM_WIDTH,
						DIST_WIDTH => DIST_WIDTH)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => CE_Com,
						DATA_X1    => Data_X1,
						DATA_X2    => Data_X2,
						DATA_Y1    => Data_Y1,
						DATA_Y2    => Data_Y2,
						E_DIST     => RAM_DATA,
						DONE       => Dist_Done);

	TSP_X_ROM: TSP_X_Dual_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => INDX_WIDTH,
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR_A     => Current_City_Ind,
						ADDR_B     => Next_City_Ind,
						DOUT_A     => Data_X1,
						DOUT_B     => Data_X2);
						
	TSP_Y_ROM: TSP_Y_Dual_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => INDX_WIDTH,
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR_A     => Current_City_Ind,
						ADDR_B     => Next_City_Ind,
						DOUT_A     => Data_Y1,
						DOUT_B     => Data_Y2);

	-- Flip-flop controllers instances
	D_FF_Next_Addr: Bit_Flipflop_D_Async
		port map (
					CLK   => NEXT_ADDR,
					RESET => D_FF_NA_Rst,
					D_IN  => '1',
					D_OUT => D_FF_NA_Out);
	
	D_FF_Next_Addr_Rst: Bit_Flipflop_D_Async
		port map (
					CLK   => CLK,
					RESET => RESET,
					D_IN  => Next_Enable,
					D_OUT => Nx_En_Delay);

	D_FF_CE_Com: Bit_Flipflop_D_Async_FallEdge
		port map (
					CLK   => Nx_En_Delay,
					RESET => CE_Com_Rst,
					D_IN  => '1',
					D_OUT => CE_Com);
	
end Structural;
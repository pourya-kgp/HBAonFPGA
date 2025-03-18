----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Nearest_Neighbor
-- Module Name      : Gen_Nearest_Neighbor
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core for specifying the nearest neighbor from the current city
-- Comments         : 
-- Dependencies     : 10 cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 143 MHz
-- Area  Estimation : 452 LUTs + 157 FFs + 3 RAM/FIFO + 2 DSPs (eil51 Database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Nearest_Neighbor is
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
end Gen_Nearest_Neighbor;

architecture Structural of Gen_Nearest_Neighbor is
	
	---------- Components ----------
	
	component Gen_Index_ij_Behavioral is
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
	
	component Gen_Tour_Sync is
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
	
	component TSP_Dist_One_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : integer := 11;
					DATA_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component Gen_Nearest_City is
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
	
	component Gen_Demux1_2 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic;
					D          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D0         : out std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component Gen_Flipflop_D_Async is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					D_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
					D_OUT      : out std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0'));
	end component;
	
	component Bit_Flipflop_D_Async is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic := '0');
	end component;
	
	component Gen_SR_SISO is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					SR_IN      : in  std_logic;
					SR_OUT     : out std_logic);
	end component;
	
	---------- Signals ----------
	
	-- Index Module
	signal Next_J , Enable_Out              : std_logic;
	signal Current_City_Ind , Next_City_Ind : std_logic_vector (INDX_WIDTH-1 downto 0);
	
	-- Tour Module
	signal CE_Tour , Done_Tour             : std_logic;
	signal F_Ind , S_Ind , F_City , S_City : std_logic_vector (INDX_WIDTH-1 downto 0);
	
	-- Address Calculator Module
	signal CE_Addr , Done_Addr      : std_logic;
	signal Current_City , Next_City : std_logic_vector (INDX_WIDTH-1 downto 0);
	signal Ram_Addr                 : std_logic_vector (ADDR_WIDTH-1 downto 0);
	
	-- Nearest City Module
	signal PIPO_Rst      : std_logic;
	signal Next_Near_Ind : std_logic_vector (INDX_WIDTH-1 downto 0);
	signal Dist_Between  : std_logic_vector (TOUR_WIDTH-1 downto 0); 
	
	-- Demultiplexer
	signal Demux_S : std_logic;
	
	-- 1 Bit D-Flipflop Module
	signal Last_J_Late , SR_Out_Late : std_logic;
	
	-- SISO Module
	signal SR_Rst , SR_In , SR_Out   : std_logic;
	
begin
	
	Next_J   <= CE_CNT or (not(Last_J_Late) and Done_Addr);
	CE_Addr  <= Done_Tour and SEL(1) and not(SEL(0)); -- Just in Dual_Read Mode
	CE_Tour  <= Enable_Out or CE_OPT;
	Demux_S  <= SEL(1) and SEL(0);
	PIPO_Rst <= RESET or NEXT_I;
	SR_Rst   <= RESET or SR_Out_Late;
	SR_In    <= (Last_J and Done_Addr);               -- Just in Dual_Read Mode
	DONE     <= SR_Out or (Done_Tour and (SEL(1) nand not(SEL(0))));

	---------- Instantiations ----------
	
	Index_ij: Gen_Index_ij_Behavioral
		generic map (
						DATA_WIDTH       => INDX_WIDTH)
		port map    (
						CLK              => CLK,
						RESET            => RESET,
						CE               => CE,
						NEXT_J           => Next_J,
						CITIES           => CITIES,
						LAST_J           => LAST_J,
						NEXT_I           => NEXT_I,
						LAST_I           => LAST_I,
						ENABLE_OUT       => Enable_Out,
						CURRENT_CITY_IND => Current_City_Ind,
						NEXT_CITY_IND    => Next_City_Ind);
	
	Tour_TSP: Gen_Tour_Sync
		generic map (
						INDX_WIDTH => INDX_WIDTH)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => CE_Tour,
						SEL        => SEL,
						CITIES     => CITIES,
						FIRST_IND  => F_Ind,
						SECND_IND  => S_Ind,
						FIRST_CITY => F_City,
						SECND_CITY => S_City,
						DONE       => Done_Tour);
	
	Addr_Calc: Gen_Addr_Calc
		generic map (
						DATA_WIDTH   => INDX_WIDTH,
						ADDR_WIDTH   => ADDR_WIDTH)
		port map    (
						CLK          => CLK,
						RESET        => RESET,
						CE           => CE_Addr,
						CITIES       => CITIES,
						CURRENT_CITY => Current_City,
						NEXT_CITY    => Next_City,
						RAM_ADDR     => Ram_Addr,
						DONE         => Done_Addr);
	
	TSP_Dist_DATA_ROM: TSP_Dist_One_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => ADDR_WIDTH,
						DATA_WIDTH => TOUR_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR       => Ram_Addr,
						DATA       => Dist_Between);
	
	Nearest_City: Gen_Nearest_City
		generic map (
						INDX_WIDTH    => INDX_WIDTH,
						DIST_WIDTH    => TOUR_WIDTH)
		port map    (
						CLK           => CLK,
						RESET         => PIPO_Rst,
						NEXT_CITY_IND => Next_Near_Ind,
						DIST_BETWEEN  => Dist_Between,
						NEAREST_IND   => NEAREST_IND,
						DIST_MIN      => DIST_MIN);
	
	Mux1: Gen_Mux2_1
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => SEL(1),
						D0         => FIRST_CITY_IND,
						D1         => Current_City_Ind,
						O          => F_Ind);
	
	Mux2: Gen_Mux2_1
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => SEL(1),
						D0         => SECND_CITY_IND,
						D1         => Next_City_Ind,
						O          => S_Ind);
	
	Demux1: Gen_Demux1_2
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => Demux_S,
						D          => F_City,
						D0         => Current_City,
						D1         => TOUR);
	
	Demux2: Gen_Demux1_2
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => Demux_S,
						D          => S_City,
						D0         => Next_City,
						D1         => INDX);
	
	D_Flipflop_Async: Gen_Flipflop_D_Async
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						CLK        => Done_Addr,
						RESET      => RESET,
						D_IN       => Next_City_Ind,
						D_OUT      => Next_Near_Ind);
	
	D_Flipflop_Bit1: Bit_Flipflop_D_Async
		port map (
					CLK   => CLK,
					RESET => RESET,
					D_IN  => LAST_J,
					D_OUT => Last_J_Late);
	
	D_Flipflop_Bit2: Bit_Flipflop_D_Async
		port map (
					CLK   => CLK,
					RESET => RESET,
					D_IN  => SR_Out,
					D_OUT => SR_Out_Late);
	
	SR_SISO: Gen_SR_SISO
		generic map (
						DATA_WIDTH => 9) -- Very Crucial ==> 9 <= DATA_WIDTH <= INF
		port map    (
						CLK        => CLK,
						RESET      => SR_Rst,
						SR_IN      => SR_In,
						SR_OUT     => SR_Out);
	
end Structural;
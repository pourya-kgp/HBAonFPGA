----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Heuristic_Data_Constructor_P1
-- Module Name      : Gen_Heuristic_Data_Constructor_P1
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Generic core to construct the distances matrix on the RAM (RAM address and corresponding distance)
-- Comments         : Based on synchronous one port ROM
-- Dependencies     : 13 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 147 MHz
-- Area  Estimation : 912 LUTs + 856 FFs + 2 RAM/FIFO + 6 DSPs (eil51 database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/15
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Heuristic_Data_Constructor_P1 is
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
end Gen_Heuristic_Data_Constructor_P1;

architecture Structural of Gen_Heuristic_Data_Constructor_P1 is
	
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

	component TSP_X_One_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 24);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component TSP_Y_One_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 24);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
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
	
	component Gen_Demux1_2 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic;
					D          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D0         : out std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component Bit_Demux1_2 is
		port (
				S  : in  std_logic;
				D  : in  std_logic;
				D0 : out std_logic;
				D1 : out std_logic);
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

	component Flipflop_T_Async is
		port (
				CLK    : in    std_logic;
				RESET  : in    std_logic;
				INPUT  : in    std_logic;
				OUTPUT : inout std_logic := '0');
	end component;

	---------- Signals ----------
	
	-- Index_ij Module
	signal Current_City_Ind : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Next_City_Ind    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Enable_Out       : std_logic := '0';

	-- Address Calculator Module
	signal City_I      : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal City_J      : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Addr_Done   : std_logic := '0';

	-- Euclidean Distance Calculator Module
	signal Dist_Done : std_logic := '0';

	-- ROM Modules
	signal Addr_XY : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Data_X  : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');
	signal Data_Y  : std_logic_vector (DROM_WIDTH-1 downto 0) := (others => '0');

	-- Euclidean Distance Flip-Flops
	type Data_XY is array (3 downto 0) of std_logic_vector (DROM_WIDTH-1 downto 0); 
	signal FF_In  : Data_XY := (others => (others => '0'));
	signal FF_Out : Data_XY := (others => (others => '0'));
	signal FF_Clk : std_logic_vector (1 downto 0) := (others => '0');
	
	-- Controller signals
	signal Sel_ij      : std_logic := '0';

	signal D_FF_NA_Rst : std_logic := '0';
	signal D_FF_NA_Out : std_logic := '0';
	
	signal Next_Enable : std_logic := '0';
	signal Nx_En_Delay : std_logic := '0';
	
	signal SR_Rst_Delay: std_logic := '0';
	signal SR_Rst      : std_logic := '0';
	signal SR_In       : std_logic := '0';
	signal SR_Out      : std_logic := '0';
	
	signal T_FF_Clk    : std_logic := '0';
	
	signal CE_Com_Rst  : std_logic := '0';
	signal CE_Com      : std_logic := '0';
	
begin
	
	City_I   <= Current_City_Ind + 1;
	City_J   <= Next_City_Ind + 1;
	WE       <= Addr_Done and Dist_Done;

	-- Mux, Demux, and flip-flop controller gates
	Next_Enable <= D_FF_NA_Out  and Enable_Out;
	D_FF_NA_Rst <= Nx_En_Delay  or RESET;
	SR_In       <= Next_Enable  or SR_Out;
	SR_Rst      <= SR_Rst_Delay or RESET;
	CE_Com_Rst  <= NEXT_ADDR    or RESET;

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
						DATA_X1    => FF_Out(0),
						DATA_X2    => FF_Out(1),
						DATA_Y1    => FF_Out(2),
						DATA_Y2    => FF_Out(3),
						E_DIST     => RAM_DATA,
						DONE       => Dist_Done);

	Generate_FF: for i in 0 to 3 generate
		Generate_FF_X: if (i < 2) generate
			D_Flipflop_Async: Gen_Flipflop_D_Async
				generic map (
								DATA_WIDTH => DROM_WIDTH)
				port map    (
								CLK        => FF_Clk(i),
								RESET      => RESET,
								D_IN       => FF_In(i),
								D_OUT      => FF_Out(i));
		end generate;
		Generate_FF_Y: if (i >= 2) generate
			D_Flipflop_Async: Gen_Flipflop_D_Async
				generic map (
								DATA_WIDTH => DROM_WIDTH)
				port map    (
								CLK        => FF_Clk(i-2),
								RESET      => RESET,
								D_IN       => FF_In(i),
								D_OUT      => FF_Out(i));
		end generate;
	end generate;					

	Demux_X: Gen_Demux1_2
		generic map (
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						S          => Sel_ij,
						D          => Data_X,
						D0         => FF_In(0),
						D1         => FF_In(1));
	
	Demux_Y: Gen_Demux1_2
		generic map (
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						S          => Sel_ij,
						D          => Data_Y,
						D0         => FF_In(2),
						D1         => FF_In(3));

	TSP_X_ROM: TSP_X_One_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => INDX_WIDTH,
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR       => Addr_XY,
						DATA       => Data_X);
	
	TSP_Y_ROM: TSP_Y_One_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => INDX_WIDTH,
						DATA_WIDTH => DROM_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR       => Addr_XY,
						DATA       => Data_Y);
	
	Mux_Addr: Gen_Mux2_1
		generic map (
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						S          => Sel_ij,
						D0         => Current_City_Ind,
						D1         => Next_City_Ind,
						O          => Addr_XY);

	-- Mux, Demux, flip-flop controllers, and module CE controller instances
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
	
	SR_SISO: Gen_SR_SISO
		generic map (
						DATA_WIDTH => 2) -- Very Crucial ==> Change the length of SR to meet the timing closure goal
		port map    (
						CLK        => CLK,
						RESET      => SR_Rst,
						SR_IN      => SR_In,
						SR_OUT     => SR_Out);
	
	D_FF_T_FF: Bit_Flipflop_D_Async
		port map (
					CLK   => CLK,
					RESET => RESET,
					D_IN  => SR_Out,
					D_OUT => T_FF_Clk);

	T_Flipflop: Flipflop_T_Async
		port map (
					CLK    => T_FF_Clk,
					RESET  => RESET,
					INPUT  => '1',
					OUTPUT => Sel_ij);

	Demux_FF_Clk: Bit_Demux1_2
		port map (
					S  => Sel_ij,
					D  => SR_Out,
					D0 => FF_Clk(0),
					D1 => FF_Clk(1));

	D_FF_SR_RST: Bit_Flipflop_D_Async
		port map (
					CLK   => CLK,
					RESET => RESET,
					D_IN  => FF_Clk(1),
					D_OUT => SR_Rst_Delay);

	D_FF_CE_Com: Bit_Flipflop_D_Async
		port map (
					CLK   => FF_Clk(1),
					RESET => CE_Com_Rst,
					D_IN  => '1',
					D_OUT => CE_Com);

end Structural;
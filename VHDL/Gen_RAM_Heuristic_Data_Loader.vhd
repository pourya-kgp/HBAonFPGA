----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_RAM_Heuristic_Data_Loader
-- Module Name      : Gen_RAM_Heuristic_Data_Loader
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to load an internal/external RAM with the distance matrix information
-- Comments         : 
-- Dependencies     : 2 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 147 MHz
-- Area  Estimation : 842 LUTs + 761 FFs + 4 RAM/FIFO + 6 DSPs (eil51 database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2024/07/14
-- Revision Date    : 2024/07/14
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_RAM_Heuristic_Data_Loader is
	generic (
				INDX_WIDTH : integer := 8;
				ADDR_WIDTH : integer := 11;
				DROM_WIDTH : integer := 24;
				DIST_WIDTH : integer := 32);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
				ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
				DOUT       : out std_logic_vector (DIST_WIDTH-1 downto 0);
				DONE       : out std_logic);
end Gen_RAM_Heuristic_Data_Loader;

architecture Moore_FSM of Gen_RAM_Heuristic_Data_Loader is

	---------- Components ----------

	component Gen_Heuristic_Data_Constructor_P2
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

	component Xilinx_One_Port_RAM_Sync is
		generic (
					ADDR_WIDTH : integer := 8;
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					WE         : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DIN        : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	---------- Signals ----------

	-- Heuristic data constructor module
	signal Next_Addr  : std_logic := '0';
	signal Const_WE   : std_logic := '0';
	signal Const_Done : std_logic := '0';
	signal Const_Addr : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	signal Const_Data : std_logic_vector (DIST_WIDTH-1 downto 0) := (others => '1');
	
	-- Single port BRAM module
	signal Ram_WE     : std_logic := '0';
	signal Ram_Addr   : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	signal Ram_Din    : std_logic_vector (DIST_WIDTH-1 downto 0) := (others => '1');
	signal Ram_Dout   : std_logic_vector (DIST_WIDTH-1 downto 0) := (others => '1');

	-- Misc
	signal Read_En    : std_logic := '0';

	-- FSM & Control Signals
	type State is (Idle_Mode , Assign_Data , Write_RAM , Next_Cell , Accessment , Read_RAM);
	signal S_Curr , S_Next : State;
	
begin
	
	DONE <= Read_En;		
	DOUT <= (others => '1') when (Read_En = '0') else Ram_Dout;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next;
		end if;
	end process;

	process (S_Curr , CE , ADDR , Const_WE , Const_Done , Const_Addr , Const_Data)
	begin

		S_Next <= S_Curr;
		
		-- Default assignments to prevent latches
		Next_Addr <= '0';
		Read_En   <= '0';
		Ram_WE    <= '0';
		Ram_Addr  <= (others => '0');
		Ram_Din   <= (others => '1');
		
		case S_Curr is
			when Idle_Mode   =>
										if (CE = '1') then
											S_Next <= Assign_Data;
										else
											S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
										end if;
			
			when Assign_Data =>
										Ram_Addr <= Const_Addr;
										Ram_Din  <= Const_Data;
										S_Next <= Write_RAM;
			
			when Write_RAM   =>
										Ram_Addr <= Const_Addr;
										Ram_Din  <= Const_Data;
										Ram_WE <= '1';
										S_Next <= Next_Cell;
			
			when Next_Cell   =>
										Next_Addr <= '1';
										S_Next <= Accessment;
			
			when Accessment  =>
										if (Const_Done = '1') then
											S_Next <= Read_RAM;
										elsif (Const_WE = '1') then
											S_Next <= Assign_Data;
										else
											S_Next <= Accessment; -- Redundant, only for clarification purposes
										end if;
			
			when Read_RAM    =>
										Read_En <= '1';
										Ram_Addr <= ADDR;
										if (CE = '0') then
											S_Next <= Idle_Mode;
										else
											S_Next <= Read_RAM; -- Redundant, only for clarification purposes
										end if;
		end case;

	end process;
		
	---------- Instantiations ----------

	Dist_Mat_Const: Gen_Heuristic_Data_Constructor_P2
		generic map (
						INDX_WIDTH => INDX_WIDTH,
						ADDR_WIDTH => ADDR_WIDTH,
						DROM_WIDTH => DROM_WIDTH,
						DIST_WIDTH => DIST_WIDTH)
		port map    (
						CLK        => CLK,
						RESET      => RESET,
						CE         => CE,
						NEXT_ADDR  => Next_Addr,
						CITIES     => CITIES,
						RAM_ADDR   => Const_Addr,
						RAM_DATA   => Const_Data,
						WE         => Const_WE,
						DONE       => Const_Done);

	BRAM_One_Port: Xilinx_One_Port_RAM_Sync
		generic map (
						ADDR_WIDTH => ADDR_WIDTH,
						DATA_WIDTH => DIST_WIDTH)
		port map    (
						CLK        => CLK,
						WE         => Ram_WE,
						ADDR       => Ram_Addr,
						DIN        => Ram_Din,
						DOUT       => Ram_Dout);
	
end Moore_FSM;
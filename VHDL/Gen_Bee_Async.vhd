----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Bee_Async
-- Module Name      : Gen_Bee_Async
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to simulate the bee behavior, hold the path of TSP and make changes to it
-- Comments         : 
-- Dependencies     : Async RAM
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 209 MHz
-- Area  Estimation : 244 LUTs + 50 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/06/12
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Bee_Async is
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
end Gen_Bee_Async;

architecture Moore_FSM of Gen_Bee_Async is

	---------- Components ----------
	
	component Xilinx_Dual_Port_RAM_Async is
		generic (
					ADDR_WIDTH : integer := 8;
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					WE         : in  std_logic;
					ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA_W     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	-- Distributed Dual Port RAM
	signal WE     : std_logic := '0';
	signal Addr_A : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Addr_B : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Data_W : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Dout_A : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Dout_B : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	
	-- FSM & Control Signals
	type State is (Idle_Mode , Init ,
						Single_Write , Exchange , Dual_Read , Final_Read , Single_Read , Read_Write , Delay , Final);
	signal S_Curr , S_Next : State;
	
	signal I_Curr , I_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal F_Curr , F_Next : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
			
begin
	
	FITSS_OUT <= F_Curr;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
			I_Curr <= (others => '0');
			F_Curr <= (others => '0');
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next; -- State Signals
			I_Curr <= I_Next; -- Counter
			F_Curr <= F_Next; -- Fitness Value Holder
		end if;
	end process;
	
	process (S_Curr , I_Curr , F_Curr , CE , SEL , DATA1_IN , DATA2_IN , FITSS_IN , CITIES , Dout_A , Dout_B)
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		I_Next <= I_Curr;
		F_Next <= F_Curr;

		-- Default assignments to prevent latches
		WE   <= '0'; -- One Puls Width
		DONE <= '0'; -- One Puls Width
		DATA1_OUT <= (others => '0');
		DATA2_OUT <= (others => '0');
		Addr_A <= (others => '0'); --> Dout_A(0)
		Addr_B <= (others => '0'); --> Dout_B(0)
		Data_W <= (others => '0');

		case S_Curr is
			when Idle_Mode    =>
										if (CE = '1') then
											S_Next <= Init;
											I_Next <= (others => '0');
										else
											S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
										end if;
			
			when Init         =>
										if    (SEL = "000") then   -- Single_Write
											S_Next <= Single_Write;
										elsif (SEL = "001") then   -- Exchange
											S_Next <= Exchange;
										elsif (SEL = "010") then   -- Dual_Read
											S_Next <= Dual_Read;
										elsif (SEL = "011") then   -- Single_Read
											S_Next <= Single_Read;
										elsif (SEL = "100") then   -- Read_Write
											S_Next <= Read_Write;
										else
											S_Next <= Idle_Mode;
										end if;
										
			when Single_Write =>
										-- Write CITY Number to the corresponding index
										-- Duration from rising_edge(CE) to rising_edge(Done) => (cities+3)*CLK
										if (I_Curr < CITIES) then
											-- Tour(DATA2_IN) <= DATA1_IN
											Addr_A <= DATA2_IN;
											Data_W <= DATA1_IN;
											WE <= '1';
											S_Next <= Single_Write; -- Redundant, only for clarification purposes
											I_Next <= I_Curr + 1;
										else
											F_Next <= FITSS_IN;
											S_Next <= Delay;
										end if;
										
			when Exchange     =>
										if (DATA1_IN /= DATA2_IN) then
											-- Exchange Two corresponding cities if they have not the same index (same cities)
											-- Duration from rising_edge(CE) to rising_edge(Done) => 5*CLK
											if (I_Curr = Zero) then
												-- Put RAM Content of Address DATA1_IN to Address CITIES using both ports
												-- Tour(CITIES) <= Tour(DATA1_IN) = Dout_B(DATA1_IN)
												Addr_B <= DATA1_IN; --------------> Dout_B(DATA1_IN)
												Addr_A <= CITIES;
												Data_W <= Dout_B;
												WE <= '1';
												S_Next <= Exchange; -- Redundant, only for clarification purposes
												I_Next <= Zero + 1;
											elsif (I_Curr = Zero+1) then 
												-- Put RAM Content of Address DATA2_IN to Address DATA1_IN using both ports
												-- Tour(DATA1_IN) <= Tour(DATA2_IN) = Dout_B(DATA2_IN)
												Addr_B <= DATA2_IN; ----------------> Dout_B(DATA2_IN)
												Addr_A <= DATA1_IN;
												Data_W <= Dout_B;
												WE <= '1';
												S_Next <= Exchange; -- Redundant, only for clarification purposes
												I_Next <= Zero + 2;
											elsif (I_Curr = Zero+2) then 
												-- Put RAM Content of Address CITIES to Address DATA2_IN using both ports
												-- Tour(DATA2_IN) <= Tour(CITIES) = Dout_B(CITIES)
												Addr_B <= CITIES; ----------------> Dout_B(CITIES)
												Addr_A <= DATA2_IN;
												Data_W <= Dout_B;
												WE <= '1';
												F_Next <= FITSS_IN;
												-- Change State
												S_Next <= Final;
											else
												S_Next <= Init;
												I_Next <= (others => '0');
											end if;
										else
											S_Next <= Final;
										end if;
									
			when Dual_Read    =>
										-- Read corresponding cities and put it on the output ports
										-- The outputs are held till a RESET or a state change
										-- Duration from rising_edge(CE) to rising_edge(Done) => 3*CLK										
										DATA1_OUT <= Dout_A;
										DATA2_OUT <= Dout_B;
										Addr_A <= DATA1_IN; --> Dout_A(DATA1_IN)
										Addr_B <= DATA2_IN; --> Dout_B(DATA2_IN)
										if (I_Curr = Zero) then
											S_Next <= Final_Read;
											I_Next <= Zero + 1;
										elsif (CE = '1') then
											S_Next <= Init;
											I_Next <= (others => '0');
										else
											S_Next <= Dual_Read; -- Redundant, only for clarification purposes
										end if;
			
			when Final_Read   =>
										DONE <= '1';
										DATA1_OUT <= Dout_A;
										DATA2_OUT <= Dout_B;
										Addr_A <= DATA1_IN; --> Dout_A(DATA1_IN)
										Addr_B <= DATA2_IN; --> Dout_B(DATA2_IN)
										S_Next <= Dual_Read;
			
			when Single_Read  =>
										-- Read all cities from first one to the last one and put them on portA and their indexes on portB
										-- Duration from rising_edge(CE) to rising_edge(Done) => (cities+2)*CLK
										Addr_A <= I_Curr; --> Dout_A(I_Curr)
										DATA1_OUT <= Dout_A;
										DATA2_OUT <= I_Curr;
										if (I_Curr < CITIES-1) then
											S_Next <= Single_Read; -- Redundant, only for clarification purposes
											I_Next <= I_Curr + 1;
										else
											S_Next <= Delay;
										end if;
			
			when Read_Write   =>
										-- Read  the data on address I_Curr and put it on output portB
										-- Write the data on address I_Curr from input portA
										-- Duration from rising_edge(CE) to rising_edge(Done) => (cities+2)*CLK
										-- read
										Addr_B <= I_Curr; --> Dout_B(I_Curr)
										DATA1_OUT <= Dout_B;
										DATA2_OUT <= I_Curr;
										-- Write
--										Addr_A <= I_Curr;   -- Address - V1
										Addr_A <= DATA2_IN; -- Address - V2
										Data_W <= DATA1_IN; -- Data
										WE <= '1';
										if (I_Curr < CITIES-1) then
											S_Next <= Read_Write; -- Redundant, only for clarification purposes
											I_Next <= I_Curr + 1;
										else
											F_Next <= FITSS_IN;
											S_Next <= Delay;
										end if;
			
			when Delay        =>
										S_Next <= Final;
			
			when Final        =>
										DONE <= '1';
										S_Next <= Idle_Mode;
		end case;
	end process;
	
	---------- Instantiations ----------

	Dual_Dist_RAM: Xilinx_Dual_Port_RAM_Async
		generic map (
						ADDR_WIDTH => INDX_WIDTH,
						DATA_WIDTH => INDX_WIDTH)
		port map    (
						CLK        => CLK,
						WE         => WE,
						ADDR_A     => Addr_A,
						ADDR_B     => Addr_B,
						DATA_W     => Data_W,
						DOUT_A     => Dout_A,
						DOUT_B     => Dout_B);

end Moore_FSM;
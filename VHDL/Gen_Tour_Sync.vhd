----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Tour_Sync
-- Module Name      : Gen_Tour_Sync
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to hold the path of TSP and make changes to it
-- Comments         : 
-- Dependencies     : Sync RAM
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 209 MHz
-- Area  Estimation : 141 LUTs + 24 FFs + 1 RAM/FIFO
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/19
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Tour_Sync is
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
end Gen_Tour_Sync;

architecture Moore_FSM of Gen_Tour_Sync is

	---------- Components ----------
	
	component Xilinx_Dual_Port_RAM_Sync is
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
	type State is (Idle_Mode , Init , Sort , Exchange , Dual_Read , Final_Read , Single_Read , Final);
	signal S_Curr , S_Next : State;
	
	signal I_Curr , I_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal D_Curr , D_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	
begin

	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
			I_Curr <= (others => '0');
			D_Curr <= Zero + 1;
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next; -- State Signals
			I_Curr <= I_Next; -- Counter
			D_Curr <= D_Next; -- Sort State Data
		end if;
	end process;

	process (S_Curr , I_Curr , D_Curr , CE , SEL , FIRST_IND , SECND_IND , CITIES , Dout_A , Dout_B)
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		I_Next <= I_Curr;
		D_Next <= D_Curr;

		-- Default assignments to prevent latches
		WE   <= '0'; -- One Puls Width
		DONE <= '0'; -- One Puls Width
		FIRST_CITY <= (others => '0');
		SECND_CITY <= (others => '0');
		Addr_A <= (others => '0'); --> Dout_A(0)
		Addr_B <= (others => '0'); --> Dout_B(0)
		Data_W <= (others => '0');
		
		case S_Curr is
			when Idle_Mode   =>
										if (CE = '1') then
											S_Next <= Init;
											I_Next <= (others => '0');
										else
											S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
										end if;
			
			when Init        =>
										if    (SEL = "00") then -------------------- Sort
											S_Next <= Sort;
											D_Next <= Zero + 1;
										elsif (SEL = "01") then	-------------------- Exchange
											Addr_B <= FIRST_IND; --> Dout_B(FIRST_IND)
											S_Next <= Exchange;
										elsif (SEL = "10") then	-------------------- Dual_Read
											Addr_A <= FIRST_IND; --> Dout_A(FIRST_IND)
											Addr_B <= SECND_IND; --> Dout_B(SECND_IND)
											S_Next <= Dual_Read;
										elsif (SEL = "11") then	-------------------- Single_Read
											Addr_A <= I_Curr;    --> Dout_A(Zero)
											S_Next <= Single_Read;
										end if;
										
			when Sort        =>
										-- Write CITY Number to the corresponding index
										-- Duration from rising_edge(CE) to rising_edge(Done) => (cities+3)*CLK
										if (I_Curr < CITIES) then
											-- Tour(I_Curr) <= I_Curr + 1 = D_Curr
											Addr_A <= I_Curr;
											Data_W <= D_Curr;
											WE <= '1';
											S_Next <= Sort; -- Redundant, only for clarification purposes
											I_Next <= I_Curr + 1;
											D_Next <= D_Curr + 1;
										else
											S_Next <= Final;
										end if;
									
			when Exchange    =>
										if (FIRST_IND /= SECND_IND) then
											-- Exchange Two corresponding cities if they have not the same index (same cities)
											-- Duration from rising_edge(CE) to rising_edge(Done) => 5*CLK
											if (I_Curr = Zero) then
												-- Put RAM Content of Address FIRST_IND to Address CITIES using both ports
												-- Tour(CITIES) <= Tour(FIRST_IND) = Dout_B(FIRST_IND)
												Addr_A <= CITIES;
												Data_W <= Dout_B;
												WE <= '1';
												Addr_B <= SECND_IND; -----------------> Dout_B(SECND_IND)
												S_Next <= Exchange; -- Redundant, only for clarification purposes
												I_Next <= Zero + 1;
											elsif (I_Curr = Zero+1) then 
												-- Put RAM Content of Address SECND_IND to Address FIRST_IND using both ports
												-- Tour(FIRST_IND) <= Tour(SECND_IND) = Dout_B(SECND_IND)
												Addr_A <= FIRST_IND;
												Data_W <= Dout_B;
												WE <= '1';
												Addr_B <= CITIES; -----------------> Dout_B(CITIES)
												S_Next <= Exchange; -- Redundant, only for clarification purposes
												I_Next <= Zero + 2;
											elsif (I_Curr = Zero+2) then 
												-- Put RAM Content of Address CITIES to Address SECND_IND using both ports
												-- Tour(SECND_IND) <= Tour(CITIES) = Dout_B(CITIES)
												Addr_A <= SECND_IND;
												Data_W <= Dout_B;
												WE <= '1';
												-- Change State
												S_Next <= Final;
											else
												S_Next <= Init;
												I_Next <= (others => '0');
											end if;
										else
											S_Next <= Final;
										end if;
			
			when Dual_Read   =>
										-- Read corresponding cities and put it on the output ports
										-- The outputs are held till a RESET or a state change
										-- Duration from rising_edge(CE) to rising_edge(Done) => 3*CLK
										FIRST_CITY <= Dout_A;
										SECND_CITY <= Dout_B;
										Addr_A <= FIRST_IND; --> Dout_A(FIRST_IND)
										Addr_B <= SECND_IND; --> Dout_B(SECND_IND)
										if (I_Curr = Zero) then
											S_Next <= Final_Read;
											I_Next <= Zero + 1;
										elsif (CE = '1') then
											S_Next <= Init;
											I_Next <= (others => '0');
										else
											S_Next <= Dual_Read; -- Redundant, only for clarification purposes
										end if;
			
			when Final_Read  =>
										DONE <= '1';
										FIRST_CITY <= Dout_A;
										SECND_CITY <= Dout_B;
										Addr_A <= FIRST_IND; --> Dout_A(FIRST_IND)
										Addr_B <= SECND_IND; --> Dout_B(SECND_IND)
										S_Next <= Dual_Read;
			
			when Single_Read => 
										-- Read all cities from first one to the last one and put them on portA and their indexes on portB
										-- Duration from rising_edge(CE) to rising_edge(Done) => (cities+2)*CLK
										FIRST_CITY <= Dout_A;
										SECND_CITY <= I_Curr;
										if (I_Curr < CITIES-1) then
											Addr_A <= I_Curr + 1; --> Dout_A(I_Curr + 1)
											S_Next <= Single_Read; -- Redundant, only for clarification purposes
											I_Next <= I_Curr + 1;
										else
											S_Next <= Final;
										end if;
			
			when Final       =>
										DONE <= '1';
										S_Next <= Idle_Mode;
		end case;
	end process;

	Dual_Dist_RAM: Xilinx_Dual_Port_RAM_Sync 
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
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Update_Tour_V1
-- Module Name      : Gen_Update_Tour_V1
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to update the TSP tour after a successful local 2-OPT search
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 208 MHz
-- Area  Estimation : 102 LUTs + 14 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : v1
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/17
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Update_Tour_V1 is
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
end Gen_Update_Tour_V1;

architecture Moore_FSM of Gen_Update_Tour_V1 is
	
	-- State Machine & Control Signals
	type State is (Idle_Mode , Init , Set_Outputs , Start_Exchange , Done_Exchange , Final);
	signal S_Curr , S_Next : State;
	
	signal I_Curr , I_Next : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- Misc
	signal City_R1 : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal City_R2 : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Differ  : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero  : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
			I_Curr <= Zero + 1;
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next; -- State Signals
			I_Curr <= I_Next; -- Counter
		end if;
	end process;
	
	process (S_Curr , I_Curr , CE , DONE_BEE , DATA1_IN , DATA2_IN)
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		I_Next <= I_Curr;

		-- Default assignments to prevent latches
		CE_BEE <= '0';
		Done   <= '0';
		DATA1_OUT <= (others => '0'); -- Reset the value
		DATA2_OUT <= (others => '0'); -- Reset the value
		City_R1 <= DATA1_IN + I_Curr;
		City_R2 <= DATA2_IN - I_Curr;
		Differ  <= City_R2 - City_R1; -- DATA2_IN > DATA1_IN (Directly connected to the Local Search Module outputs)
		
		case S_Curr is
			when Idle_Mode      =>
											if (CE = '1') then
												S_Next <= Init;
											else
												S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
											end if;
			
			when Init           =>
											if (DATA2_IN /= Zero) then 
												I_Next <= Zero + 1;
												S_Next <= Set_Outputs;
											else
												S_Next <= Final;
													-- In the condition that the Local Search Module DID NOT Find better results,
													-- it puts Zero on its outputs. Therefore, the Update Module will know that
													-- any exchange is NOT permitted or necessary, move to the Final State,
													-- and set the DONE signal high
											end if;
			
			when Set_Outputs    =>
											DATA1_OUT <= City_R1;
											DATA2_OUT <= City_R2;
											S_Next <= Start_Exchange;
			
			when Start_Exchange =>
											CE_BEE <= '1';
											DATA1_OUT <= City_R1; -- Stays unchanged
											DATA2_OUT <= City_R2; -- Stays unchanged
											S_Next <= Done_Exchange;
			
			when Done_Exchange  =>
											DATA1_OUT <= City_R1; -- Stays unchanged
											DATA2_OUT <= City_R2; -- Stays unchanged
											if (DONE_BEE = '1') then
												if (Differ > Zero+2) then
													I_Next <= I_Curr + 1;
													S_Next <= Set_Outputs;
												else
													S_Next <= Final;
												end if;
											else
												S_Next <= Done_Exchange; -- Redundant, only for clarification purposes
											end if;
			when Final          =>
											Done <= '1'; -- Stays high as long as CE = 1 or a reset occurrence
											if (CE = '0') then
												S_Next <= Idle_Mode;
											else
												S_Next <= Final; -- Redundant, only for clarification purposes
											end if;
		end case;
	end process;
	
end Moore_FSM;
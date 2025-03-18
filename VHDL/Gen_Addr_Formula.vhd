----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Addr_Formula
-- Module Name      : Gen_Addr_Formula
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to calculate the address of two cities' distance in the ROM (distance matrix)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 199 MHz
-- Area  Estimation : 78 LUTs + 53 FFs + 2 DSPs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/22
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_Addr_Formula is
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
end Gen_Addr_Formula;

architecture Moore_FSM of Gen_Addr_Formula is

	-- FSM & Control Signals
	type State is (Idle_Mode , Init , Sft_Sub , Mult , Add , Sub , Final);
	signal S_Curr , S_Next : State;
	
	-- Misc
	signal Even_Curr  , Even_Next  : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Odd_Curr   , Odd_Next   : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal CMin_Curr  , CMin_Next  : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Part1_Curr , Part1_Next : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	signal Part2_Curr , Part2_Next : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');

begin

process (CLK , RESET)
begin
	if (RESET = '1') then
		S_Curr     <= Idle_Mode;
		Even_Curr  <= (others => '0');
		Odd_Curr   <= (others => '0');
		CMin_Curr  <= (others => '0');
		Part1_Curr <= (others => '0');
		Part2_Curr <= (others => '0');
	elsif (rising_edge(CLK)) then
		S_Curr     <= S_Next;
		Even_Curr  <= Even_Next;
		Odd_Curr   <= Odd_Next;
		CMin_Curr  <= CMin_Next;
		Part1_Curr <= Part1_Next;
		Part2_Curr <= Part2_Next;
	end if;
end process;

process (S_Curr , Even_Curr , Odd_Curr , CMin_Curr , Part1_Curr , Part2_Curr , CE , CITIES , CITY_MIN , CITY_MAX)
begin
	
	-- Preventing latches and replacing them with registers
	S_Next     <= S_Curr;
	Even_Next  <= Even_Curr;
	Odd_Next   <= Odd_Curr;
	CMin_Next  <= CMin_Curr;
	Part1_Next <= Part1_Curr;
	Part2_Next <= Part2_Curr;

	-- Default assignments to prevent latches
	ADDR_FORMULA <= (others => '0');
	DONE <= '0';
	
	-- Formula: (CITY_MIN-1)*CITIES + CITY_MAX - ((CITY_MIN+1)*CITY_MIN)/2
	-- Part1  : (CITY_MIN-1)*CITIES + CITY_MAX
	-- Part2  : ((CITY_MIN+1)*CITY_MIN)/2;
	-- Result : Part1 - Part2
	
	case S_Curr is
		when Idle_Mode =>
								if (CE = '1' and CITY_MIN > Zero and CITY_MAX > Zero) then
									S_Next <= Init;
								else
									S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
								end if;
							
		when Init      =>
								if (CITY_MIN(0) = '0') then
									Even_Next <= CITY_MIN;
									Odd_Next  <= CITY_MIN + 1;
								else
									Even_Next <= CITY_MIN + 1;
									Odd_Next  <= CITY_MIN;
								end if;
								S_Next <= Sft_Sub;
		
		when Sft_Sub   =>
								Even_Next <= '0' & Even_Curr(DATA_WIDTH-1 downto 1);
								CMin_Next <= CITY_MIN - 1;
								S_Next <= Mult;
		
		when Mult 	   =>
								Part2_Next <= conv_std_logic_vector (conv_integer(Even_Curr) * conv_integer(Odd_Curr) , ADDR_WIDTH);
								Part1_Next <= conv_std_logic_vector (conv_integer(CMin_Curr) * conv_integer(CITIES)   , ADDR_WIDTH);
								S_Next <= Add;
		
		when Add 	   =>
								Part1_Next <= Part1_Curr + CITY_MAX;
								S_Next <= Sub;
		
		when Sub 	   =>
								ADDR_FORMULA <= Part1_Curr - Part2_Curr;
								S_Next <= Final;
						  
		when Final 	   =>
								DONE <= '1';
								ADDR_FORMULA <= Part1_Curr - Part2_Curr;
								if (CE = '0') then
									S_Next <= Idle_Mode;
								else
									S_Next <= Final; -- Redundant, only for clarification purposes
								end if;
	end case;
end process;

end Moore_FSM;
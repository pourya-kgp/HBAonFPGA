----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Flipflop_T_Async
-- Module Name      : Flipflop_T_Async
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : T Flip-Flop with asynchronous reset
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 721 MHz
-- Area  Estimation : 1 LUTs + 1 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Flipflop_T_Async is
	port (
			CLK    : in    std_logic;
			RESET  : in    std_logic;
			INPUT  : in    std_logic;
			OUTPUT : inout std_logic := '0');
end Flipflop_T_Async;

architecture Behavioral of Flipflop_T_Async is
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			OUTPUT <= '0';
		elsif (rising_edge(CLK)) then
			if (INPUT = '1') then
				OUTPUT <= not(OUTPUT);
			end if;
		end if;
	end process;
	
end Behavioral;
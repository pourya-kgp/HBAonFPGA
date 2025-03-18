----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Bit_Flipflop_D_Async_FallEdge
-- Module Name      : Bit_Flipflop_D_Async_FallEdge
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : 1-Bit D Flip-Flop with asynchronous reset, which responds to the falling edge of the clock
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Bit_Flipflop_D_Async_FallEdge is
	port (
			CLK   : in  std_logic;
			RESET : in  std_logic;
			D_IN  : in  std_logic;
			D_OUT : out std_logic := '0');
end Bit_Flipflop_D_Async_FallEdge;

architecture Behavioral of Bit_Flipflop_D_Async_FallEdge is
begin

	process (CLK , RESET)
	begin
		if (RESET = '1') then
			D_OUT <= '0';
		elsif (falling_edge(CLK)) then
			D_OUT <= D_IN;
		end if;
	end process;

end Behavioral;
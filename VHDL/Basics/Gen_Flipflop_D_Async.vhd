----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Flipflop_D_Async
-- Module Name      : Gen_Flipflop_D_Async
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for the D Flip-Flop with asynchronous reset
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

entity Gen_Flipflop_D_Async is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				D_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
				D_OUT      : out std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0'));
end Gen_Flipflop_D_Async;

architecture Behavioral of Gen_Flipflop_D_Async is
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			D_OUT <= (others => '0');
		elsif (rising_edge(CLK)) then
			D_OUT <= D_IN;
		end if;
	end process;

end Behavioral;
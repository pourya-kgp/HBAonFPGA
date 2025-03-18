----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_SR_PIPO
-- Module Name      : Gen_SR_PIPO
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for the Parallel-In and Parallel-Out Shift Register (PIPO SR)
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

entity Gen_SR_PIPO is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				INPUT      : in  std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '1');
				OUTPUT     : out std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '1'));
end Gen_SR_PIPO;

architecture Behavioral of Gen_SR_PIPO is
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			OUTPUT <= (others => '1'); -- Initial Value is Maximum Value
		elsif (rising_edge(CLK)) then
			if (CE = '1') then
				OUTPUT <= INPUT;
			end if;
		end if;
	end process;

end Behavioral;
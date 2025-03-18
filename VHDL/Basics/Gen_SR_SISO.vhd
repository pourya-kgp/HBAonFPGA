----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_SR_SISO
-- Module Name      : Gen_SR_SISO
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for the Serial-In and Serial-Out Shift Register (SISO SR)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 1239 MHz
-- Area  Estimation : 9 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_SR_SISO is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				SR_IN      : in  std_logic;
				SR_OUT     : out std_logic);
end Gen_SR_SISO;

architecture Behavioral of Gen_SR_SISO is

	signal Data : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');

begin

	process (CLK , RESET)
	begin
		if(RESET = '1')then
			SR_OUT <= '0';
			Data   <= (others => '0');
		elsif (rising_edge(CLK)) then
			SR_OUT <= Data(0);
			Data   <= SR_IN & Data(DATA_WIDTH-1 downto 1);
		end if;
	end process;

end Behavioral;
----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Bit_Demux1_2
-- Module Name      : Bit_Demux1_2
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : 1-Bit 1x2 demultiplexer
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 2 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Bit_Demux1_2 is
	port (
			S  : in  std_logic;
			D  : in  std_logic;
			D0 : out std_logic;
			D1 : out std_logic);
end Bit_Demux1_2;

architecture Behavioral of Bit_Demux1_2 is
begin

	process (D , S)
	begin
		case S is
			when '0' =>
								D0 <= D;
								D1 <= '0';
			when '1' =>
								D0 <= '0';
								D1 <= D;
			when others =>
								NULL;
		end case;
	end process;

end Behavioral;
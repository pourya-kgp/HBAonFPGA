----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Demux1_2
-- Module Name      : Gen_Demux1_2
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for 1x2 demultiplexer
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 16 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Demux1_2 is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				S          : in  std_logic;
				D          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				D0         : out std_logic_vector (DATA_WIDTH-1 downto 0);
				D1         : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_Demux1_2;

architecture Behavioral of Gen_Demux1_2 is
begin

	process (D , S)
	begin
		case S is
			when '0'    =>
								D0 <= D;
								D1 <= (others => '0');
			when '1'    =>
								D0 <= (others => '0');
								D1 <= D;
			when others =>
								NULL;
		end case;
	end process;

end Behavioral;
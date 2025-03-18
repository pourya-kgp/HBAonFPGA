----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Edge_Detector
-- Module Name      : Edge_Detector
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : Edge detector based on emission delay technique
-- Comments         : 
-- Dependencies     : Async D Flip-Flop
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 1 LUTs + 1 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Edge_Detector is
	port (
			CLK    : in  std_logic;
			RESET  : in  std_logic;
			EDGE   : in  std_logic;
			DETECT : out std_logic);
end Edge_Detector;

architecture Structural of Edge_Detector is

	---------- Components ----------
	
	component Bit_Flipflop_D_Async is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic);
	end component;
	
	---------- Signals ----------
	
	signal Edge_Late : std_logic := '0';

begin
	
	DETECT <= EDGE and not(Edge_Late);
	
	D_FF_Async: Bit_Flipflop_D_Async
		port map (
					CLK 	=> CLK,
					RESET => RESET,
					D_IN 	=> EDGE,
					D_OUT => Edge_Late);
	
end Structural;
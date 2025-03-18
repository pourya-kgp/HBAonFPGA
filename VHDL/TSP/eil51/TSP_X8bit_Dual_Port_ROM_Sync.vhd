----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : TSP_X_Dual_Port_ROM_Sync
-- Module Name      : TSP_X_Dual_Port_ROM_Sync
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Dual-port ROM with synchronous read (Block RAM)
-- Comments         : eil51 Database X Coordinates
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation :   RAM/FIFO
-- Tools            : ISE Design Suite v14.7 - Altera Quartus 16.1 Lite
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2024/07/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TSP_X_Dual_Port_ROM_Sync is
	generic (
				ADDR_WIDTH : natural := 8;
				DATA_WIDTH : natural := 8);
	port    (
				CLK        : in  std_logic;
				ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
				ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
				DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
				DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
end TSP_X_Dual_Port_ROM_Sync;

architecture Behavioral of TSP_X_Dual_Port_ROM_Sync is

	type ROM_Type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal ROM : ROM_Type := (
			"00011110" , -- ADDR 0
			"00100101" , -- ADDR 1
			"00110001" , -- ADDR 2
			"00110100" , -- ADDR 3
			"00010100" , -- ADDR 4
			"00101000" , -- ADDR 5
			"00010101" , -- ADDR 6
			"00010001" , -- ADDR 7
			"00011111" , -- ADDR 8
			"00110100" , -- ADDR 9
			"00110011" , -- ADDR 10
			"00101010" , -- ADDR 11
			"00011111" , -- ADDR 12
			"00000101" , -- ADDR 13
			"00001100" , -- ADDR 14
			"00100100" , -- ADDR 15
			"00110100" , -- ADDR 16
			"00011011" , -- ADDR 17
			"00010001" , -- ADDR 18
			"00001101" , -- ADDR 19
			"00111001" , -- ADDR 20
			"00111110" , -- ADDR 21
			"00101010" , -- ADDR 22
			"00010000" , -- ADDR 23
			"00001000" , -- ADDR 24
			"00000111" , -- ADDR 25
			"00011011" , -- ADDR 26
			"00011110" , -- ADDR 27
			"00101011" , -- ADDR 28
			"00111010" , -- ADDR 29
			"00111010" , -- ADDR 30
			"00100101" , -- ADDR 31
			"00100110" , -- ADDR 32
			"00101110" , -- ADDR 33
			"00111101" , -- ADDR 34
			"00111110" , -- ADDR 35
			"00111111" , -- ADDR 36
			"00100000" , -- ADDR 37
			"00101101" , -- ADDR 38
			"00111011" , -- ADDR 39
			"00000101" , -- ADDR 40
			"00001010" , -- ADDR 41
			"00010101" , -- ADDR 42
			"00000101" , -- ADDR 43
			"00011110" , -- ADDR 44
			"00100111" , -- ADDR 45
			"00100000" , -- ADDR 46
			"00011001" , -- ADDR 47
			"00011001" , -- ADDR 48
			"00110000" , -- ADDR 49
			"00111000" , -- ADDR 50
			"00000000" , -- ADDR 51
			"00000000" , -- ADDR 52
			"00000000" , -- ADDR 53
			"00000000" , -- ADDR 54
			"00000000" , -- ADDR 55
			"00000000" , -- ADDR 56
			"00000000" , -- ADDR 57
			"00000000" , -- ADDR 58
			"00000000" , -- ADDR 59
			"00000000" , -- ADDR 60
			"00000000" , -- ADDR 61
			"00000000" , -- ADDR 62
			"00000000" , -- ADDR 63
			"00000000" , -- ADDR 64
			"00000000" , -- ADDR 65
			"00000000" , -- ADDR 66
			"00000000" , -- ADDR 67
			"00000000" , -- ADDR 68
			"00000000" , -- ADDR 69
			"00000000" , -- ADDR 70
			"00000000" , -- ADDR 71
			"00000000" , -- ADDR 72
			"00000000" , -- ADDR 73
			"00000000" , -- ADDR 74
			"00000000" , -- ADDR 75
			"00000000" , -- ADDR 76
			"00000000" , -- ADDR 77
			"00000000" , -- ADDR 78
			"00000000" , -- ADDR 79
			"00000000" , -- ADDR 80
			"00000000" , -- ADDR 81
			"00000000" , -- ADDR 82
			"00000000" , -- ADDR 83
			"00000000" , -- ADDR 84
			"00000000" , -- ADDR 85
			"00000000" , -- ADDR 86
			"00000000" , -- ADDR 87
			"00000000" , -- ADDR 88
			"00000000" , -- ADDR 89
			"00000000" , -- ADDR 90
			"00000000" , -- ADDR 91
			"00000000" , -- ADDR 92
			"00000000" , -- ADDR 93
			"00000000" , -- ADDR 94
			"00000000" , -- ADDR 95
			"00000000" , -- ADDR 96
			"00000000" , -- ADDR 97
			"00000000" , -- ADDR 98
			"00000000" , -- ADDR 99
			"00000000" , -- ADDR 100
			"00000000" , -- ADDR 101
			"00000000" , -- ADDR 102
			"00000000" , -- ADDR 103
			"00000000" , -- ADDR 104
			"00000000" , -- ADDR 105
			"00000000" , -- ADDR 106
			"00000000" , -- ADDR 107
			"00000000" , -- ADDR 108
			"00000000" , -- ADDR 109
			"00000000" , -- ADDR 110
			"00000000" , -- ADDR 111
			"00000000" , -- ADDR 112
			"00000000" , -- ADDR 113
			"00000000" , -- ADDR 114
			"00000000" , -- ADDR 115
			"00000000" , -- ADDR 116
			"00000000" , -- ADDR 117
			"00000000" , -- ADDR 118
			"00000000" , -- ADDR 119
			"00000000" , -- ADDR 120
			"00000000" , -- ADDR 121
			"00000000" , -- ADDR 122
			"00000000" , -- ADDR 123
			"00000000" , -- ADDR 124
			"00000000" , -- ADDR 125
			"00000000" , -- ADDR 126
			"00000000" , -- ADDR 127
			"00000000" , -- ADDR 128
			"00000000" , -- ADDR 129
			"00000000" , -- ADDR 130
			"00000000" , -- ADDR 131
			"00000000" , -- ADDR 132
			"00000000" , -- ADDR 133
			"00000000" , -- ADDR 134
			"00000000" , -- ADDR 135
			"00000000" , -- ADDR 136
			"00000000" , -- ADDR 137
			"00000000" , -- ADDR 138
			"00000000" , -- ADDR 139
			"00000000" , -- ADDR 140
			"00000000" , -- ADDR 141
			"00000000" , -- ADDR 142
			"00000000" , -- ADDR 143
			"00000000" , -- ADDR 144
			"00000000" , -- ADDR 145
			"00000000" , -- ADDR 146
			"00000000" , -- ADDR 147
			"00000000" , -- ADDR 148
			"00000000" , -- ADDR 149
			"00000000" , -- ADDR 150
			"00000000" , -- ADDR 151
			"00000000" , -- ADDR 152
			"00000000" , -- ADDR 153
			"00000000" , -- ADDR 154
			"00000000" , -- ADDR 155
			"00000000" , -- ADDR 156
			"00000000" , -- ADDR 157
			"00000000" , -- ADDR 158
			"00000000" , -- ADDR 159
			"00000000" , -- ADDR 160
			"00000000" , -- ADDR 161
			"00000000" , -- ADDR 162
			"00000000" , -- ADDR 163
			"00000000" , -- ADDR 164
			"00000000" , -- ADDR 165
			"00000000" , -- ADDR 166
			"00000000" , -- ADDR 167
			"00000000" , -- ADDR 168
			"00000000" , -- ADDR 169
			"00000000" , -- ADDR 170
			"00000000" , -- ADDR 171
			"00000000" , -- ADDR 172
			"00000000" , -- ADDR 173
			"00000000" , -- ADDR 174
			"00000000" , -- ADDR 175
			"00000000" , -- ADDR 176
			"00000000" , -- ADDR 177
			"00000000" , -- ADDR 178
			"00000000" , -- ADDR 179
			"00000000" , -- ADDR 180
			"00000000" , -- ADDR 181
			"00000000" , -- ADDR 182
			"00000000" , -- ADDR 183
			"00000000" , -- ADDR 184
			"00000000" , -- ADDR 185
			"00000000" , -- ADDR 186
			"00000000" , -- ADDR 187
			"00000000" , -- ADDR 188
			"00000000" , -- ADDR 189
			"00000000" , -- ADDR 190
			"00000000" , -- ADDR 191
			"00000000" , -- ADDR 192
			"00000000" , -- ADDR 193
			"00000000" , -- ADDR 194
			"00000000" , -- ADDR 195
			"00000000" , -- ADDR 196
			"00000000" , -- ADDR 197
			"00000000" , -- ADDR 198
			"00000000" , -- ADDR 199
			"00000000" , -- ADDR 200
			"00000000" , -- ADDR 201
			"00000000" , -- ADDR 202
			"00000000" , -- ADDR 203
			"00000000" , -- ADDR 204
			"00000000" , -- ADDR 205
			"00000000" , -- ADDR 206
			"00000000" , -- ADDR 207
			"00000000" , -- ADDR 208
			"00000000" , -- ADDR 209
			"00000000" , -- ADDR 210
			"00000000" , -- ADDR 211
			"00000000" , -- ADDR 212
			"00000000" , -- ADDR 213
			"00000000" , -- ADDR 214
			"00000000" , -- ADDR 215
			"00000000" , -- ADDR 216
			"00000000" , -- ADDR 217
			"00000000" , -- ADDR 218
			"00000000" , -- ADDR 219
			"00000000" , -- ADDR 220
			"00000000" , -- ADDR 221
			"00000000" , -- ADDR 222
			"00000000" , -- ADDR 223
			"00000000" , -- ADDR 224
			"00000000" , -- ADDR 225
			"00000000" , -- ADDR 226
			"00000000" , -- ADDR 227
			"00000000" , -- ADDR 228
			"00000000" , -- ADDR 229
			"00000000" , -- ADDR 230
			"00000000" , -- ADDR 231
			"00000000" , -- ADDR 232
			"00000000" , -- ADDR 233
			"00000000" , -- ADDR 234
			"00000000" , -- ADDR 235
			"00000000" , -- ADDR 236
			"00000000" , -- ADDR 237
			"00000000" , -- ADDR 238
			"00000000" , -- ADDR 239
			"00000000" , -- ADDR 240
			"00000000" , -- ADDR 241
			"00000000" , -- ADDR 242
			"00000000" , -- ADDR 243
			"00000000" , -- ADDR 244
			"00000000" , -- ADDR 245
			"00000000" , -- ADDR 246
			"00000000" , -- ADDR 247
			"00000000" , -- ADDR 248
			"00000000" , -- ADDR 249
			"00000000" , -- ADDR 250
			"00000000" , -- ADDR 251
			"00000000" , -- ADDR 252
			"00000000" , -- ADDR 253
			"00000000" , -- ADDR 254
			"00000000"   -- ADDR 255
			);
			
begin
	
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			-- In the case of Altera Quartus, it is extremely essential that the output assignment stays in the process.
			-- Otherwise, Altera Quartus will not infer the VHDL code as ROM.
			-- However, in the case of Xilinx ISE, it does not matter whether the output assignment stays in the process
			-- or outside of it with synchronization to the clock pulse by another signal. The VHDL code will infer as ROM anyway.
			DOUT_A <= ROM (to_integer(unsigned(ADDR_A)));
			DOUT_B <= ROM (to_integer(unsigned(ADDR_B)));
		end if;
	end process;
	
end Behavioral;

-- Extremely important: In order for Altera Quartus to infer the VHDL code as ROM, the setting in the path
-- "Assignments/Device…/Device and Pin Options…/Configuration/Configuration mode" must be changed to
-- "Single Uncompressed Image with memory initialization (512 Kbits UFM)".
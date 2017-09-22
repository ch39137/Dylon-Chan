/*----------------------------------------------------------
Author					:				Dylon Chan
E-mail					:				chenh@sari.ac.cn
Filename					:				DVI_GVGA.v
Date						:				2017-09-22
Description				:				DVI_VGA display
Modification history	:
Data				By				Version			Change Description
============================================================
2017/09/22		Dylon Chan	1.0				Original
------------------------------------------------------------*/ 

`timescale 1ns/1ns

module DVI_VGA
(
	//global clock 50MHz
	input					iCLK,				//25MHz
	input					iRST_N,			//global reset
	
	//user interface
	output				oDVI_TX_CLK,	//DVI clock
	output				oDVI_TX_HS,
	output				oDVI_TX_VS,
	output				oDVI_TX_DE,
	output				oDVI_TX_ISEL,
	output				oDVI_TX_SCL,
	output				oDVI_TX_HTPLG,
	output				oDVI_TX_SDA,
	output				oDVI_TX_PD_n,
	output	[23:0]	oDVI_TX_DATA
);

//----------------------------------
//sync global clock and reset signal
wire clk_vga;
wire sys_rst_n;

system_ctrl_pll u_system_ctrl_pll(
	.areset			(~iRST_N),		//global reset
	.inclk0			(iCLK),			//25MHz
	.c0				(clk_vga),		//vga clock
	.locked			(sys_rst_n)		//reset
);


//-------------------------------------
//LCD driver timing
wire	[10:0]	lcd_xpos;		//lcd horizontal coordinate
wire	[10:0]	lcd_ypos;		//lcd vertical coordinate
wire	[23:0]	lcd_data;		//lcd data
lcd_driver u_lcd_driver
(
	//global clock
	.iCLK				(clk_vga),		
	.iRST_N			(sys_rst_n), 
	 
	 //lcd interface
	.lcd_dclk		(oDVI_TX_CLK),
	.lcd_blank		(),
	.lcd_sync		(),		    	
	.lcd_hs			(oDVI_TX_HS),		
	.lcd_vs			(oDVI_TX_VS),
	.lcd_en			(oDVI_TX_DE),
	.lcd_rgb			(oDVI_TX_DATA),

	//user interface
	.lcd_request	(),
	.lcd_data		(lcd_data),	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos)
);

//-------------------------------------
//lcd data simulation
lcd_display	u_lcd_display
(
	//global clock
	.iCLK				(clk_vga),		
	.iRST_N			(sys_rst_n), 
	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos),
	.lcd_data		(lcd_data)
);

assign   oDVI_TX_ISEL	= 1'b0;
assign   oDVI_TX_SCL		= 1'b1;
assign   oDVI_TX_HTPLG	= 1'b1;
assign   oDVI_TX_SDA		= 1'b1;
assign   oDVI_TX_PD_n	= 1'b1;

endmodule

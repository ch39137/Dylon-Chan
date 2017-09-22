/*----------------------------------------------------------
Author					:				Dylon Chan
E-mail					:				chenh@sari.ac.cn
Filename					:				lcd_display.v
Date						:				2017-09-22
Description				:				LCD/VGA display simulation
Modification history	:
Data				By				Version			Change Description
============================================================
2017/09/22		Dylon Chan	1.0				Original
------------------------------------------------------------*/

`timescale 1ns/1ns
module lcd_display
(
	input						iCLK,			//system clock
	input						iRST_N,		//sync clock
	
	input			[10:0]	lcd_xpos,	//lcd horizontal coordinate
	input			[10:0]	lcd_ypos,	//lcd vertical coordinate
	output	 	[23:0]	lcd_data		//lcd data
);

//----------------------------------------------------------
//call rom module
//wire 			[7:0]		image_data;
wire			[23:0]	image_data;
wire			[18:0]	addr;			//640*480
//wire			[19:0]	addr;		//1024*768

assign  addr = lcd_xpos + lcd_ypos * 11'd640;	//640*480
//assign addr = lcd_xpos + lcd_ypos * 11'd1024;	//1024*768
image_rom	u_image_rom_red(
					.address			(addr),
					.clock			(iCLK),
					.q					(image_data)
);


//----------------------------------------------------------
//lcd data output
assign lcd_data = image_data; //{ image_data, image_data, image_data };

endmodule

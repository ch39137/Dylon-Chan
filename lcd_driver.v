/*----------------------------------------------------------
Author					:				Dylon Chan
E-mail					:				chenh@sari.ac.cn
Filename					:				lcd_driver.v
Date						:				2017-09-22
Description				:				LCD/VGA driver
Modification history	:
Data				By				Version			Change Description
============================================================
2017/09/22		Dylon Chan	1.0				Original
------------------------------------------------------------*/

`timescale 1ns/1ns
`include		"lcd_param.v"

module lcd_driver
(
	//global clock
	input					iCLK,				//system clock
	input					iRST_N,			//sync reset
	
	//lcd interface
	output				lcd_dclk,		//lck pixel clock
	output				lcd_blank,		//lcd bank
	output				lcd_sync,		//lcd sync
	output				lcd_hs,	   	//lcd horizontal sync
	output				lcd_vs,	   	//lcd vertical sync
	output				lcd_en,			//lcd display enable
	output	[23:0]	lcd_rgb,			//lcd display data
	
	//user interface
	input		[23:0]	lcd_data,		//lcd data
	
	output				lcd_request,	//lcd data request
	output	[10:0]	lcd_xpos,		//lcd horizontal coordinate
	output	[10:0]	lcd_ypos			//lcd	vertical	coordinate
);

/*******************************************
		SYNC--BACK--DISP--FRONT
*******************************************/
//------------------------------------------
//h_sync counter & generator
reg [10:0] hcnt; 

always @ (posedge iCLK or negedge iRST_N)
begin
	if (!iRST_N)
		hcnt <= 11'd0;
	else
		begin
        if(hcnt < `H_TOTAL - 1'b1)		//line over			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 11'd0;
		end
end 
assign	lcd_hs = (hcnt <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//v_sync counter & generator
reg [10:0] vcnt;

always@(posedge iCLK or negedge iRST_N)
begin
	if (!iRST_N)
		vcnt <= 11'b0;
	else if(hcnt == `H_TOTAL - 1'b1)		//line over
		begin
		if(vcnt < `V_TOTAL - 1'b1)			//frame over
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= 11'd0;
		end
end
assign	lcd_vs = (vcnt <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
assign	lcd_dclk = ~iCLK;
assign	lcd_blank = lcd_hs & lcd_vs;		
assign	lcd_sync = 1'b0;


//-----------------------------------------
assign	lcd_en =	(hcnt >= `H_SYNC + `H_BACK  && hcnt < `H_SYNC + `H_BACK + `H_DISP) &&
						(vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;
assign	lcd_rgb = lcd_en ? lcd_data : 24'h000000;	//ffffff;



//------------------------------------------
//ahead x clock
localparam	H_AHEAD = 	11'd1;

assign lcd_request = (hcnt >= `H_SYNC + `H_BACK - H_AHEAD && hcnt < `H_SYNC + `H_BACK + `H_DISP - H_AHEAD) &&
							(vcnt >= `V_SYNC + `V_BACK && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
							? 1'b1 : 1'b0;
//lcd xpos & ypos
assign	lcd_xpos	= 	lcd_request ? (hcnt - (`H_SYNC + `H_BACK - H_AHEAD)) : 11'd0;
assign	lcd_ypos	= 	lcd_request ? (vcnt - (`V_SYNC + `V_BACK)) : 11'd0;


endmodule

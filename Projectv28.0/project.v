`timescale 1ns / 1ns
`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"

module project(
	CLOCK_50,						//	On Board 50 MHz
	KEY,
	SW,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK,						//	VGA BLANK
	VGA_SYNC,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   							//	VGA Blue[9:0]
	);
   output [6:0] HEX0;
	 output [6:0] HEX1;
	    output [6:0] HEX2;
	 output [6:0] HEX3;
	    output [6:0] HEX4;
	 output [6:0] HEX5;
	 
	input	CLOCK_50;				//	50 MHz
	input [9:0] SW;
	input [3:0] KEY;
	output VGA_CLK;   			//	VGA Clock
	output VGA_HS;					//	VGA H_SYNC
	output VGA_VS;					//	VGA V_SYNC
	output VGA_BLANK;				//	VGA BLANK
	output VGA_SYNC;				//	VGA SYNC
	output [9:0] VGA_R;   		//	VGA Red[9:0]
	output [9:0] VGA_G;	 		//	VGA Green[9:0]
	output [9:0] VGA_B;   		//	VGA Blue[9:0]
	
	wire resetn;
	wire ld_x;
	wire [4:0] ctr_en;
	wire [7:0] ctr_block;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire [7:0] x_ini;
	wire [6:0] y_ini;
	
	wire writeEn;
	wire clk;
	wire clk_block;
	wire [3:0] random_first;
	wire [3:0] random_second;
	wire [15:0] Blackcounter;
	
	assign resetn = KEY[0];
	assign left = ~KEY[2];
	assign right = ~KEY[1];
	reg [7:0] XPos;
	reg [6:0] YPos;
	reg [2:0] colorIn = 3'b110;
	reg [2:0] colour_block = 3'b100;
	reg leftTemp = 1'b0;
	reg rightTemp = 1'b0;
	reg bothTemp = 1'b0;
	reg neitherTemp = 1'b0;
	reg blockTemp = 8'b00000000;
	reg block_go = 1'b0;
	reg [23:0] score;
	wire [7:0] xblockout;
	wire [6:0] yblockout;
	wire [1:0] mode;
	reg endgame;
	
	reg [14:0] block1 = 15'b010100001010000;// x : first 8 bits  y: second 7 bits
	reg [14:0] block2 = 15'b001010000000100;
	reg [14:0] block3 = 15'b011000000101000;
	reg [14:0] block4 = 15'b101000001010010;
	reg [14:0] block5 = 15'b000100001001100;
	reg [14:0] block6 = 15'b010000000110010;
	reg [14:0] block7 = 15'b001000000010010;
	reg [14:0] block8 = 15'b011111100001100;
	RateDivider r1(
		.q(clk),
		.clock(CLOCK_50)); 

	RateDivider_block r2(
		.q(clk_block),
		.clock(CLOCK_50)); 

always@(posedge clk_block)
	begin
		if (blockTemp == 8'b00000000)
			begin
			block_go <= 1'b1;
			colour_block <= 3'b000;
			blockTemp <= blockTemp + 8'b00000001;
			end
		else if (blockTemp == 8'b00000001)
			begin
			block_go <= 1'b0;
			block1 <= block1 - 15'b000000000000001; // moving the block upwords
			block2 <= block2 - 15'b000000000000001;
			block3 <= block3 - 15'b000000000000001; // moving the block upwords
			block4 <= block4 - 15'b000000000000001;
			block5 <= block5 - 15'b000000000000001; // moving the block upwords
			block6 <= block6 - 15'b000000000000001;
			block7 <= block7 - 15'b000000000000001; // moving the block upwords
			block8 <= block8 - 15'b000000000000001;
			blockTemp <= blockTemp + 8'b00000001;
			colour_block <= 3'b100;
			end
		else if (blockTemp == 8'b00000010)
			begin
				block_go <= 1'b1;
				blockTemp <= blockTemp + 8'b00000001;
				colour_block <= 3'b100;
			end
		else if(blockTemp == 8'b00000011)
			begin
				block_go <= 1'b0;
				colour_block <= 3'b100;
				blockTemp <= 8'b00000000;
			end	
	end
	
always@(posedge clk)
	begin
		if (resetn == 1'b0)
		begin
			XPos <= 8'b01010000;
			YPos <= 7'b0000111;
			endgame <= 1'b0;
			score <= 24'b000000000000000000000000;
		end
		
		if (endgame == 1'b0)
		begin
			score <= score + 24'b000000000000000000000001;
			if (score == 24'b000000000000111111111111)
			       score <=24'b000000000000111111111111;
					 
			if (resetn == 1'b0)
				begin
					XPos <= 8'b01010000;
					YPos <= 7'b0000111;
					endgame <= 1'b0;
					score <= 24'b000000000000000000000000;
				end
			if (
			(XPos >= block1[14:7] -8'b00000100) 
			&& (XPos <= (block1[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block1[6:0] - 7'b0000011)) 
			&& (YPos > (block1[6:0] - 7'b0001000)) 
			||
			(XPos >= block2[14:7] -8'b00000100) 
			&& (XPos <= (block2[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block2[6:0] - 7'b0000011)) 
			&& (YPos > (block2[6:0] - 7'b0001000)) 
			||
			(XPos >= block3[14:7] -8'b00000100) 
			&& (XPos <= (block3[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block3[6:0] - 7'b0000011)) 
			&& (YPos > (block3[6:0] - 7'b0001000)) 
			||
			(XPos >= block4[14:7] -8'b00000100) 
			&& (XPos <= (block4[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block4[6:0] - 7'b0000011)) 
			&& (YPos > (block4[6:0] - 7'b0001000)) 
			||
			(XPos >= block5[14:7] -8'b00000100) 
			&& (XPos <= (block5[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block5[6:0] - 7'b0000011)) 
			&& (YPos > (block5[6:0] - 7'b0001000)) 
			||
			(XPos >= block6[14:7] -8'b00000100) 
			&& (XPos <= (block6[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block6[6:0] - 7'b0000011)) 
			&& (YPos > (block6[6:0] - 7'b0001000)) 
			||
			(XPos >= block7[14:7] -8'b00000100) 
			&& (XPos <= (block7[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block7[6:0] - 7'b0000011)) 
			&& (YPos > (block7[6:0] - 7'b0001000)) 
			||
			(XPos >= block8[14:7] -8'b00000100) 
			&& (XPos <= (block8[14:7] + 8'b00001111 + 8'b00000001)) 
			&& (YPos < (block8[6:0] - 7'b0000011)) 
			&& (YPos > (block8[6:0] - 7'b0001000)) 
			)
			begin
				  // on the block: not pressing anything, the character moves with block
				if (left == 1'b0 && right == 1'b0)
					begin
						XPos <= XPos;
						YPos <= YPos;
						colorIn <= 3'b000;
						neitherTemp <= 1'b1;
					end
				if( neitherTemp == 1'b1)
					begin
						XPos <= XPos;
						YPos <= YPos - 7'b0000001;
						colorIn <= 3'b110;
						neitherTemp <= 1'b0;
					end
					
					//on the block: not only change x, but also change y due to moving block
				if (left == 1'b1 && right == 1'b1)
						begin
						
						colorIn <= 3'b000;
						bothTemp <= 1'b1;
					end
				if( bothTemp == 1'b1)
					begin
						XPos <= XPos;
						YPos <= YPos -7'b0000001;
						colorIn <= 3'b110;
						bothTemp <= 1'b0;
					end
				if (left == 1'b1)
				begin
					XPos <= XPos;
					YPos <= YPos;
					colorIn <= 3'b000;
					leftTemp <= 1'b1;
				end
				if (leftTemp == 1'b1)
				begin
					XPos <= XPos - 8'b00000100;
					YPos <= YPos - 7'b0000001;
					colorIn <= 3'b110;
					leftTemp <= 1'b0;
				end
				
				if (right == 1'b1)
				begin
					XPos <= XPos;
					YPos <= YPos;
					colorIn <= 3'b000;
					rightTemp <= 1'b1;
				end
				if (rightTemp == 1'b1)
				begin
					XPos <= XPos + 8'b00000100;
					YPos <= YPos - 7'b0000001;
					colorIn <= 3'b110;
					rightTemp <= 1'b0;
				end
			end
			
	 
			else 
			
			begin
				if (resetn == 1'b0)
				begin
					XPos <= 8'b01010000;
					YPos <= 7'b0000111;
					endgame <= 1'b0;
					score <= 24'b000000000000000000000000;
				end
				// not on the block: both x and y change			
				if (left == 1'b0 && right == 1'b0)
					begin
						colorIn <= 3'b000;
						neitherTemp <= 1'b1;
					end
				if( neitherTemp == 1'b1)
					begin
						XPos <= XPos;
						YPos <= YPos + 7'b0000100;
						colorIn <= 3'b110;
						neitherTemp <= 1'b0;
					end
					//on the block: not only change x, but also change y due to moving block
				if (left == 1'b1 && right == 1'b1)
						begin
						colorIn <= 3'b000;
						bothTemp <= 1'b1;
					end
				if( bothTemp == 1'b1)
					begin
						YPos <= YPos + 7'b0000100;
						colorIn <= 3'b110;
						bothTemp <= 1'b0;
					end
				if (left == 1'b1)
				begin
					colorIn <= 3'b000;
					leftTemp <= 1'b1;
				end
				
				if (leftTemp == 1'b1)
				begin
					XPos <= XPos - 8'b00000100;
					YPos <= YPos + 7'b0000100;
					colorIn <= 3'b110;
					leftTemp <= 1'b0;
				end
				
				if (right == 1'b1)
				begin
					colorIn <= 3'b000;
					rightTemp <= 1'b1;
				end
				if (rightTemp == 1'b1)
				begin
					XPos <= XPos + 8'b00000100;
					YPos <= YPos + 7'b0000100;
					colorIn <= 3'b110;
					rightTemp <= 1'b0;
				end
			end
		end

		if( YPos == 7'b0000100 || YPos >= 7'b1110101)
			begin 
						//XPos <= 8'b01010000;
						//YPos <= 7'b0000111;
						endgame <= 1'b1;
			end 
		

	end
	// Random position generator 
/*	lfsr generator_one(
						.out(random_first),
						.clk(CLOCK_50),
						.reset(right));
	lfsr generator_two(
						.out(random_second),
						.clk(CLOCK_50),
						.reset(right));
	*/

	
   // Instantiate FSM control

	
	controller c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(left || right || block_go),
		.over(endgame),
		.XBlock1(block1[14:7]),
		.YBlock1(block1[6:0]),
		.XBlock2(block2[14:7]),
		.YBlock2(block2[6:0]),
		.XBlock3(block3[14:7]),
		.YBlock3(block3[6:0]),
		.XBlock4(block4[14:7]),
		.YBlock4(block4[6:0]),
		.XBlock5(block5[14:7]),
		.YBlock5(block5[6:0]),
		.XBlock6(block6[14:7]),
		.YBlock6(block6[6:0]),
		.XBlock7(block7[14:7]),
		.YBlock7(block7[6:0]),
		.XBlock8(block8[14:7]),
		.YBlock8(block8[6:0]),
		.plot(writeEn),
		.counter(ctr_en),
		.counterBlock(ctr_block),
		.XBlockOut(xblockout),
		.YBlockOut(yblockout),
		.modeOut(mode),
		.blackcounter(Blackcounter)
		);
	 
	// Instantiate datapath
   datapath d0(
    .clk(CLOCK_50),
    .resetn(resetn),
	 .XPosition(XPos),
	 .YPosition(YPos),
    .XBlock(xblockout),
	 .YBlock(yblockout),
	 .colorIn(colorIn),
	 .blockIn(colour_block),
	 .counter(ctr_en),
	 .counterBlock(ctr_block),
	 .blackcounter(Blackcounter),
	 .XOut(x), 
	 .YOut(y),
	 .ColorOut(colour),
	 .mode(mode)
    );
	 
	
	// Create an Instance of a VGA controller
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(writeEn),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK),
		.VGA_SYNC(VGA_SYNC),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	hex_decoder h0(	
		.a(score[3]),
		.b(score[2]),
		.c(score[1]),
		.d(score[0]),
		.out0(HEX0[0]),
		.out1(HEX0[1]),
		.out2(HEX0[2]),
		.out3(HEX0[3]),
		.out4(HEX0[4]),
		.out5(HEX0[5]),
		.out6(HEX0[6])
		);
			hex_decoder h1(	
		.a(score[7]),
		.b(score[6]),
		.c(score[5]),
		.d(score[4]),
		.out0(HEX1[0]),
		.out1(HEX1[1]),
		.out2(HEX1[2]),
		.out3(HEX1[3]),
		.out4(HEX1[4]),
		.out5(HEX1[5]),
		.out6(HEX1[6])
		);
			hex_decoder h2(	
		.a(score[11]),
		.b(score[10]),
		.c(score[9]),
		.d(score[8]),
		.out0(HEX2[0]),
		.out1(HEX2[1]),
		.out2(HEX2[2]),
		.out3(HEX2[3]),
		.out4(HEX2[4]),
		.out5(HEX2[5]),
		.out6(HEX2[6])
		);
			hex_decoder h3(	
		.a(score[15]),
		.b(score[14]),
		.c(score[13]),
		.d(score[12]),
		.out0(HEX3[0]),
		.out1(HEX3[1]),
		.out2(HEX3[2]),
		.out3(HEX3[3]),
		.out4(HEX3[4]),
		.out5(HEX3[5]),
		.out6(HEX3[6])
		);
			hex_decoder h4(	
		.a(score[19]),
		.b(score[18]),
		.c(score[17]),
		.d(score[16]),
		.out0(HEX4[0]),
		.out1(HEX4[1]),
		.out2(HEX4[2]),
		.out3(HEX4[3]),
		.out4(HEX4[4]),
		.out5(HEX4[5]),
		.out6(HEX4[6])
		);
			hex_decoder h5(	
		.a(score[23]),
		.b(score[22]),
		.c(score[21]),
		.d(score[20]),
		.out0(HEX5[0]),
		.out1(HEX5[1]),
		.out2(HEX5[2]),
		.out3(HEX5[3]),
		.out4(HEX5[4]),
		.out5(HEX5[5]),
		.out6(HEX5[6])
		);

endmodule

module controller(
    input clk,
    input resetn,
    input go,
	 input over,
    input [7:0] XBlock1,
	 input [6:0] YBlock1,
    input [7:0] XBlock2,
	 input [6:0] YBlock2,
	 input [7:0] XBlock3,
	 input [6:0] YBlock3,
	 input [7:0] XBlock4,
	 input [6:0] YBlock4,
	 input [7:0] XBlock5,
	 input [6:0] YBlock5,
	 input [7:0] XBlock6,
	 input [6:0] YBlock6,
	 input [7:0] XBlock7,
	 input [6:0] YBlock7,
	 input [7:0] XBlock8,
	 input [6:0] YBlock8,
	 
	 output reg plot,
	 output [4:0] counter,
	 output [7:0] counterBlock,
	 output [7:0] XBlockOut,
	 output [6:0] YBlockOut,
	 output [1:0] modeOut,
	 output [15:0] blackcounter
    );

	 reg [4:0] count = 5'b10000;
	 reg [7:0] count_Block = 8'b00000000;
    reg [5:0] current_state, next_state; 
    reg [2:0] control;
	 reg [7:0] xblockout;
 	 reg [7:0] yblockout;
	 reg [15:0] Blacken;
    localparam  STATE1        = 5'd0,
                STATE2	      = 5'd1,
					 STATE3	      = 5'd2, // block 1
                STATE4        = 5'd3,
					 STATE5        = 5'd4, // block 2
					 STATE6        = 5'd5,
					 STATE7	      = 5'd6, // block 3
                STATE8        = 5'd7,
					 STATE9        = 5'd8, // block 4
					 STATE10       = 5'd9,
					 STATE11	      = 5'd10, // block 5
                STATE12       = 5'd11, 
					 STATE13       = 5'd12,// block 6
					 STATE14       = 5'd13,
					 STATE15	      = 5'd14,// block 7
                STATE16       = 5'd15,
					 STATE17       = 5'd16,// block 8
					 STATE18       = 5'd17,
					 STATE19       = 5'd18,
					 BLACKEN1		= 5'd19,
					 BLACKEN2		= 5'd20,
					 ENDGAME			= 5'd21,
					 BLACKEN_INIT	= 5'd22,
					 BLACKEN3		= 5'd23;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
			STATE1: next_state = go ? BLACKEN1 : STATE1;		// Loop in current state until value is input
			BLACKEN1: next_state = (Blacken < 16'b101000001111111) ? BLACKEN1 : BLACKEN_INIT;
			BLACKEN_INIT: next_state = BLACKEN2;
			BLACKEN2: next_state = (Blacken < 16'b011111111111111) ? BLACKEN2 : STATE2;
			STATE2: next_state = (count < 5'b10000) ? STATE2 : STATE3;  	// Loop in current state until go signal goes low
			STATE3: next_state = STATE4;
			STATE4: next_state = ( count_Block < 8'b00001111) ? STATE4 : STATE5;
			STATE5: next_state = STATE6;
         STATE6: next_state = ( count_Block < 8'b00001111) ? STATE6 : STATE7;
			STATE7: next_state = STATE8;
         STATE8: next_state = ( count_Block < 8'b00001111) ? STATE8 : STATE9;
			STATE9: next_state = STATE10;
         STATE10: next_state = ( count_Block < 8'b00001111) ? STATE10: STATE11;
			STATE11: next_state = STATE12;
         STATE12: next_state = ( count_Block < 8'b00001111) ? STATE12: STATE13;
			STATE13: next_state = STATE14;
         STATE14: next_state = ( count_Block < 8'b00001111) ? STATE14: STATE15;
			STATE15: next_state = STATE16;
         STATE16: next_state = ( count_Block < 8'b00001111) ? STATE16: STATE17;
			STATE17: next_state = STATE18;
         STATE18: next_state = ( count_Block < 8'b00001111) ? STATE18: STATE19;
			// The Game Over scene
			STATE19: next_state = ( over ) ? BLACKEN3: STATE1;
			BLACKEN3: next_state = (Blacken < 16'b101000001111111) ? BLACKEN3 : ENDGAME;
			ENDGAME: next_state = ( !resetn )? STATE1 : ENDGAME; // RESET STATE?
			default:     next_state = STATE1;
		endcase
    end // state_table
    // Output logic aka all of our datapath control signals

    always @(posedge clk)
    begin: enable_signals
		  count <= 5'b00000;
		  count_Block <= 8'b0;
        case (current_state)
            STATE1: // Go
					begin
					plot <= 1'b0;
					Blacken <= 16'b0;
					end 
					
				BLACKEN1:
					begin
						plot <= 1'b1;
						control <= 3'b010;
						Blacken <= Blacken + 16'b0000000000000001;
					end
					
				BLACKEN_INIT:
					begin
						plot <= 1'b0;
						Blacken <=  16'b0000000000000000;
					end
				BLACKEN2:
					begin
						plot <= 1'b1;
						control <= 3'b100;
						Blacken <= Blacken + 16'b0000000000000001;
					end
					
				BLACKEN3:
					begin
						plot <= 1'b1;
						control <= 3'b100;
						Blacken <= Blacken + 16'b0000000000000001;
					end		
				
				ENDGAME:
					begin
						plot <= 1'b0;
						//control <= 3'b010;
						//Blacken <= Blacken + 16'b0000000000000001;
					end
            STATE2:
					begin // start counting main character 
					plot <= 1'b1;
					count <= count + 5'b00001;
					control <= 3'b000;
					end
				STATE3: 
					begin 
					count_Block <= 8'b00000000;
					control <= 3'b001;
					end
				STATE4: 
					begin // start counting the block
					 count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock1;
					 yblockout <= YBlock1;	
					control <= 3'b001;
					end
				
				STATE5: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE6: 
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock2;
					 yblockout <= YBlock2;
					control <= 3'b001;
					end
				STATE7: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE8: 
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock3;
					 yblockout <= YBlock3;
					control <= 3'b001;
					end
				STATE9: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE10:
					begin
					 count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock4;
					 yblockout <= YBlock4;
					control <= 3'b001;
					end
				STATE11: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE12:
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock5;
					 yblockout <= YBlock5;
					control <= 3'b001;
					end
				STATE13: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE14:
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock6;
					 yblockout <= YBlock6;
					control <= 3'b001;
					end
				STATE15: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE16: 
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock7;
					 yblockout <= YBlock7;
					control <= 3'b001;
					end
				STATE17: 	
					begin 
				   count_Block <= 8'b0;
					control <= 3'b001;
					end 
				STATE18:
					begin
				 	count <= 5'b10000;
					 plot <= 1'b1;
					 count_Block <= count_Block + 8'b00000001;
					 xblockout <= XBlock8;
					 yblockout <= YBlock8;
					control <= 3'b001;
					end

				 STATE19:
					begin 
					 count_Block <= 8'b0;
					 count <= 5'b0;
					 plot <= 1'b1;
					control <= 3'b000;
					Blacken <= 16'b0;
					end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= STATE1;
        else
            current_state <= next_state;
    end // state_FFS
	 
	 assign counter = count;
	 assign counterBlock = count_Block;
	 assign modeOut = control;
	 assign XBlockOut = xblockout;
	 assign YBlockOut = yblockout;
	 assign blackcounter = Blacken; 

endmodule

module datapath(
    input clk,
    input resetn,
    input [7:0] XPosition,
	 input [6:0] YPosition,
    input [7:0] XBlock,
	 input [6:0] YBlock,
	 input [2:0] colorIn,
	 input [2:0] blockIn,
	 input [4:0] counter, 
	 input [7:0] counterBlock,
	 input [15:0] blackcounter,
	 input [2:0] mode,
	 output reg [7:0] XOut, 
	 output reg [6:0] YOut,
	 output reg [2:0] ColorOut
    );
	
	//reg [4:0] new_counter;
	always@(*) 
	begin
		if(!resetn) 
			begin
			XOut = 8'b0; 
			YOut = 7'b0;
			ColorOut = colorIn;
			end
		else 
			begin

				if (mode == 3'b000)
					begin
						if (counter != 5'b10000 && counterBlock == 8'b00000000) 
							begin
							XOut = XPosition + {6'b0, counter[1:0]};
							YOut = YPosition + {5'b0, counter[3:2]};
							if (counter == 4'b1000 || counter == 4'b1011 || counter == 4'b1101 || counter == 4'b1110)
								 begin
							     ColorOut = 3'b011; // blue
								 end
							else 
								begin
								ColorOut = 3'b110; // yellow
								end
							end
					end
				if (mode == 3'b001)
					begin
						if (counterBlock != 8'b11111111)
							begin
							XOut = XBlock +  counterBlock[7:0]; //{2'b0, counterBlock[7:0]}
							YOut = YBlock;// + {3'b0, counterBlock[3:0]};
							ColorOut = blockIn;
							end
					end
				if (mode == 3'b010)
					begin
							XOut = {blackcounter[14:7]};
							YOut = {blackcounter[6:0]};
							ColorOut = 3'b000;
					end
				if (mode == 3'b011)
					begin
							XOut = {blackcounter[14:7]};
							YOut = {blackcounter[6:0]};
							ColorOut = 3'b000;
					end
//				if (mode == 3'b100)
//					begin
//							XOut = 8'b00101000 + blackcounter[14:7];
//							YOut = {blackcounter[6:0]};
//							ColorOut = 3'b111;
//					end
			end
			
	end
endmodule

module RateDivider( q, clock);
	input clock;
	output reg [28:0] q; // declare q
    reg [28:0] p;
	

	always @(posedge clock) // triggered every time clock rises
	begin
			
		 p <= 28'b0000001011111010111100000111;			

			if (p == 28'b0000000000000000000000000000)
				begin
					q <= 1;
				   p <= 28'b0000001011111010111100000111;				

				end
			else
				begin
					q <= 0;
					p <= p - 28'b0000000000000000000000000001;
				end
		
	end
endmodule


module RateDivider_block( q, clock);
	input clock;
	output reg [28:0] q; // declare q
    reg [28:0] p;
	

	always @(posedge clock) // triggered every time clock rises
	begin
			
		 p <= 28'b0000001011111010111100000111;			

			if (p == 28'b0000000000000000000000000000)
				begin
					q <= 1;
					//p <= 28'b0000001011111010111100000111;		
					p <= 28'b0000000101111101011110000100;

				end
			else
				begin
					q <= 0;
					p <= p - 28'b0000000000000000000000000001;
				end
		
	end
endmodule



module lfsr (
 out,
 clk,
 reset
 );
 output reg [3:0] out;
 wire feedback;
 input clk;
 input reset;
 
 assign feedback = ~(out[3]^ out[2]);
 always@(posedge clk, posedge reset)
 begin 
  if(reset)
      out <= 4'b0;
  else
     out <= {feedback,out[3:1]};
end 
endmodule


module counter(q, Clear_b, Enable, clock);
	input Clear_b, Enable, clock;
	output reg [3:0] q; // declare q
	always @(posedge clock) // triggered every time clock rises
	begin
		if (Clear_b == 1'b0) // when Clear b is 0
			q <= 0; // q is set to 0
		else if (Enable == 1'b1) // increment q only when Enable is 1
			q <= q + 1'b1; // increment q
	end
endmodule


module hex_decoder(a, b, c, d, out0, out1, out2, out3, out4, out5, out6);
	input a,b,c,d;
	output out0,out1,out2,out3,out4,out5,out6;
	assign out0 = ~a&~b&~c&d | ~a&b&~c&~d | a&~b&c&d | a&b&~c&d;
	assign out1 = a&b&c | b&c&~d | a&c&d | a&b&~c&~d | ~a&b&~c&d;
	assign out2 = a&b&c | ~a&~b&c&~d | a&b&~c&~d;
	assign out3 = ~a&~b&~c&d | ~a&b&~c&~d | b&c&d | a&~b&c&~d;
	assign out4 = ~a&d | ~a&b&~c | ~b&~c&d;
	assign out5 = ~a&~b&d | ~a&~b&c | ~a&c&d | a&b&~c&d;
	assign out6 = ~a&~b&~c | ~a&b&c&d | a&b&~c&~d;
endmodule

module mux2to1(x, y, s, m); // 2-1 multiplexer
	input x; //selected when s is 0
	input y; //selected when s is 1
	input s; //select signal
	output m; //output
	assign m = s & y | ~s & x; // OR assign m = s ? y : x;
endmodule 



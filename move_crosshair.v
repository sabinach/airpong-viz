`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:09:20 12/08/2018 
// Design Name: 
// Module Name:    move_crosshair 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Given user button inputs, move the crosshairs in the selected direction.
//
//				   Inputs: user button presses
//				   Outputs: updated xy coordinate locations for the crosshairs
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module move_crosshair(
	input clk, // vsync
	input enable,
	input btn_up_debounced,
	input btn_down_debounced,
	input btn_left_debounced,
	input btn_right_debounced,
	output reg [10:0] x_new = 11'd400,
	output reg [9:0] y_new = 10'd300
	); 
	
	parameter DELTA = 2;
	parameter X_MIN = 0;
	parameter X_MAX = 1023;
	parameter Y_MIN = 0;
	parameter Y_MAX = 767;
	
	// determine if the new coordinate at the next timestep overshoots the video boundaries
	wire overshoot_left, overshoot_right, overshoot_up, overshoot_down;
	assign overshoot_left = btn_left_debounced && (x_new > X_MIN + DELTA) && enable;
	assign overshoot_right = btn_right_debounced && (x_new < X_MAX - DELTA) && enable;
	assign overshoot_up = btn_up_debounced && (y_new > Y_MIN + DELTA) && enable;
	assign overshoot_down = btn_down_debounced && (y_new < Y_MAX - DELTA) && enable;
	
	// if the next move does not overshoot the video boundaries, update the coordinate location
	always @(negedge clk) begin
		case({overshoot_left, overshoot_right})
			2'b00: x_new = x_new;
			2'b01: x_new = x_new + DELTA;
			2'b10: x_new = x_new - DELTA;
			2'b11: x_new = x_new;
		endcase
		case({overshoot_up, overshoot_down})
			2'b00: y_new = y_new;
			2'b01: y_new = y_new + DELTA;
			2'b10: y_new = y_new - DELTA;
			2'b11: y_new = y_new;
		endcase
	end
		
endmodule 

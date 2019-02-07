`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sabina Chen
// 
// Create Date:    14:09:51 12/07/2018 
// Design Name: 
// Module Name:    crosshair 
// Project Name:   AirPong
// Target Devices: 
// Tool versions:  
// Description:    Takes center location coordinates, 
//				   and draws crosshairs that intersect at that location
//
//				   Inputs: xy coordinates
//				   Outputs: updated pixel vga output w/ crosshairs intersecting at the provided xy coordinates
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
		
module crosshair(
    input clk,
    input [10:0] hcount,
    input [9:0] vcount,
	input center_sel, 		// select between movable crosshair, to crosshair following center of object
	 
    input [10:0] x_new_puck,	// manual moving
	input [9:0] y_new_puck,
	input [10:0] x_new_paddle1,
	input [9:0] y_new_paddle1,
	input [10:0] x_new_paddle2,
	input [9:0] y_new_paddle2,
	 
	input [10:0] x_center_puck,	// calculated coordinates by detect_color, center of objects
    input [9:0] y_center_puck,
	input [10:0] x_center_paddle1,
    input [9:0] y_center_paddle1,
	input [10:0] x_center_paddle2,
    input [9:0] y_center_paddle2,
	 
    input [23:0] pixel,
    output [23:0] crosshair_pixel
    );
	 
	parameter MAGENTA = {8'd255,8'd0,8'd255};
	parameter GREEN = {8'd0,8'd255,8'd0};
	parameter BLUE = {8'd0,8'd0,8'd255};
	 
	wire adjustable_puck, adjustable_paddle1, adjustable_paddle2;
	wire centered_puck, centered_paddle1, centered_paddle2;
	wire no_object;
	 
	assign adjustable_puck = (hcount==x_new_puck || vcount==y_new_puck) && center_sel;
	assign adjustable_paddle1 = (hcount==x_new_paddle1 || vcount==y_new_paddle1) && center_sel;
	assign adjustable_paddle2 = (hcount==x_new_paddle2 || vcount==y_new_paddle2) && center_sel;
	 
	assign centered_puck = (hcount==x_center_puck || vcount==y_center_puck) && ~center_sel;
	assign centered_paddle1 = (hcount==x_center_paddle1 || vcount==y_center_paddle1) && ~center_sel;
	assign centered_paddle2 = (hcount==x_center_paddle2 || vcount==y_center_paddle2) && ~center_sel;
	 
	assign no_object = ~(adjustable_puck || adjustable_paddle1 || adjustable_paddle2) && 
								~(centered_puck || centered_paddle1 || centered_paddle2);
	
	// draw crosshairs that align with the center of objects
	assign crosshair_pixel = ((adjustable_puck || centered_puck) ? MAGENTA : 24'b0) |
										((adjustable_paddle1 || centered_paddle1) ? GREEN : 24'b0) |
										((adjustable_paddle2 || centered_paddle2) ? BLUE : 24'b0) |
										((no_object) ? pixel : 24'b0);
	
endmodule

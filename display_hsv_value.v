`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sabina Chen
// 
// Create Date:    14:48:58 12/07/2018 
// Design Name: 
// Module Name:    display_hsv_value 
// Project Name:   AirPong
// Target Devices: 
// Tool versions: 
// Description:    Given a xy pixel coordinate location, output the hsv value for the selected pixel.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
	
module display_hsv_value(
   input clk,
   input [10:0] hcount,
   input [9:0] vcount,
   input [10:0] x_coord,
   input [9:0] y_coord,
   input [23:0] pixel,
   input [23:0] hsv,
   output reg [7:0] h_sel, 
   output reg [7:0] s_sel,
   output reg [7:0] v_sel
   );

   // output the hsv value at the selected xy coordinate
	always @(posedge clk) begin
		if(hcount==x_coord && vcount==y_coord) begin
			h_sel <= hsv[23:16];
			s_sel <= hsv[15:8];
			v_sel <= hsv[7:0];
		end
	end

endmodule

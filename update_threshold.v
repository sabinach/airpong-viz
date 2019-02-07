`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		Sabina Chen
// 
// Create Date:    13:18:18 12/10/2018 
// Design Name: 
// Module Name:    update_threshold 
// Project Name:   AirPong
// Target Devices: 
// Tool versions: 
// Description: 	Update saved hsv theshold value sfor selected objecs based on user button inputs
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module update_threshold #(parameter INITIAL_THRESHOLD = 25, SPEED = 3) (
		input clk, 
		input [1:0] obj_sel,
		input update_value, enable_threshold,
		input btn_enter_pulsed, btn_min_incr_pulsed, btn_min_decr_pulsed, btn_max_incr_pulsed, btn_max_decr_pulsed,
		input [1:0] H, S, V, PUCK, PADDLE1, PADDLE2,
		input [7:0] h_sel, v_sel, s_sel,
		output reg [7:0] h1_min=0, h1_max=0, h2_min=0, h2_max=0, s_min=0, s_max=0, v_min=0, v_max=0
	);
	
	// initialize and update thresholds based on initial crosshair center locations, and then user input
	always @(posedge clk) begin
		// set initial thresholds based on hsv center values, minimum 0, max is 255
		if(enable_threshold && update_value && btn_enter_pulsed) begin
			h1_min <= (h_sel-INITIAL_THRESHOLD<0) ? 8'd0 : (h_sel-INITIAL_THRESHOLD); 
			h1_max <= (h_sel+INITIAL_THRESHOLD>255) ? 8'd255 : (h_sel+INITIAL_THRESHOLD);		
			h2_min <= (h_sel-INITIAL_THRESHOLD<0) ? 8'd0 : (h_sel-INITIAL_THRESHOLD); 
			h2_max <= (h_sel+INITIAL_THRESHOLD>255) ? 8'd255 : (h_sel+INITIAL_THRESHOLD);		
			s_min <= (s_sel-INITIAL_THRESHOLD<0) ? 8'd0 : (s_sel-INITIAL_THRESHOLD);
			s_max <= (s_sel+INITIAL_THRESHOLD>255) ? 8'd255 : (s_sel+INITIAL_THRESHOLD);
			v_min <= (v_sel-INITIAL_THRESHOLD<0) ? 8'd0 : (v_sel-INITIAL_THRESHOLD);
			v_max <= (v_sel+INITIAL_THRESHOLD>255) ? 8'd255 : (v_sel+INITIAL_THRESHOLD);
		end

		// manually update hsv threholds via use button presses
		// HUE
		if (enable_threshold && obj_sel==H && update_value && btn_min_incr_pulsed) begin
			h1_min <= (h1_min+SPEED>255) ? 8'd255 : (h1_min+SPEED);		
			h2_min <= (h2_min+SPEED>255) ? 8'd255 : (h2_min+SPEED);		
		end
		if (enable_threshold && obj_sel==H && update_value && btn_min_decr_pulsed) begin
			h1_min <= (h1_min-SPEED<0) ? 8'd0 : (h1_min-SPEED); 	
			h2_min <= (h2_min-SPEED<0) ? 8'd0 : (h2_min-SPEED); 
		end
		if (enable_threshold && obj_sel==H && update_value && btn_max_incr_pulsed) begin
			h1_max <= (h1_max+SPEED>255) ? 8'd255 : (h1_max+SPEED);		
			h2_max <= (h2_max+SPEED>255) ? 8'd255 : (h2_max+SPEED);	
		end
		if (enable_threshold && obj_sel==H && update_value && btn_max_decr_pulsed) begin
			h1_max <= (h1_max-SPEED<0) ? 8'd0 : (h1_max-SPEED); 	
			h2_max <= (h2_max-SPEED<0) ? 8'd0 : (h2_max-SPEED); 
		end
		// SATURATION
		if (enable_threshold && obj_sel==S && update_value && btn_min_incr_pulsed) begin
			s_min <= (s_min+SPEED>255) ? 8'd255 : (s_min+SPEED);		
		end
		if (enable_threshold && obj_sel==S && update_value && btn_min_decr_pulsed) begin
			s_min <= (s_min-SPEED<0) ? 8'd0 : (s_min-SPEED); 
		end
		if (enable_threshold && obj_sel==S && update_value && btn_max_incr_pulsed) begin
			s_max <= (s_max+SPEED>255) ? 8'd255 : (s_max+SPEED);		
		end
		if (enable_threshold && obj_sel==S && update_value && btn_max_decr_pulsed) begin
			s_max <= (s_max-SPEED<0) ? 8'd0 : (s_max-SPEED); 	
		end
		// VALUE
		if (enable_threshold && obj_sel==V && update_value && btn_min_incr_pulsed) begin
			v_min <= (v_min+SPEED>255) ? 8'd255 : (v_min+SPEED);	
		end
		if (enable_threshold && obj_sel==V && update_value && btn_min_decr_pulsed) begin
			v_min <= (v_min-SPEED<0) ? 8'd0 : (v_min-SPEED); 
		end
		if (enable_threshold && obj_sel==V && update_value && btn_max_incr_pulsed) begin
			v_max <= (v_max+SPEED>255) ? 8'd255 : (v_max+SPEED);	
		end
		if (enable_threshold && obj_sel==V && update_value && btn_max_decr_pulsed) begin
			v_max <= (v_max-SPEED<0) ? 8'd0 : (v_max-SPEED); 
		end
	end
	
endmodule

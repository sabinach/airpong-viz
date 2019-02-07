//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Sabina chen
//
// Create Date: 21:26:30 12/07/2018
// Design Name:
// Module Name: 	threshold_hsv
// Project Name: 	AirPong
// Target Devices:
// Tool versions:
// Description:    Allows users to adjust the threshold of hsv values via user button presses for selected objects.
//
//					Inputs: 1) Current HSV threshold values for each object
//							2) User button presses
//					Output:	Updated HSV threshold values for the selected object
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module threshold_hsv #(parameter INITIAL_THRESHOLD = 25, SPEED = 3)(
	input clk, reset,
	input [1:0] obj_sel,		// puck, paddle1, paddle2
	input [7:0] h_sel_puck, s_sel_puck, v_sel_puck,
	input [7:0] h_sel_paddle1, s_sel_paddle1, v_sel_paddle1,
	input [7:0] h_sel_paddle2, s_sel_paddle2, v_sel_paddle2,
	input btn_enter,		    // calibrate on current center value
	input btn_min_decrease,		// button3: 	min decrease
	input btn_min_increase,		// button2: 	min increase
	input btn_max_decrease,		// button1: 	max decrease
	input btn_max_increase,		// button0: 	max increase
	input enable_threshold,		// switch[7]:	enable thresholding
	input [1:0] hsv_sel,		// switch[5:4]: 0:h1, 1:h2, 2:s, 3:v
	input [1:0] H, S, V, PUCK, PADDLE1, PADDLE2,
	output [7:0] h1_min_puck, h1_max_puck, h2_min_puck, h2_max_puck, s_min_puck, s_max_puck, v_min_puck, v_max_puck,
	output [7:0] h1_min_paddle1, h1_max_paddle1, h2_min_paddle1, h2_max_paddle1, s_min_paddle1, s_max_paddle1, v_min_paddle1, v_max_paddle1,
	output [7:0] h1_min_paddle2, h1_max_paddle2, h2_min_paddle2, h2_max_paddle2, s_min_paddle2, s_max_paddle2, v_min_paddle2, v_max_paddle2
	);
	
	// check for button pulse (ie. has the button changed from one state to another -> indicates button press)
	wire btn_enter_pulsed, btn_min_decr_pulsed, btn_min_incr_pulsed, btn_max_decr_pulsed, btn_max_incr_pulsed;
	l2p_fsm pulse_enter(.clk(clk),.reset(reset),.level(btn_enter),.out(btn_enter_pulsed)); 
	l2p_fsm pulse_min_decr(.clk(clk),.reset(reset),.level(btn_min_decrease),.out(btn_min_decr_pulsed)); 
	l2p_fsm pulse_min_incr(.clk(clk),.reset(reset),.level(btn_min_increase),.out(btn_min_incr_pulsed)); 
	l2p_fsm pulse_max_decr(.clk(clk),.reset(reset),.level(btn_max_decrease),.out(btn_max_decr_pulsed)); 
	l2p_fsm pulse_max_incr(.clk(clk),.reset(reset),.level(btn_max_increase),.out(btn_max_incr_pulsed)); 
	
	//puck
	update_threshold #(.INITIAL_THRESHOLD(INITIAL_THRESHOLD), .SPEED(SPEED)) 
		threshold_puck(
			.clk(clk),.obj_sel(obj_sel),
			.update_value(obj_sel==PUCK),
			.enable_threshold(enable_threshold),
			.btn_enter_pulsed(btn_enter_pulsed), 
			.btn_min_incr_pulsed(btn_min_incr_pulsed), .btn_min_decr_pulsed(btn_min_decr_pulsed), 
			.btn_max_incr_pulsed(btn_max_incr_pulsed), .btn_max_decr_pulsed(btn_max_decr_pulsed),
			.H(H), .S(S), .V(V), .PUCK(PUCK), .PADDLE1(PADDLE1), .PADDLE2(PADDLE2),
			.h_sel(h_sel_puck), .s_sel(s_sel_puck), .v_sel(v_sel_puck),
			.h1_min(h1_min_puck), .h1_max(h1_max_puck), 
			.h2_min(h2_min_puck), .h2_max(h2_max_puck), 
			.s_min(s_min_puck), .s_max(s_max_puck), 
			.v_min(v_min_puck), .v_max(v_max_puck)
		);
	
	//paddle1
	update_threshold #(.INITIAL_THRESHOLD(INITIAL_THRESHOLD), .SPEED(SPEED)) 
		threshold_paddle1(
			.clk(clk),.obj_sel(obj_sel),
			.update_value(obj_sel==PADDLE1),
			.enable_threshold(enable_threshold),
			.btn_enter_pulsed(btn_enter_pulsed), 
			.btn_min_incr_pulsed(btn_min_incr_pulsed), .btn_min_decr_pulsed(btn_min_decr_pulsed), 
			.btn_max_incr_pulsed(btn_max_incr_pulsed), .btn_max_decr_pulsed(btn_max_decr_pulsed),
			.H(H), .S(S), .V(V), .PUCK(PUCK), .PADDLE1(PADDLE1), .PADDLE2(PADDLE2),
			.h_sel(h_sel_paddle1), .s_sel(s_sel_paddle1), .v_sel(v_sel_paddle1),
			.h1_min(h1_min_paddle1), .h1_max(h1_max_paddle1), 
			.h2_min(h2_min_paddle1), .h2_max(h2_max_paddle1), 
			.s_min(s_min_paddle1), .s_max(s_max_paddle1), 
			.v_min(v_min_paddle1), .v_max(v_max_paddle1)
		);
	
	//paddle2
	update_threshold #(.INITIAL_THRESHOLD(INITIAL_THRESHOLD), .SPEED(SPEED)) 
		threshold_paddle2(
			.clk(clk),.obj_sel(obj_sel),
			.update_value(obj_sel==PADDLE2),
			.enable_threshold(enable_threshold),
			.btn_enter_pulsed(btn_enter_pulsed), 
			.btn_min_incr_pulsed(btn_min_incr_pulsed), .btn_min_decr_pulsed(btn_min_decr_pulsed), 
			.btn_max_incr_pulsed(btn_max_incr_pulsed), .btn_max_decr_pulsed(btn_max_decr_pulsed),
			.H(H), .S(S), .V(V), .PUCK(PUCK), .PADDLE1(PADDLE1), .PADDLE2(PADDLE2),
			.h_sel(h_sel_paddle2), .s_sel(s_sel_paddle2), .v_sel(v_sel_paddle2),
			.h1_min(h1_min_paddle2), .h1_max(h1_max_paddle2), 
			.h2_min(h2_min_paddle2), .h2_max(h2_max_paddle2), 
			.s_min(s_min_paddle2), .s_max(s_max_paddle2), 
			.v_min(v_min_paddle2), .v_max(v_max_paddle2)
		);

endmodule

	
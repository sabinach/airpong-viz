//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Sabina chen
//
// Create Date: 18:13:29 12/06/2018
// Design Name:
// Module Name: detect_color
// Project Name: AirPong
// Target Devices:
// Tool versions:
// Description: Given HSV boundaries for each object, determine which pixels lie within 
//              the HSV boundaries and color that pixel. At the same time, keep a counter
//              on the number of pixels that fall within bounds to calculate the average
//              location of the pixels.
//
//              Input: HSV boundaries
//              Outputs: 1) Updated vga pixel output with colored pixels representing detected colors
//                       2) xy pixel locations of the center of mass of detected color pixels for each object
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module detect_color 
	(input clk,
	input [7:0] H1_MIN_PUCK, H1_MAX_PUCK, H2_MIN_PUCK, H2_MAX_PUCK, S_MIN_PUCK, S_MAX_PUCK, V_MIN_PUCK, V_MAX_PUCK, // SABINA10
	input [7:0] H1_MIN_PADDLE1, H1_MAX_PADDLE1, H2_MIN_PADDLE1, H2_MAX_PADDLE1, S_MIN_PADDLE1, S_MAX_PADDLE1, V_MIN_PADDLE1, V_MAX_PADDLE1, // SABINA10
	input [7:0] H1_MIN_PADDLE2, H1_MAX_PADDLE2, H2_MIN_PADDLE2, H2_MAX_PADDLE2, S_MIN_PADDLE2, S_MAX_PADDLE2, V_MIN_PADDLE2, V_MAX_PADDLE2, // SABINA10
	input [23:0] hsv,
   input [10:0] h_count, vid_border_left, vid_border_right,
   input [9:0] v_count, vid_border_up, vid_border_down,
   input [23:0] pixel,
   output reg [23:0] color_pixel,
	output reg [24:0] x_total_puck, y_total_puck,
	output reg [24:0] x_total_paddle1, y_total_paddle1,
	output reg [24:0] x_total_paddle2, y_total_paddle2,
   output [10:0] x_center_puck_filtered, x_center_paddle1_filtered, x_center_paddle2_filtered,
   output [9:0] y_center_puck_filtered, y_center_paddle1_filtered, y_center_paddle2_filtered
   );

   wire [7:0] h, s, v;
   assign h = hsv[23:16];
   assign s = hsv[15:8];
   assign v = hsv[7:0];

   reg [24:0] x_counter_puck = 0;
   reg [24:0] y_counter_puck = 0;
   reg [24:0] x_numerator_puck = 0;
   reg [24:0] x_denominator_puck = 0;
   reg [24:0] y_numerator_puck = 0; 
   reg [24:0] y_denominator_puck = 0;
	
	reg [24:0] x_counter_paddle1 = 0;
   reg [24:0] y_counter_paddle1 = 0;
   reg [24:0] x_numerator_paddle1 = 0;
   reg [24:0] x_denominator_paddle1 = 0;
   reg [24:0] y_numerator_paddle1 = 0; 
   reg [24:0] y_denominator_paddle1 = 0;
	
	reg [24:0] x_counter_paddle2 = 0;
   reg [24:0] y_counter_paddle2 = 0;
   reg [24:0] x_numerator_paddle2 = 0;
   reg [24:0] x_denominator_paddle2 = 0;
   reg [24:0] y_numerator_paddle2 = 0; 
   reg [24:0] y_denominator_paddle2 = 0;

   // color the pixels that lie within hsv bounds
   always @(posedge clk) begin
      // reset counters at the beginning of each new frame 
      if(h_count==11'd0 && v_count==10'd0)begin
         color_pixel <= pixel;
         // puck
         x_total_puck <= 0;
         y_total_puck <= 0;
         x_counter_puck <= 0;
         y_counter_puck <= 0;
			// paddle1
			x_total_paddle1 <= 0;
         y_total_paddle1 <= 0;
         x_counter_paddle1 <= 0;
         y_counter_paddle1 <= 0;
			// paddle2
			x_total_paddle2 <= 0;
         y_total_paddle2 <= 0;
         x_counter_paddle2 <= 0;
         y_counter_paddle2 <= 0;
      end
		
      // if in frame, detect color
      else if(h_count>=vid_border_left && h_count<=vid_border_right && v_count>=vid_border_up && v_count<=vid_border_down) begin
			// puck
         if( ((h>H1_MIN_PUCK && h<=H1_MAX_PUCK) || h>H2_MIN_PUCK && h<=H2_MAX_PUCK) && (s>S_MIN_PUCK && s<=S_MAX_PUCK) && (v>V_MIN_PUCK && v<=V_MAX_PUCK)) begin
            color_pixel <= {8'd255,8'd0,8'd255}; // shade magenta
            x_total_puck <= x_total_puck + h_count;
            y_total_puck <= y_total_puck + v_count;
            x_counter_puck <= x_counter_puck + 1;
            y_counter_puck <= y_counter_puck + 1;
         end 
			else begin
            color_pixel <= pixel;
            x_total_puck <= x_total_puck;
            y_total_puck <= y_total_puck;
            x_counter_puck <= x_counter_puck;
            y_counter_puck <= y_counter_puck;
            x_numerator_puck <= x_numerator_puck;
            y_numerator_puck <= y_numerator_puck;
            x_denominator_puck <= x_denominator_puck;
            y_denominator_puck <= y_denominator_puck;
			end			
			// paddle1
         if( ((h>H1_MIN_PADDLE1 && h<=H1_MAX_PADDLE1) || h>H2_MIN_PADDLE1 && h<=H2_MAX_PADDLE1) && (s>S_MIN_PADDLE1 && s<=S_MAX_PADDLE1) && (v>V_MIN_PADDLE1 && v<=V_MAX_PADDLE1)) begin
            color_pixel <= {8'd0,8'd255,8'd0}; // shade green
            x_total_paddle1 <= x_total_paddle1 + h_count;
            y_total_paddle1 <= y_total_paddle1 + v_count;
            x_counter_paddle1 <= x_counter_paddle1 + 1;
            y_counter_paddle1 <= y_counter_paddle1 + 1;
         end 
			else begin
				x_total_paddle1 <= x_total_paddle1;
            y_total_paddle1 <= y_total_paddle1;
            x_counter_paddle1 <= x_counter_paddle1;
            y_counter_paddle1 <= y_counter_paddle1;
            x_numerator_paddle1 <= x_numerator_paddle1;
            y_numerator_paddle1 <= y_numerator_paddle1;
            x_denominator_paddle1 <= x_denominator_paddle1;
            y_denominator_paddle1 <= y_denominator_paddle1;
			end
			// paddle2
         if( ((h>H1_MIN_PADDLE2 && h<=H1_MAX_PADDLE2) || h>H2_MIN_PADDLE2 && h<=H2_MAX_PADDLE2) && (s>S_MIN_PADDLE2 && s<=S_MAX_PADDLE2) && (v>V_MIN_PADDLE2 && v<=V_MAX_PADDLE2)) begin
            color_pixel <= {8'd0,8'd0,8'd255}; // shade blue
            x_total_paddle2 <= x_total_paddle2 + h_count;
            y_total_paddle2 <= y_total_paddle2 + v_count;
            x_counter_paddle2 <= x_counter_paddle2 + 1;
            y_counter_paddle2 <= y_counter_paddle2 + 1;
         end 
			else begin
				// paddle2
				x_total_paddle2 <= x_total_paddle2;
            y_total_paddle2 <= y_total_paddle2;
            x_counter_paddle2 <= x_counter_paddle2;
            y_counter_paddle2 <= y_counter_paddle2;
            x_numerator_paddle2 <= x_numerator_paddle2;
            y_numerator_paddle2 <= y_numerator_paddle2;
            x_denominator_paddle2 <= x_denominator_paddle2;
            y_denominator_paddle2 <= y_denominator_paddle2;
         end
      end 

      // start divider immediately after past video boundary, if enough detected pixels then find xy-center
      else if (h_count == 600 && v_count == 800) begin
			//puck
         x_numerator_puck <= (x_counter_puck > 50) ? x_total_puck : 0;
         y_numerator_puck <= (y_counter_puck > 50) ? y_total_puck : 0;
         x_denominator_puck <= (x_counter_puck==0) ? 1 : x_counter_puck;
         y_denominator_puck <= (y_counter_puck==0) ? 1 : y_counter_puck;
			//paddle1
			x_numerator_paddle1 <= (x_counter_paddle1 > 50) ? x_total_paddle1 : 0;
         y_numerator_paddle1 <= (y_counter_paddle1 > 50) ? y_total_paddle1 : 0;
         x_denominator_paddle1 <= (x_counter_paddle1==0) ? 1 : x_counter_paddle1;
         y_denominator_paddle1 <= (y_counter_paddle1==0) ? 1 : y_counter_paddle1;
			//paddle2
			x_numerator_paddle2 <= (x_counter_paddle2 > 50) ? x_total_paddle2 : 0;
         y_numerator_paddle2 <= (y_counter_paddle2 > 50) ? y_total_paddle2 : 0;
         x_denominator_paddle2 <= (x_counter_paddle2==0) ? 1 : x_counter_paddle2;
         y_denominator_paddle2 <= (y_counter_paddle2==0) ? 1 : y_counter_paddle2;
      end
		
      // if not in frame, do nothing
		else begin
			color_pixel <= pixel;
		end
   end

   // divide xy_total / xy_counter to get average h/vcount location
	// puck
   wire [24:0] x_quotient_puck;
   wire [24:0] x_remainder_puck;
	wire [24:0] y_quotient_puck;
   wire [24:0] y_remainder_puck;
   wire x_ready_puck, y_ready_puck;
	// paddle1
   wire [24:0] x_quotient_paddle1;
   wire [24:0] x_remainder_paddle1;
	wire [24:0] y_quotient_paddle1;
   wire [24:0] y_remainder_paddle1;
   wire x_ready_paddle1, y_ready_paddle1;
	// paddle2
   wire [24:0] x_quotient_paddle2;
   wire [24:0] x_remainder_paddle2;
	wire [24:0] y_quotient_paddle2;
   wire [24:0] y_remainder_paddle2;
   wire x_ready_paddle2, y_ready_paddle2;

	// puck
	avgdivider x_div_puck(.clk(clk), .dividend(x_numerator_puck), .divisor(x_denominator_puck), 
		.quotient(x_quotient_puck), .fractional(x_remainder_puck), .rfd(x_ready_puck));
	avgdivider y_div_puck(.clk(clk), .dividend(y_numerator_puck), .divisor(y_denominator_puck),
		.quotient(y_quotient_puck), .fractional(y_remainder_puck), .rfd(y_ready_puck)); 
	// paddle1
	avgdivider x_div_paddle1(.clk(clk), .dividend(x_numerator_paddle1), .divisor(x_denominator_paddle1), 
		.quotient(x_quotient_paddle1), .fractional(x_remainder_paddle1), .rfd(x_ready_paddle1));
	avgdivider y_div_paddle1(.clk(clk), .dividend(y_numerator_paddle1), .divisor(y_denominator_paddle1),
		.quotient(y_quotient_paddle1), .fractional(y_remainder_paddle1), .rfd(y_ready_paddle1)); 
	// paddle2
	avgdivider x_div_paddle2(.clk(clk), .dividend(x_numerator_paddle2), .divisor(x_denominator_paddle2), 
		.quotient(x_quotient_paddle2), .fractional(x_remainder_paddle2), .rfd(x_ready_paddle2));
	avgdivider y_div_paddle2(.clk(clk), .dividend(y_numerator_paddle2), .divisor(y_denominator_paddle2),
		.quotient(y_quotient_paddle2), .fractional(y_remainder_paddle2), .rfd(y_ready_paddle2)); 
	
	wire [10:0] x_center_puck, x_center_paddle1, x_center_paddle2;
	wire [9:0] y_center_puck, y_center_paddle1, y_center_paddle2;
	
	// puck
   assign x_center_puck = x_ready_puck ? x_quotient_puck[10:0] : x_center_puck;
   assign y_center_puck = y_ready_puck ? y_quotient_puck[9:0] : y_center_puck;
	// paddle1
   assign x_center_paddle1 = x_ready_paddle1 ? x_quotient_paddle1[10:0] : x_center_paddle1;
   assign y_center_paddle1 = y_ready_paddle1 ? y_quotient_paddle1[9:0] : y_center_paddle1;
	// paddle2
   assign x_center_paddle2 = x_ready_paddle2 ? x_quotient_paddle2[10:0] : x_center_paddle2;
   assign y_center_paddle2 = y_ready_paddle2 ? y_quotient_paddle2[9:0] : y_center_paddle2;
	
   // pass coordinates theough a low pass filter to smooth out jumpiness 
	low_pass_filter x_center_puck_coord(.clk(clk),.input_data(x_center_puck),.post_filter_data(x_center_puck_filtered));
	low_pass_filter y_center_puck_coord(.clk(clk),.input_data(y_center_puck),.post_filter_data(y_center_puck_filtered));
	low_pass_filter x_center_paddle1_coord(.clk(clk),.input_data(x_center_paddle1),.post_filter_data(x_center_paddle1_filtered));
	low_pass_filter y_center_paddle1_coord(.clk(clk),.input_data(y_center_paddle1),.post_filter_data(y_center_paddle1_filtered));
	low_pass_filter x_center_paddle2_coord(.clk(clk),.input_data(x_center_paddle2),.post_filter_data(x_center_paddle2_filtered));
	low_pass_filter y_center_paddle2_coord(.clk(clk),.input_data(y_center_paddle2),.post_filter_data(y_center_paddle2_filtered));

endmodule



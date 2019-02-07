`default_nettype none
//
// File:   zbt_6111_sample.v
// Date:   26-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Sample code for the MIT 6.111 labkit demonstrating use of the ZBT
// memories for video display.  Video input from the NTSC digitizer is
// displayed within an XGA 1024x768 window.  One ZBT memory (ram0) is used
// as the video frame buffer, with 8 bits used per pixel (black & white).
//
// Since the ZBT is read once for every four pixels, this frees up time for 
// data to be stored to the ZBT during other pixel times.  The NTSC decoder
// runs at 27 MHz, whereas the XGA runs at 65 MHz, so we synchronize
// signals between the two (see ntsc2zbt.v) and let the NTSC data be
// stored to ZBT memory whenever it is available, during cycles when
// pixel reads are not being performed.
//
// We use a very simple ZBT interface, which does not involve any clock
// generation or hiding of the pipelining.  See zbt_6111.v for more info.
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09
//
// Use ramclock module to deskew clocks;  GPH
// To change display from 1024*787 to 800*600, use clock_40mhz and change
// accordingly. Verilog ntsc2zbt.v will also need changes to change resolution.
//
// Date   : 10-Nov-11

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2011-Nov-10: Changed resolution to 1024 * 768.
//					 Added back ramclok to deskew RAM clock
//
// 2009-May-11: Fixed memory management bug by 8 clock cycle forecast. 
//              Changed resolution to  800 * 600.
//              Reduced clock speed to 40MHz.
//              Disconnected zbt_6111's ram_clk signal. 
//              Added ramclock to control RAM.
//              Added notes about ram1 default values.
//              Commented out clock_feedback_out assignment.
//              Removed delayN modules because ZBT's latency has no more effect.
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module zbt_6111_sample(
			 beep, audio_reset_b, 
		    ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       //tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       //tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       //tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       //ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       //ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       //flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       //flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       //mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, 
	       //clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       //user1, user2, user3, user4,
			 user3,
	       
	       //daughtercard,

	       //systemace_data, systemace_address, systemace_ce_b,
	       //systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   //output [9:0] tv_out_ycrcb;
   //output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	//  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	//  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   //output ram0_clk;
   output [3:0] ram0_bwe_b;
   
   //inout  [35:0] ram1_data;
   //output [18:0] ram1_address;
   //output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   //output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   //inout  [15:0] flash_data;
   //output [23:0] flash_address;
   //output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   //input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   //input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz; 
	//clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   //inout [31:0] user1, user2, user3, user4;
	inout [31:0] user3;
   
   //inout [43:0] daughtercard;

   //inout  [15:0] systemace_data;
   //output [6:0]  systemace_address;
   //output systemace_ce_b, systemace_we_b, systemace_oe_b;
   //input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // Video Output
   //assign tv_out_ycrcb = 10'h0;
   //assign tv_out_reset_b = 1'b0;
   //assign tv_out_clock = 1'b0;
   //assign tv_out_i2c_clock = 1'b0;
   //assign tv_out_i2c_data = 1'b0;
   //assign tv_out_pal_ntsc = 1'b0;
   //assign tv_out_hsync_b = 1'b1;
   //assign tv_out_vsync_b = 1'b1;
   //assign tv_out_blank_b = 1'b1;
   //assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   //assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b1;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b1;
   //assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = clock_27mhz;//1'b0;
   //assign tv_in_i2c_data = 1'bZ;
   
	// tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs

	/* change lines below to enable ZBT RAM bank0 */

	/*
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_clk = 1'b0;
   assign ram0_we_b = 1'b1;
   assign ram0_cen_b = 1'b0;	// clock enable
	*/

	/* enable RAM pins */

   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_bwe_b = 4'h0; 

	/**********/

   //assign ram1_data = 36'hZ; 
   //assign ram1_address = 19'h0;
   //assign ram1_adv_ld = 1'b0;
   //assign ram1_clk = 1'b0;
   
   //These values has to be set to 0 like ram0 if ram1 is used.
   //assign ram1_cen_b = 1'b1;
   //assign ram1_ce_b = 1'b1;
   //assign ram1_oe_b = 1'b1;
   //assign ram1_we_b = 1'b1;
   //assign ram1_bwe_b = 4'hF;

   // clock_feedback_out will be assigned by ramclock
   // assign clock_feedback_out = 1'b0;  //2011-Nov-10
   // clock_feedback_in is an input
   
   // Flash ROM
   //assign flash_data = 16'hZ;
   //assign flash_address = 24'h0;
   //assign flash_ce_b = 1'b1;
   //assign flash_oe_b = 1'b1;
   //assign flash_we_b = 1'b1;
   //assign flash_reset_b = 1'b0;
   //assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   /*
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   */
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   // assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   //assign user1 = 32'hZ;
   //assign user2 = 32'hZ;
   //assign user3 = 32'hZ;
   assign user3 = 32'hZ;
   //assign user4 = 32'hZ;

   // Daughtercard Connectors
   //assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   //assign systemace_data = 16'hZ;
   //assign systemace_address = 7'h0;
   //assign systemace_ce_b = 1'b1;
   //assign systemace_we_b = 1'b1;
   //assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
   // -------------------------------------------------------------------------
   // 65 MHz clock creation
   // -------------------------------------------------------------------------

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

   // -------------------------------------------------------------------------
   // Ram clock creation
   // -------------------------------------------------------------------------

   wire clk; // Primary logic clock
	wire locked;
	//assign clock_feedback_out = 0; // gph 2011-Nov-10

   ramclock rc(.ref_clock(clock_65mhz), 
	       .fpga_clock(clk),
	       .ram0_clock(ram0_clk), 
	       .ram1_clock(/*ram1_clk*/),   //uncomment if ram1 is used
	       .clock_feedback_in(clock_feedback_in),
	       .clock_feedback_out(clock_feedback_out), 
	       .locked(locked));
   
   // -------------------------------------------------------------------------
   // Power-on reset generation
   // -------------------------------------------------------------------------

   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clk), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

	// -------------------------------------------------------------------------
   // Set Parameters
   // -------------------------------------------------------------------------
   
   /////////////////
   // VID_COORD
   /////////////////

   // camera frame image 725 x 505
   parameter  VID_BORDER_UP =    10'd126;       // initial numbers
   parameter  VID_BORDER_DOWN =  10'd542;
   parameter  VID_BORDER_LEFT =  11'd82;
   parameter  VID_BORDER_RIGHT = 11'd730;

   // define selectable objects
   parameter PUCK = 0;
   parameter PADDLE1 = 1;
   parameter PADDLE2 = 2;

   // define selectables hsv
   parameter H = 0;
   parameter S = 1;
   parameter V = 2;

   // define switches and buttons
   wire CROSSHAIR_CHROMA_SEL, CENTER_SEL, DISP_XY_HSV, ENABLE_THRESH;
   wire [1:0] OBJ_SEL, HSV_SEL;
     
   assign CROSSHAIR_CHROMA_SEL   = switch[2];
   assign CENTER_SEL             = switch[3];
   assign DISP_XY_HSV            = switch[0];
   assign OBJ_SEL                = switch[5:4];
   assign HSV_SEL                = switch[7:6];
   assign ENABLE_THRESH          = ~switch[1];
	
   ////////////////
   // PONG
   ////////////////

   wire [1:0] DISPLAY_KILL;
   wire [3:0] PSPEED;

   assign DISPLAY_KILL = switch[1:0];
   assign PSPEED = switch[7:4]; 
	
   // -------------------------------------------------------------------------
   // Debouncing
   // -------------------------------------------------------------------------

   // ENTER button is user reset
   wire reset,user_reset;
   assign reset = user_reset | power_on_reset;
   debounce db1(.reset(power_on_reset), .clk(clk), .noisy(~button_enter), .clean(user_reset));

   wire btn_up_debounced,btn_down_debounced, btn_left_debounced, btn_right_debounced;
   debounce db3(.reset(reset),.clk(clk),.noisy(~button_up),.clean(btn_up_debounced));
   debounce db4(.reset(reset),.clk(clk),.noisy(~button_down),.clean(btn_down_debounced));
   debounce db5(.reset(reset),.clk(clk),.noisy(~button_left),.clean(btn_left_debounced));
   debounce db6(.reset(reset),.clk(clk),.noisy(~button_right),.clean(btn_right_debounced));

   wire btn_enter_debounced,btn_0_debounced,btn_1_debounced,btn_2_debounced,btn_3_debounced;
   debounce db7(.reset(reset),.clk(clk),.noisy(~button_enter),.clean(btn_enter_debounced));
   debounce db8(.reset(reset),.clk(clk),.noisy(~button0),.clean(btn_0_debounced));
   debounce db9(.reset(reset),.clk(clk),.noisy(~button1),.clean(btn_1_debounced));
   debounce db10(.reset(reset),.clk(clk),.noisy(~button2),.clean(btn_2_debounced));
   debounce db11(.reset(reset),.clk(clk),.noisy(~button3),.clean(btn_3_debounced));

   // -------------------------------------------------------------------------
   // Hex dot matrix displays
   // -------------------------------------------------------------------------

   // display module for debugging

   reg [63:0] dispdata;

   display_16hex hexdisp1(reset, clock_27mhz, dispdata,
			  disp_blank, disp_clock, disp_rs, disp_ce_b,
			  disp_reset_b, disp_data_out);

   // generate basic XVGA video signals
   wire [10:0] hcount;
   wire [9:0]  vcount;
   wire hsync,vsync,blank;
   xvga xvga1(.vclock(clk),.hcount(hcount),.vcount(vcount),
               .hsync(hsync),.vsync(vsync),.blank(blank));

   // -------------------------------------------------------------------------
   // ZBT Wiring - wire labkit directly to zbt
   // -------------------------------------------------------------------------

   wire [35:0] vram_write_data;
   wire [35:0] vram_read_data;
   wire [18:0] vram_addr;
   wire        vram_we;

   wire ram0_clk_not_used;
   zbt_6111 zbt1(clk, 1'b1, vram_we, vram_addr,
		   vram_write_data, vram_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);

   // -------------------------------------------------------------------------
   // vram_display - read from ZBT memory
   // -------------------------------------------------------------------------

   // generate pixel value from reading ZBT memory
   wire [17:0]    vr_pixel; 
   wire [18:0]    vram_addr1;

   vram_display vd1(reset,clk,hcount,vcount,vr_pixel,
          vram_addr1,vram_read_data);

   // -------------------------------------------------------------------------
   // adv7185 - take raw ntsc output and converts to usable form
   // -------------------------------------------------------------------------

   // ADV7185 NTSC decoder interface code
   // adv7185 initialization module
   adv7185init adv7185(.reset(reset), .clock_27mhz(clock_27mhz), 
		       .source(1'b0), .tv_in_reset_b(tv_in_reset_b), 
		       .tv_in_i2c_clock(tv_in_i2c_clock), 
		       .tv_in_i2c_data(tv_in_i2c_data));
	
   // -------------------------------------------------------------------------
   // ntsc_decode - parse control signals
   // -------------------------------------------------------------------------

   wire [29:0] ycrcb;	// video data (luminance, chrominance)
   wire [2:0] fvh;	// sync for field, vertical, horizontal
   wire       dv;	// data valid
   
   ntsc_decode decode (.clk(tv_in_line_clock1), .reset(reset),
		       .tv_in_ycrcb(tv_in_ycrcb[19:10]), 
		       .ycrcb(ycrcb), .f(fvh[2]),
		       .v(fvh[1]), .h(fvh[0]), .data_valid(dv));

   // -------------------------------------------------------------------------
   // Ycrcb2rgb - takes updated control signals and changes to rgb format
   // -------------------------------------------------------------------------
	
	wire [7:0] red, green, blue;
	wire [17:0] rgb; 

	YCrCb2RGB color_conv( red, green, blue, tv_in_line_clock1, reset, ycrcb[29:20], ycrcb[19:10],ycrcb[9:0] ); 

	assign rgb = {red[7:2],green[7:2],blue[7:2]}; 
	
	// -------------------------------------------------------------------------
   // ntsc_to_zbt - saves rgb data to zbt, and returns ntsc address + data
   // -------------------------------------------------------------------------

   // code to write NTSC data to video memory

   wire [18:0] ntsc_addr;
   wire [35:0] ntsc_data;
   wire        ntsc_we;
	ntsc_to_zbt n2z (clk, tv_in_line_clock1, fvh, dv, rgb,
		    ntsc_addr, ntsc_data, ntsc_we, 1'b0);
	
   // code to write pattern to ZBT memory
   reg [31:0] 	count;
   always @(posedge clk) count <= reset ? 0 : count + 1;

   wire [18:0] 	vram_addr2 = count[0+18:0];
	wire [35:0] 	vpat = ( 1'b0 ? {4{count[3+3:3],4'b0}} : {4{count[3+4:4],4'b0}} ); // Sabina - removed to use switch[6]

   // mux selecting read/write to memory based on which write-enable is chosen

   //wire 	sw_ntsc = ~switch[7]; // Sabina - removed to use switch[7]
   wire sw_ntsc = 1'b1;
   wire 	my_we = sw_ntsc ? (hcount[0]==1'b1) : blank; // Sabina - removed to use switch[8]
   wire [18:0] 	write_addr = sw_ntsc ? ntsc_addr : vram_addr2;
   wire [35:0] 	write_data = sw_ntsc ? ntsc_data : vpat;

   assign 	vram_addr = my_we ? write_addr : vram_addr1;
   assign 	vram_we = my_we;
   assign 	vram_write_data = write_data;
	
   // -------------------------------------------------------------------------
   // rgb2hsv - rgb->hsv
   // -------------------------------------------------------------------------
             
   // clk (input) and vr_pixel (output) data input received from vram_display 
	wire [7:0] vr_red, vr_green, vr_blue;
	assign vr_red = {vr_pixel[17:12], 2'b0};
	assign vr_green = {vr_pixel[11:6], 2'b0};
	assign vr_blue = {vr_pixel[5:0], 2'b0};
	
   wire [23:0] hsv;
   rgb2hsv rgb_hsv_convert(.clock(clk), .reset(reset), .r(vr_red), .g(vr_green), .b(vr_blue), 
										.h(hsv[23:16]), .s(hsv[15:8]), .v(hsv[7:0])); //outputs hsv values

	// -------------------------------------------------------------------------
   // Delay - add hcount vcount delays due to rgb2hsv divider delay
   // -------------------------------------------------------------------------
	
	wire [10:0] hcount_delayed;
	wire [9:0] vcount_delayed;
	delayN #(22,11) delay_h(clk, hcount, hcount_delayed);
	delayN #(22,10) delay_v(clk, vcount, vcount_delayed);
	
   // -------------------------------------------------------------------------
   // video_border_pixel - create moving border (takes in vr_pixel, outputs video_border_pixel)
   // -------------------------------------------------------------------------
	
   wire in_video_boundary;
   assign in_video_boundary = (hcount >= VID_BORDER_LEFT && hcount < VID_BORDER_RIGHT) && 
											(vcount >= VID_BORDER_UP && vcount < VID_BORDER_DOWN);
	
	wire [23:0] video_border_pixel;
	assign video_border_pixel = (in_video_boundary) ? {vr_red, vr_green, vr_blue} : 24'd0;
	
	wire [23:0] video_border_pixel_delayed;
	delayN #(22,24) delay_border(clk, video_border_pixel, video_border_pixel_delayed);
	
	// -------------------------------------------------------------------------
   // move & display crosshair - debug/visualization module (takes in video_border_pixel, outputs crosshair_pixel)
   // -------------------------------------------------------------------------
	
   // debugging module - can take in any xy-coord and move the center of the crosshair to that location

	// set puck, paddle1, or paddle2
	wire [10:0] x_new_puck, x_new_paddle1, x_new_paddle2;
   wire [9:0] y_new_puck, y_new_paddle1, y_new_paddle2;
	
	wire enable_puck, enable_paddle1, enable_paddle2;
	assign enable_puck = (OBJ_SEL == PUCK);
	assign enable_paddle1 = (OBJ_SEL == PADDLE1);
	assign enable_paddle2 = (OBJ_SEL == PADDLE2);
	
	//puck
	move_crosshair move_crosshair_puck(
							.clk(vsync),
							.enable(enable_puck),
							.btn_up_debounced(btn_up_debounced),
							.btn_down_debounced(btn_down_debounced),
							.btn_left_debounced(btn_left_debounced),
							.btn_right_debounced(btn_right_debounced),
							.x_new(x_new_puck),
							.y_new(y_new_puck) );
	//paddle1
	move_crosshair move_crosshair_paddle1(
							.clk(vsync),
							.enable(enable_paddle1),
							.btn_up_debounced(btn_up_debounced),
							.btn_down_debounced(btn_down_debounced),
							.btn_left_debounced(btn_left_debounced),
							.btn_right_debounced(btn_right_debounced),
							.x_new(x_new_paddle1),
							.y_new(y_new_paddle1) );
	//paddle2
	move_crosshair move_crosshair_paddle2(
							.clk(vsync),
							.enable(enable_paddle2),
							.btn_up_debounced(btn_up_debounced),
							.btn_down_debounced(btn_down_debounced),
							.btn_left_debounced(btn_left_debounced),
							.btn_right_debounced(btn_right_debounced),
							.x_new(x_new_paddle2),
							.y_new(y_new_paddle2) );
	
	wire [23:0] crosshair_pixel;
	wire [10:0] x_center_puck;
   wire [9:0] y_center_puck;
	wire [10:0] x_center_paddle1;
   wire [9:0] y_center_paddle1;
	wire [10:0] x_center_paddle2;
   wire [9:0] y_center_paddle2;
	
	//crosshair - puck:magenta, paddle1:green, paddle2:blue
	crosshair display_crosshair(
		.clk(clk), .hcount(hcount), .vcount(vcount), .center_sel(CENTER_SEL), 
		
		.x_new_puck(x_new_puck), .y_new_puck(y_new_puck), 
		.x_new_paddle1(x_new_paddle1), .y_new_paddle1(y_new_paddle1), 
		.x_new_paddle2(x_new_paddle2), .y_new_paddle2(y_new_paddle2), 
		
		.x_center_puck(x_center_puck), .y_center_puck(y_center_puck), 
		.x_center_paddle1(x_center_paddle1), .y_center_paddle1(y_center_paddle1), 
		.x_center_paddle2(x_center_paddle2), .y_center_paddle2(y_center_paddle2), 
		
		.pixel(video_border_pixel), .crosshair_pixel(crosshair_pixel)
	);
	
	// -------------------------------------------------------------------------
   // display_hsv_value - takes x_new/y_new coords provided by crosshair,
   //                        and uses video_border_pixel to detect hsv at selected coord. 
	// 						  displays hsv value on hex display. used for debugging detect_color
   // -------------------------------------------------------------------------
	
   // debugging module

	wire [7:0] h_sel_puck, s_sel_puck, v_sel_puck;
	wire [7:0] h_sel_paddle1, s_sel_paddle1, v_sel_paddle1;
	wire [7:0] h_sel_paddle2, s_sel_paddle2, v_sel_paddle2;
	display_hsv_value view_hsv_puck(.clk(clk), .hcount(hcount), .vcount(vcount), .x_coord(x_new_puck), .y_coord(y_new_puck), 
		.pixel(video_border_pixel), .hsv(hsv), .h_sel(h_sel_puck), .s_sel(s_sel_puck), .v_sel(v_sel_puck));
	display_hsv_value view_hsv_paddle1(.clk(clk), .hcount(hcount), .vcount(vcount), .x_coord(x_new_paddle1), .y_coord(y_new_paddle1), 
		.pixel(video_border_pixel), .hsv(hsv), .h_sel(h_sel_paddle1), .s_sel(s_sel_paddle1), .v_sel(v_sel_paddle1));
	display_hsv_value view_hsv_paddle2(.clk(clk), .hcount(hcount), .vcount(vcount), .x_coord(x_new_paddle2), .y_coord(y_new_paddle2), 
		.pixel(video_border_pixel), .hsv(hsv), .h_sel(h_sel_paddle2), .s_sel(s_sel_paddle2), .v_sel(v_sel_paddle2));
	
   // -------------------------------------------------------------------------
   // threshold_hsv - takes in current hsv + user button interactions 
   //                    -> spits out new hsv thresholds, which is used by detect_color (ie.color_pixel)
   // -------------------------------------------------------------------------

   // debugging module - can input approximate hue we want to test (red overlaps around so need to test two, but other colors just one)

   // outputs created thresholds from selected hsv center value
   wire [7:0] h1_min_puck, h1_max_puck, h2_min_puck, h2_max_puck, s_min_puck, s_max_puck, v_min_puck, v_max_puck;
	wire [7:0] h1_min_paddle1, h1_max_paddle1, h2_min_paddle1, h2_max_paddle1, s_min_paddle1, s_max_paddle1, v_min_paddle1, v_max_paddle1;
	wire [7:0] h1_min_paddle2, h1_max_paddle2, h2_min_paddle2, h2_max_paddle2, s_min_paddle2, s_max_paddle2, v_min_paddle2, v_max_paddle2;
	
	threshold_hsv #(.INITIAL_THRESHOLD(25),.SPEED(3)) update_threshold (
		.clk(clk), .reset(reset),
		.obj_sel(OBJ_SEL), 
		
		.h_sel_puck(h_sel_puck), .s_sel_puck(s_sel_puck), .v_sel_puck(v_sel_puck), 
		.h_sel_paddle1(h_sel_paddle1), .s_sel_paddle1(s_sel_paddle1), .v_sel_paddle1(v_sel_paddle1),
		.h_sel_paddle2(h_sel_paddle2), .s_sel_paddle2(s_sel_paddle2), .v_sel_paddle2(v_sel_paddle2),
		
		.btn_enter(btn_enter_debounced), .btn_min_decrease(btn_3_debounced), .btn_min_increase(btn_2_debounced), 
		.btn_max_decrease(btn_1_debounced), .btn_max_increase(btn_0_debounced),
		.hsv_sel(HSV_SEL), .enable_threshold(ENABLE_THRESH), 
		.H(H), .S(S), .V(V), .PUCK(PUCK), .PADDLE1(PADDLE1), .PADDLE2(PADDLE2),
		
		.h1_min_puck(h1_min_puck), .h1_max_puck(h1_max_puck), .h2_min_puck(h2_min_puck), .h2_max_puck(h2_max_puck), 
		.s_min_puck(s_min_puck), .s_max_puck(s_max_puck), .v_min_puck(v_min_puck), .v_max_puck(v_max_puck),
		.h1_min_paddle1(h1_min_paddle1), .h1_max_paddle1(h1_max_paddle1), .h2_min_paddle1(h2_min_paddle1), .h2_max_paddle1(h2_max_paddle1), 
		.s_min_paddle1(s_min_paddle1), .s_max_paddle1(s_max_paddle1), .v_min_paddle1(v_min_paddle1), .v_max_paddle1(v_max_paddle1),
		.h1_min_paddle2(h1_min_paddle2), .h1_max_paddle2(h1_max_paddle2), .h2_min_paddle2(h2_min_paddle2), .h2_max_paddle2(h2_max_paddle2), 
		.s_min_paddle2(s_min_paddle2), .s_max_paddle2(s_max_paddle2), .v_min_paddle2(v_min_paddle2), .v_max_paddle2(v_max_paddle2) 
	);
		
   // -------------------------------------------------------------------------
   // color_pixel - detect red and replace pixels with black/magenta (takes in video_border_pixel
   //                outputs color_pixel + x_center/y_center of object)
   // -------------------------------------------------------------------------

   // color detection, can set hsv thresholds manually through here after we've tested/gotten the numbers

   // detect color based on specific hsv thresholds, and output color_pixel with detected colors blackened for debugging
   wire [23:0] color_pixel;
	wire [24:0] x_total_puck, y_total_puck;
	wire [24:0] x_total_paddle1, y_total_paddle1;
	wire [24:0] x_total_paddle2, y_total_paddle2;
	
	detect_color //#(.H1_MIN(h1_min), .H1_MAX(h1_max), .H2_MIN(h2_min), .H2_MAX(h2_max), .SMIN(s_min), .SMAX(s_max), .VMIN(v_min), .VMAX(v_max))
      detect_objects(
				.clk(clk), 
				
				.H1_MIN_PUCK(h1_min_puck), .H1_MAX_PUCK(h1_max_puck), .H2_MIN_PUCK(h2_min_puck), .H2_MAX_PUCK(h2_max_puck), 
				.S_MIN_PUCK(s_min_puck), .S_MAX_PUCK(s_max_puck), .V_MIN_PUCK(v_min_puck), .V_MAX_PUCK(v_max_puck), 
				.H1_MIN_PADDLE1(h1_min_paddle1), .H1_MAX_PADDLE1(h1_max_paddle1), .H2_MIN_PADDLE1(h2_min_paddle1), .H2_MAX_PADDLE1(h2_max_paddle1), 
				.S_MIN_PADDLE1(s_min_paddle1), .S_MAX_PADDLE1(s_max_paddle1), .V_MIN_PADDLE1(v_min_paddle1), .V_MAX_PADDLE1(v_max_paddle1),
				.H1_MIN_PADDLE2(h1_min_paddle2), .H1_MAX_PADDLE2(h1_max_paddle2), .H2_MIN_PADDLE2(h2_min_paddle2), .H2_MAX_PADDLE2(h2_max_paddle2), 
				.S_MIN_PADDLE2(s_min_paddle2), .S_MAX_PADDLE2(s_max_paddle2), .V_MIN_PADDLE2(v_min_paddle2), .V_MAX_PADDLE2(v_max_paddle2), 
				
				.hsv(hsv), .h_count(hcount), .v_count(vcount), 
				.vid_border_left(VID_BORDER_LEFT), .vid_border_right(VID_BORDER_RIGHT), .vid_border_up(VID_BORDER_UP), 
				.vid_border_down(VID_BORDER_DOWN), .pixel(video_border_pixel_delayed), .color_pixel(color_pixel), 
				
				.x_total_puck(x_total_puck), .y_total_puck(y_total_puck),
				.x_total_paddle1(x_total_paddle1), .y_total_paddle1(y_total_paddle1),
				.x_total_paddle2(x_total_paddle2), .y_total_paddle2(y_total_paddle2),
				
				.x_center_puck_filtered(x_center_puck), .y_center_puck_filtered(y_center_puck), 
				.x_center_paddle1_filtered(x_center_paddle1), .y_center_paddle1_filtered(y_center_paddle1),
				.x_center_paddle2_filtered(x_center_paddle2), .y_center_paddle2_filtered(y_center_paddle2)	
		);
		
   // -------------------------------------------------------------------------
   // Adjust xy-centers to game space
   // -------------------------------------------------------------------------

   wire [10:0] adj_x_puck, adj_x_paddle1, adj_x_paddle2; 
   wire [9:0] adj_y_puck, adj_y_paddle1, adj_y_paddle2;
   
   assign adj_x_puck = x_center_puck - VID_BORDER_LEFT;
   assign adj_y_puck = y_center_puck - VID_BORDER_UP;
   assign adj_x_paddle1 = x_center_paddle1 - VID_BORDER_LEFT;
   assign adj_y_paddle1 = y_center_paddle1 - VID_BORDER_UP;
   assign adj_x_paddle2 = x_center_paddle2 - VID_BORDER_LEFT;
   assign adj_y_paddle2 = y_center_paddle2 - VID_BORDER_UP;
	
	wire [23:0] color_pixel;
	wire [11:0] x_center_puck;
	wire [10:0] y_center_puck;
	wire [11:0] x_center_paddle1;
	wire [10:0] y_center_paddle1;
	wire [11:0] x_center_paddle2;
	wire [10:0] y_center_paddle2;
	
	wire [7:0] h1_min_puck, h1_max_puck, h2_min_puck, h2_max_puck, s_min_puck, s_max_puck, v_min_puck, v_max_puck;
	wire [7:0] h1_min_paddle1, h1_max_paddle1, h2_min_paddle1, h2_max_paddle1, s_min_paddle1, s_max_paddle1, v_min_paddle1, v_max_paddle1;
	wire [7:0] h1_min_paddle2, h1_max_paddle2, h2_min_paddle2, h2_max_paddle2, s_min_paddle2, s_max_paddle2, v_min_paddle2, v_max_paddle2;
	
	wire [7:0] h_sel_puck, s_sel_puck, v_sel_puck;
	wire [7:0] h_sel_paddle1, s_sel_paddle1, v_sel_paddle1;
	wire [7:0] h_sel_paddle2, s_sel_paddle2, v_sel_paddle2;
	
	wire [10:0] adj_x_puck, adj_x_paddle1, adj_x_paddle2; 
   wire [9:0] adj_y_puck, adj_y_paddle1, adj_y_paddle2;
	
	wire [23:0] crosshair_pixel;
	
	assign tv_in_i2c_clock = 1'b0;
   assign tv_in_reset_b = 1'b0;
   //assign tv_in_i2c_data = 1'bZ;
	
   // -------------------------------------------------------------------------
   // Pong logic
   // -------------------------------------------------------------------------	
	
   // feed XVGA signals to user's pong game
   wire [23:0] pong_pixel;
   wire [23:0] cb_pixel;
   wire [7:0]  velocity_x, velocity_y;

   wire        halt; // 1 to stop flight due to game conditions
   wire        kill; // 1 to stop flight due to other conditions

	wire [23:0] video_coord_pixel;
	assign video_coord_pixel = (CROSSHAIR_CHROMA_SEL) ? color_pixel : crosshair_pixel; 
	
   pong_game pg(
       .vclock(clk), .reset(reset),
       .enable(~kill),
       .left_up(btn_up_debounced), .left_down(btn_down_debounced),
       .right_up(btn_1_debounced), .right_down(btn_0_debounced),
       .pspeed(PSPEED),
       .hcount(hcount), .vcount(vcount),
       .hsync(hsync),.vsync(vsync),.blank(blank),
		 
       .base_pixel(video_coord_pixel),
       .puck_x(x_center_puck), .puck_y(y_center_puck), 
		 .led(led[3:0]),
       .paddle_1_x(x_center_paddle1), .paddle_1_y(y_center_paddle1),
       .paddle_2_x(x_center_paddle2), .paddle_2_y(y_center_paddle2),
		 
       .pixel(pong_pixel),
       .velocity_x(velocity_x), .velocity_y(velocity_y),
       .halt(halt)
   );
	
   // -------------------------------------------------------------------------
   // Estimator
   // -------------------------------------------------------------------------
	wire    airborne; // 1 if drone is currently in the air
	wire    stable;   // 1 if drone is stable enough to control
	
//
//   estimator estimator(
//         .imu(),
//         .barometer(),
//         .ultrasound(),
//         .magnetometer(),
//         .optical_x(),
//         .optical_y(),
//         .data_ready(),
//         .airborne(airborne),
//         .stable(stable)
//   );
	
   // -------------------------------------------------------------------------
   // Controls
   // -------------------------------------------------------------------------
   //  switch[1:0] selects which video generator to use:
   //  00: user's pong game, safety ON (kill is true)
   //  01: 1 pixel outline of active video area (adjust screen controls)
   //  10: user's pong game, safety OFF (kill is false)
   //  11: user's pong game, safety ON (kill is true)

   wire        display_game; // 1 to display the game on VGA
   wire        in_flight; // 1 if drone is commanded to be flying
	wire [7:0] x_velocity,y_velocity;
	
   assign display_game = DISPLAY_KILL != 2'b01;
   assign kill = DISPLAY_KILL != 2'b10;      
   assign in_flight = ~(halt || kill) && display_game;
	assign airborne = 1;
	assign stable = 1;

	
   controls controls(
            .reference_vx(velocity_x),
            .reference_vy(velocity_y),
            .airborne(airborne),
            .in_flight(in_flight),
            .stable(stable),
            .cmd_vx(x_velocity),
            .cmd_vy(y_velocity)
   );

   // -------------------------------------------------------------------------
   // Communications
   // -------------------------------------------------------------------------

	wire [7:0] data_in,commanded;
	wire done_send,command_ready;
	wire [3:0] state_bret;
	
	comms_command_center command(.start(switch[3]),.clock(clock_27mhz), .reset(reset), 
	.sensor_data(data_in), .connected(), .in_the_air(), .takeoff_land(switch[2]),.done_sending(done_send),
	.up(), .right(), .down(), .left(), .done_sending_sens(),
	.command(commanded),.roll_and_pitch(),.state(state_bret),.command_ready(command_ready));
	
	transmit_to_drone tx(.clock(clock_27mhz),.command_ready(command_ready),
	.command(commanded),.x_velocity(x_velocity),.y_velocity(y_velocity),
	.tx_out(user3[0]),.done_sending(done_send));
	
	rx_from_drone rx(.clock_27mhz(clock_27mhz),.data(user3[1]),.data_receive(data_in));
	
	
   // -------------------------------------------------------------------------
   // Display select - pong vs video coord
   // -------------------------------------------------------------------------

   // select output pixel data

   wire [63:0] disp_hsv_puck, disp_hsv_paddle1, disp_hsv_paddle2;
   wire [63:0] disp_sel_puck, disp_sel_paddle1, disp_sel_paddle2;
   wire [63:0] disp_coord_puck, disp_coord_paddle1, disp_coord_paddle2;
	wire [63:0] disp_velocity_puck;

   assign disp_hsv_puck = {h1_max_puck,h1_min_puck, h2_max_puck,h2_min_puck, s_max_puck,s_min_puck, v_max_puck,v_min_puck};
   assign disp_hsv_paddle1 = {h1_max_paddle1,h1_min_paddle1, h2_max_paddle1,h2_min_paddle1, s_max_paddle1,s_min_paddle1, v_max_paddle1,v_min_paddle1};
   assign disp_hsv_paddle2 = {h1_max_paddle2,h1_min_paddle2, h2_max_paddle2,h2_min_paddle2, s_max_paddle2,s_min_paddle2, v_max_paddle2,v_min_paddle2};

   assign disp_sel_puck = {16'b0, 8'b0,h_sel_puck, 8'b0,s_sel_puck, 8'b0,v_sel_puck};
   assign disp_sel_paddle1 = {16'b0, 8'b0,h_sel_paddle1, 8'b0,s_sel_paddle1, 8'b0,v_sel_paddle1};
   assign disp_sel_paddle2 = {16'b0, 8'b0,h_sel_paddle2, 8'b0,s_sel_paddle2, 8'b0,v_sel_paddle2};

   assign disp_coord_puck = {5'b0,x_center_puck, 6'b0,y_center_puck, 5'b0,adj_x_puck, 6'b0,adj_y_puck};
   assign disp_coord_paddle1 = {5'b0,x_center_paddle1, 6'b0,y_center_paddle1, 5'b0,adj_x_paddle1, 6'b0,adj_y_paddle1};
   assign disp_coord_paddle2 = {5'b0,x_center_paddle2, 6'b0,y_center_paddle2, 5'b0,adj_x_paddle2, 6'b0,adj_y_paddle2};
	
	assign disp_velocity_puck = {8'b0,x_velocity, 8'b0,y_velocity, 8'b0,velocity_x, 8'b0,velocity_y};
	
	reg [23:0] pixel; 
   reg b,hs,vs;
	
   always @(posedge clk) begin
      b <= blank;
      hs <= hsync;
      vs <= vsync;

      case (OBJ_SEL)
         PUCK: dispdata = (DISP_XY_HSV) ? disp_hsv_puck : disp_velocity_puck;
         PADDLE1: dispdata = (DISP_XY_HSV) ? disp_hsv_paddle1: disp_velocity_puck;
         PADDLE2: dispdata = (DISP_XY_HSV) ? disp_hsv_paddle2 : disp_velocity_puck;
         //PUCK: dispdata = (DISP_XY_HSV) ? disp_hsv_puck : disp_coord_puck;
         //PADDLE1: dispdata = (DISP_XY_HSV) ? disp_hsv_paddle1: disp_coord_paddle1;
         //PADDLE2: dispdata = (DISP_XY_HSV) ? disp_hsv_paddle2 : disp_coord_paddle2;
      endcase

      pixel <= (display_game) ? pong_pixel : video_coord_pixel; 
		
   end

   // -------------------------------------------------------------------------
   // final monitor visualization - currently used for debugging color detection, 
   //                                will later have pong game overlay
   // ------------------------------------------------------------------------- 

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clk.
	assign vga_out_red = pixel[23:16]; 
   assign vga_out_green = pixel[15:8]; 
   assign vga_out_blue = pixel[7:0];
	
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_pixel_clock = ~clk;
   assign vga_out_blank_b = ~b;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;

   // debugging
   assign led[7:4] = ~state_bret[3:0]; 


endmodule



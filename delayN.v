/////////////////////////////////////////////////////////////////////////////
// parameterized delay line - provided by staff
// 							  modified to take inputs of varying sizes

module delayN #(parameter NDELAY=22, parameter LENGTH = 10)(clk,in,out);
   input clk;
   input [LENGTH-1:0] in;
   output [LENGTH-1:0] out;

   reg [LENGTH-1:0] shiftreg [NDELAY:0];
   reg [4:0] i;

   always @(posedge clk) begin
		shiftreg[0] <= in;
		for(i=1; i<NDELAY+1; i=i+1) begin
			shiftreg[i] <= shiftreg[i-1];
		end
	end
	
	assign out = shiftreg[NDELAY];

endmodule

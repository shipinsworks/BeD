module dff(
	   clk,
	   rst,
	   din,
	   dout
	   );
   input clk;
   input rst;
   input din;
   output dout;

   reg 	  dout_r0;
   
   always @( posedge clk or posedge rst ) begin
      if( rst )
	dout_r0 <= 1'b0;
      else
	dout_r0 <= din;
   end
   assign dout = dout_r0;
   
endmodule // dff

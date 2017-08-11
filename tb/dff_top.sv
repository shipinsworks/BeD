`include "macro.svh"

module dff_top;

   logic clk;
   logic rst;

   initial begin
      clk = 1'b0;
      forever begin
	 #10 clk = ~clk;
      end
   end

   initial begin
      rst = 1'b1;
      #25 rst = 1'b0;
   end
   
   logic din;
   logic dout;

   initial begin
      `debug_printf(( "scenario call." ));
      scenario();
      
      din = 1'b0;
      #12 din = 1'b1;
      #10 din = 1'b0;
      $finish;
   end
   
   dff DUT(.clk(clk),
	   .rst(rst),
	   .din(din),
	   .dout(dout));

`include "dpi-c.svh"
`include "scenario_task.svh"
   
endmodule // dff_top

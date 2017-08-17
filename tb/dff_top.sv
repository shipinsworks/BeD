`include "macro.svh"
`include "s2cif.svh"
`include "drv_dff.sv"

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

   s2cif s2cif();
   
   logic din;
   logic dout;
   uint32_t ret;
   
   initial begin
      `debug_printf(( "scenario call." ));
      scenario();
      while( s2cif.check_end() != 0 ) begin
	 #(10); // recheck wait
      end
      $finish;
   end

   drv_dff #( .id(1) )
   drv_dff(
	   .s2cif(s2cif),
	   .clk(clk),
	   .rst(rst),
	   .din(din),
	   .dout(dout)
	   );

   dff DUT(.clk(clk),
	   .rst(rst),
	   .din(din),
	   .dout(dout));

   // 強制的な時間停止
`ifdef STOP_TIME
   initial begin
      #(`STOP_TIME) $finish();
   end
`endif

`include "scenario_task.svh"
`include "dpi-c.svh"
   
endmodule // dff_top

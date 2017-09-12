`include "macro.svh"
`include "drv_s2cif.sv"
`include "s2cif.svh"

module dff_s2cif_top;


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
      s2cif.check_end( ret );
      while( ret == 0 ) begin // 完了不可の間、待つ
	 #(10); // recheck wait
	 s2cif.check_end( ret );
      end
      `debug_printf(("check_end ret:%d",ret));
      $finish;
   end

   drv_s2cif #( .id(1) )
   drv_s2cif(
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
   
endmodule // dff_s2cif_top

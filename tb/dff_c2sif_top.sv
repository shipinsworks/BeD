`include "macro.svh"
`include "c2sif.svh"
`include "drv_c2sif.sv"

module dff_c2sif_top;

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

   // シナリオ側からのデータ投入インタフェース
   c2sif c2sif();
   
   logic din;
   logic dout;
   int 	 ret;
   
   initial begin
      `debug_printf(( "scenario call." ));
      scenario();
      // シナリオからのリターンで終了
      #100 $finish;
   end

   // シナリオからのデータを論理に入力するドライバ
   drv_c2sif #( .id(1) )
   drv_c2sif(
	   .c2sif(c2sif),
	   .clk(clk),
	   .rst(rst),
	   .din(din),
	   .dout(dout)
	   );

   // 検証対象論理
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

   // DPI-C用各種定義
`include "scenario_task.svh"
`include "dpi-c.svh"
   
endmodule // dff_top

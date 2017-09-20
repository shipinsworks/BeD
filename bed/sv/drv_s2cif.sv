`include "macro.svh"
`include "s2cif.svh"

// シナリオ側へ要求してデータ投入するドライバモジュール
module drv_s2cif
  #(
    parameter id = 0,
    parameter din_delay = 0
    )
   (
    s2cif s2cif,
    input logic clk,
    input logic rst,
    output logic din,
    input logic dout
    );

   logic 	din_r0;
   uint32_t     addr = 0;
   uint32_t     size = 1;
   uint32_t     data[`S2CIF_DATA_SIZE];
   int 		ret;

   // 応答関数の設定要求
   initial begin
      s2cif.func_setup( id, 0, &ret ); // dff_get_data
      if( ret != 0 ) $finish();
      s2cif.func_setup( id, 1, &ret ); // dff_put_data
      if( ret != 0 ) $finish();
   end

   // クロックの立ち上がりでデータを要求
   always @( posedge clk, posedge rst ) begin
      if( rst == 1'b1 )
	din_r0 <= 1'b0;
      else begin
	 s2cif.data_pull_call( id, 0, addr, size, ret, data ); // dff_get_data
	 `debug_printf(("data_pull_call called: ret:%d",ret));
	 if( ret == 0 ) begin
	    din_r0 <= data[0] & 1'b1;
	    `debug_printf(("din_r0:%d",din_r0));
	 end
	 else if( ret < 0 ) din_r0 <= 1'b0; // data end
	 else begin
	    `error_printf(("ret:%d", ret));
	    #1 $finish();
	 end
      end
   end

   assign #(din_delay) din = din_r0;

   // シナリオ側への信号出力
   always @( posedge clk ) begin
      if( rst == 1'b0 ) begin
	 data[0] = { 31'h0, dout };
	 `debug_printf(("data_push_call data[0]: %08x",data[0]));
	 s2cif.data_push_call( id, 1, addr, size, ret, data );
	 `debug_printf(("data_push_call called: ret:%d",ret));
      end
   end
   
endmodule // drv_s2cif

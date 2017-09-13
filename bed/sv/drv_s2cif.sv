`include "macro.svh"
`include "s2cif.svh"

// シナリオ側へ要求してデータ投入するドライバモジュール
module drv_s2cif
  #(
    parameter id = 0
    )
   (
    s2cif s2cif,
    input logic clk,
    input logic rst,
    output logic din,
    input logic dout
    );

   logic 	din_r0;
   uint32_t     data[`S2CIF_DATA_SIZE];
   int 		ret;

   // 応答関数の設定要求
   initial begin
      s2cif.func_setup( id, 0, &ret ); // dff_get_data
      if( ret != 0 ) $finish();
   end

   // クロックの立ち上がりでデータを要求
   always @( posedge clk, posedge rst ) begin
      if( rst == 1'b1 )
	din_r0 <= 1'b0;
      else begin
	 s2cif.func_call( id, 0, ret, data ); // dff_get_data
	 `debug_printf(("func_call called: ret:%d",ret));
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

   assign din = din_r0;
   
endmodule // drv_s2cif

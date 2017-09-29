`include "macro.svh"
`include "c2sif.svh"

// シナリオ側から指示によりデータを投入するドライバモジュール
module drv_c2sif
  #(
    parameter id = 0,
    parameter din_write_delay = 5,
    parameter dout_read_delay = 2
    )
   (
    c2sif        c2sif,
    input logic  clk,
    input logic  rst,
    output logic din = 1'b0,
    input logic  dout
    );

   logic 	 din_r0 = 1'b0;
   logic 	 push_req;
   event 	 push_event;
   logic 	 dout_r0 = 1'b0;
   logic 	 pull_req;
   event 	 pull_event;
   
   // シナリオからの指示を処理する関数
   task get_packet();
      forever begin
	 @( posedge c2sif.req ); // シナリオ側からの呼び出し待ち
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    case( c2sif.fn )
	      `C2SIF_FN_DATA_WRITE: begin // write
		 c2sif.ret = 0;
		 din_r0 = c2sif.data[0] & 1'b1;
		 push_req = 1'b1;
		 @( push_event.triggered );
		 `debug_printf(("push_event get"));
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: `C2SIF_FN_DATA_WRITE
	      `C2SIF_FN_DATA_READ: begin // read
		 pull_req = 1'b1;
		 @( pull_event.triggered );
		 c2sif.ret = 0;
		 c2sif.data[0] = 32'h0 | dout_r0;
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: `C2SIF_FN_DATA_READ
	    endcase
	 end // if ( c2sif.id == id )
      end
   endtask // get_packet

   // タスクの起動（このドライバではタスクが１つ）
   initial begin
      push_req = 1'b0;
      pull_req = 1'b0;
      fork
	 get_packet();
      join;
   end

   // リセット中は信号ドライブを待つ。
   always @( posedge clk ) begin
      if(( rst == 1'b0 ) && ( push_req == 1'b1 )) begin
	 `debug_printf(("get push_req:1"));
	 push_req = 1'b0;
	 #(din_write_delay);
	 `debug_printf(("din valid set"));
	 din = din_r0;
	 -> push_event;
      end
   end // always @ ( posedge clk or posedge rst )

   always @( posedge clk ) begin
      if(( rst == 1'b0 ) && ( pull_req == 1'b1 )) begin
	 `debug_printf(("get pull_req:1"));
	 pull_req = 1'b0;
	 #(dout_read_delay);
	 dout_r0 = dout;
	 -> pull_event;
      end
   end
   
endmodule // drv_one_signal

`include "macro.svh"
`include "c2sif.svh"

// シナリオ側から指示によりデータを投入するドライバモジュール
module drv_c2sif
  #(
    parameter id = 0,
    parameter din_delay = 0,
    parameter dout_delay = 1
    )
   (
    c2sif        c2sif,
    input logic  clk,
    input logic  rst,
    output logic din,
    input logic  dout
    );

   logic 	 din_r0;
   logic 	 din_r1;
   event 	 push_event;
   logic 	 dout_r0;
   event 	 pull_event;

   // シナリオからの指示を処理する関数
   task get_packet();
      forever begin
	 @( posedge c2sif.req ); // シナリオ側からの呼び出し待ち
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    case( c2sif.fn )
	      0: begin // write
		 din_r0 = c2sif.data[0] & 1'b1;
		 c2sif.ret = 0;
		 @( push_event.triggered );
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: 0
	      1: begin // read
		 @( pull_event.triggered );
		 c2sif.ret = 0;
		 c2sif.data[0] = 32'h0 | dout; // データ取り込み
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end
	    endcase
	 end // if ( c2sif.id == id )
      end
   endtask // get_packet

   // タスクの起動（このドライバではタスクが１つ）
   initial begin
      fork
	 get_packet();
      join;
   end

   always @( posedge clk or posedge rst ) begin
      if( rst == 1'b1 )
	din_r1 <= 1'b0;
      else begin
	 din_r1 <= din_r0;
	 -> push_event;
      end
   end
   assign #(din_delay) din = din_r1;

   always @( posedge clk ) begin
      if( rst == 1'b0 ) begin
	 #(dout_delay); // データの取り込みはalways文中ではやらない
	 -> pull_event; // pull_eventとデータ取り込みのタイミングの問題
      end
   end
   
endmodule // drv_one_signal

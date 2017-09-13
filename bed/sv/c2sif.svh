`ifndef _C2SIF_SVH_
 `define _C2SIF_SVH_

 `include "macro.svh"

// シナリオ側マスタのインタフェース
interface c2sif();
   // sim_timeを消費しないでＣ言語側と通信するための２信号
   logic req;
   logic ack;
   // インタフェースの通信用変数
   uint32_t id;
   uint32_t fn;
   uint32_t addr;
   uint32_t data[0:`C2SIF_DATA_SIZE-1];
   int ret;

   // 通信信号の初期化
   initial begin
      req = 1'b0;
      ack = 1'b0;
   end

   // シナリオからの関数呼び出しは、scenario()関数スコープで実行されるため、
   // scenario()関数を呼び出したモジュール上の関数のみ
   // write_packet()関数は、c2s_write_packet()関数を経由して呼び出される
   task write_packet( inout c2sif_pkt_s pkt );
      if( ack == 1 ) begin
	 @( negedge ack );
	 `debug_printf(("found ack: 0"));
      end
      id = pkt.id;
      fn = pkt.fn;
      addr = pkt.addr;
      for( int i=0; i<`C2SIF_DATA_SIZE; i++ ) begin
	 data[i] = pkt.data[i];
      end
      req = 1'b1;
      `debug_printf(("set req: 1"));
      @( posedge ack );
      `debug_printf(("found ack: 1"));
      pkt.ret = ret;
      `debug_printf(("pkt.ret: %d",pkt.ret));
      req = 1'b0;
      `debug_printf(("set req: 0"));
      @( negedge ack );
      `debug_printf(("found ack: 0"));
   endtask // write_packet

   // read_packet()関数は、c2s_read_packet()関数を経由して呼び出される
   task read_packet( inout c2sif_pkt_s pkt );
      if( ack == 1 ) begin
	 @( negedge ack );
	 `debug_printf(("found ack: 0"));
      end
      id = pkt.id;
      fn = pkt.fn;
      addr = pkt.addr;
      req = 1'b1;
      `debug_printf(("set req: 1"));
      @( posedge ack );
      `debug_printf(("found ack: 1"));
      for( int i=0; i<`C2SIF_DATA_SIZE; i++ ) begin
	 pkt.data[i] = data[i];
      end
      pkt.ret = ret;
      `debug_printf(("pkt.ret: %d",pkt.ret));
      req = 1'b0;
      `debug_printf(("set req: 0"));
      @( negedge ack );
      `debug_printf(("found ack: 0"));
   endtask // read_packet
   
endinterface // c2sif

`endif

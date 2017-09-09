`ifndef _C2SIF_SVH_
 `define _C2SIF_SVH_

 `include "macro.svh"

interface c2sif();
   logic req;
   logic ack;
   
   uint32_t id;
   uint32_t fn;
   uint32_t addr;
   uint32_t data[0:`C2SIF_DATA_SIZE-1];
   int ret;

   initial begin
      req = 1'b0;
      ack = 1'b0;
   end

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
   endtask // send_packet
   
endinterface // c2sif

`endif

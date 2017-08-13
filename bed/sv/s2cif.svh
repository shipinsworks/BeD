`ifndef _S2CIF_SVH_
 `define _S2CIF_SVH_

 `include "macro.svh"

 `define S2CIF_DATA_SIZE 16
typedef struct {
   uint32 id;
   uint32 fn;
   uint32 ret;
   uint32 data[0:`S2CIF_DATA_SIZE-1];
} pkt_s;

interface s2cif();
   bit 	       req;
   
   initial begin
      req = 0;
   end
   
   task automatic get_data( inout pkt_s pkt );
      if( req == 1 ) @( negedge req ); // 他のＩＤからのリクエスト完了待ち
      req = 1;
      sc_get_data( pkt );
      req = 0;
   endtask // get_data
   
endinterface // s2cif

`endif

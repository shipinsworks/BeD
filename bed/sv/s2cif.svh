`ifndef _S2CIF_SVH_
 `define _S2CIF_SVH_

 `include "macro.svh"

 `define S2CIF_DATA_SIZE 16
typedef struct {
   uint32_t id;
   uint32_t fn;
   uint32_t ret;
   uint32_t data[0:`S2CIF_DATA_SIZE-1];
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

   task automatic func_setup( input uint32_t id, input uint32_t fn, output uint32_t ret );
      pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      s2c_s_func_setup( pkt );
      ret = pkt.ret;
   endtask // s2c_s_func_setup

   task automatic func_call( input uint32_t id, input uint32_t fn, output uint32_t ret, output uint32_t data[`S2CIF_DATA_SIZE] );
      pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      s2c_func_call( pkt );
      data = pkt.data;
      ret = pkt.ret;
   endtask // func_call
   
endinterface // s2cif

`endif

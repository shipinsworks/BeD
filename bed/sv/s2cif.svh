`ifndef _S2CIF_SVH_
 `define _S2CIF_SVH_

 `include "macro.svh"

interface s2cif();
   bit req;
   
   initial begin
      req = 0;
   end
   
   task automatic get_data( input int unsigned id, input int unsigned fn, output int unsigned ret, output int unsigned data[`S2CIF_DATA_SIZE] );
      if( req == 1 ) @( negedge req ); // 他のＩＤからのリクエスト完了待ち
      req = 1;
      sc_get_data( id, fn, ret, data );
      req = 0;
   endtask // get_data
   
endinterface // s2cif

`endif

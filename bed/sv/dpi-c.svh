`ifndef _DPI_C_SVH_
 `define _DPI_C_SVH_

   import "DPI-C" context task scenario();
   import "DPI-C" task sc_get_data( inout pkt_s pkt );
   import "DPI-C" task s2c_s_func_setup( inout pkt_s pkt );
   import "DPI-C" task s2c_func_call( inout pkt_s pkt );
   export "DPI-C" task cs_printf;
   export "DPI-C" task dbg_printf;
   
`endif

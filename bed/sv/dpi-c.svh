`ifndef _DPI_C_SVH_
 `define _DPI_C_SVH_

   import "DPI-C" context task scenario();
   import "DPI-C" task s2c_check_end( inout pkt_s pkt );
   import "DPI-C" task s2c_s_func_setup( inout pkt_s pkt );
   import "DPI-C" task s2c_func_call( inout pkt_s pkt );
   export "DPI-C" function c2s_printf;
   export "DPI-C" function c2s_debug_printf;
   export "DPI-C" function c2s_error_printf;
   export "DPI-C" task c2s_send_packet;
   
`endif

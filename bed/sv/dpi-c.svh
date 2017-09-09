`ifndef _DPI_C_SVH_
 `define _DPI_C_SVH_

   import "DPI-C" context task scenario();

 `ifdef _S2CIF_SVH_
   import "DPI-C" task s2c_check_end( inout s2cif_pkt_s pkt );
   import "DPI-C" task s2c_s_func_setup( inout s2cif_pkt_s pkt );
   import "DPI-C" task s2c_func_call( inout s2cif_pkt_s pkt );
 `endif
   
   export "DPI-C" function c2s_printf;
   export "DPI-C" function c2s_debug_printf;
   export "DPI-C" function c2s_error_printf;
`ifdef _C2SIF_SVH_
   export "DPI-C" task c2s_write_packet;
   export "DPI-C" task c2s_read_packet;
`endif
   
`endif

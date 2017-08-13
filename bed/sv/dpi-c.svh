`ifndef _DPI_C_SVH_
 `define _DPI_C_SVH_

   import "DPI-C" context task scenario();
//   import "DPI-C" task sc_get_data( input int unsigned id, input int unsigned fn, output int unsigned ret, output int unsigned data[`S2CIF_DATA_SIZE] );
   import "DPI-C" task sc_get_data( inout pkt_s pkt );
   
   export "DPI-C" task cs_printf;
   
`endif

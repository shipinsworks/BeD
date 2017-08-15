`ifndef _MACRO_SVH_
 `define _MACRO_SVH_

 `define error_printf( msg ) $display( "[Error   ] %8d : %s(%1d) %s", $stime, `__FILE__, `__LINE__, $sformatf msg )

`ifdef DEBUG
 `define debug_printf( msg ) $display( "[Debug   ] %8d : %s(%1d) %s", $stime, `__FILE__, `__LINE__, $sformatf msg )
`else
 `define debug_printf( msg )
`endif

typedef int unsigned uint32;

`endif

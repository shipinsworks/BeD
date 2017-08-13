`ifndef _MACRO_SVH_
 `define _MACRO_SVH_

`ifdef DEBUG
 `define debug_printf( msg ) $display( "[Debug   ] %8d : %s", $stime, $sformatf( msg ))
`else
 `define debug_printf( msg )
`endif

typedef int unsigned uint32;

`endif

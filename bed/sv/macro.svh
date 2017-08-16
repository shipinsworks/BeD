`ifndef _MACRO_SVH_
 `define _MACRO_SVH_

function string basename( string p );
   int i;
   for( i = p.len(); i>=0; i-- ) begin
      if( p[i] == "/" ) break;
   end
   if( i < 0 ) return p;
   else begin
      return p.substr(i+1,p.len()-1);
   end
endfunction // basename

 `define error_printf( msg ) $display( "[Error   ] %8d : %s(%1d) %s", $stime, basename( `__FILE__ ), `__LINE__, $sformatf msg )

`ifdef DEBUG
 `define debug_printf( msg ) $display( "[Debug   ] %8d : %s(%1d) %s", $stime, basename( `__FILE__ ), `__LINE__, $sformatf msg )
`else
 `define debug_printf( msg )
`endif

typedef int unsigned uint32_t;

`endif

`ifndef _SCENARIO_TASK_SVH_
 `define _SCENARIO_TASK_SVH_
 `include "macro.svh"

function automatic void c2s_printf( input string msg );
   $display( "[Scenario] %8d : %s", $stime, msg );
endfunction // cs_printf

function automatic void c2s_debug_printf( input string msg );
   $display( "[C_Debug ] %8d : %s", $stime, msg );
endfunction // dbg_printf

function automatic void c2s_error_printf( input string msg );
   $display( "[C_Error ] %8d : %s", $stime, msg );
endfunction // error_printf

`ifdef _C2SIF_SVH_
task automatic c2s_write_packet( inout c2sif_pkt_s pkt );
   c2sif.write_packet( pkt );
   `debug_printf(("ret: %d", pkt.ret));
endtask // c2s_send_packet
`endif

`endif

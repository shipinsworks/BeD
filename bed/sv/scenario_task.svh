`ifndef _SCENARIO_TASK_SVH_
 `define _SCENARIO_TASK_SVH_

function automatic void c2s_printf( input string msg );
   $display( "[Scenario] %8d : %s", $stime, msg );
endfunction // cs_printf

function automatic void c2s_debug_printf( input string msg );
   $display( "[C_Debug ] %8d : %s", $stime, msg );
endfunction // dbg_printf

function automatic void c2s_error_printf( input string msg );
   $display( "[C_Error ] %8d : %s", $stime, msg );
endfunction // error_printf

task automatic c2s_send_packet( inout c2sif_pkt_s pkt );
   pkt.ret = 76543210;
   $display( "[C2SIF   ] data[0]: 0x%08x ret: %d", pkt.data[0], pkt.ret );
endtask // c2s_send_packet

`endif

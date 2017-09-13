`ifndef _SCENARIO_TASK_SVH_
 `define _SCENARIO_TASK_SVH_
 `include "macro.svh"

// シナリオのprint要求をSimログに出力するための関数
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
// シナリオ側からの転送要求の受け関数（処理はC2SIFインタフェースの中）
task automatic c2s_write_packet( inout c2sif_pkt_s pkt );
   c2sif.write_packet( pkt );
   `debug_printf(("ret: %d", pkt.ret));
endtask // c2s_write_packet

task automatic c2s_read_packet( inout c2sif_pkt_s pkt );
   c2sif.read_packet( pkt );
   `debug_printf(("ret: %d data[0]: %08x",pkt.ret,pkt.data[0]));
endtask // c2s_read_packet

`endif

`endif

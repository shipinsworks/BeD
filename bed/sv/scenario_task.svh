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

`endif

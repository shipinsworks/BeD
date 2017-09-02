`ifndef _SCENARIO_TASK_SVH_
 `define _SCENARIO_TASK_SVH_

function automatic void cs_printf( input string msg );
   $display( "[Scenario] %8d : %s", $stime, msg );
endfunction // cs_printf

function automatic void dbg_printf( input string msg );
   $display( "[C_Debug ] %8d : %s", $stime, msg );
endfunction // dbg_printf

`endif

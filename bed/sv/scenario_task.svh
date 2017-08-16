`ifndef _SCENARIO_TASK_SVH_
 `define _SCENARIO_TASK_SVH_

task cs_printf( input string msg );
   $display( "[Scenario] %8d : %s", $stime, msg );
endtask // cs_printf

task dbg_printf( input string msg );
   $display( "[C_Debug ] %8d : %s", $stime, msg );
endtask // dbg_printf

// 強制的な時間停止
`ifdef STOP_TIME
initial begin
   #(`STOP_TIME) $finish();
end
`endif
   
`endif

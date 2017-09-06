`include "macro.svh"
`include "c2sif.svh"

module drv_c2sif
  #(
    parameter id = 0
    )
   (
    c2sif        c2sif,
    input logic  clk,
    input logic  rst,
    output logic din,
    input logic  dout
    );

   // logic 	 din_r0;
   // pkt_s         pkt;
   // int 		 ret;

   // always @( c2sif.req ) begin
   //    if(( c2sif.id == id ) && ( c2sif.fn == 0 )) begin
   // 	 if( c2sif.req == 1'b1 ) begin
   // 	    din_wk = c2sif.data[0];
   // 	    c2sif.ack = 1'b1;
   // 	 end
   // 	 else if( c2sif.req == 1'b0 ) begin
   // 	    c2sif.ack = 1'b0;
   // 	 end
   //    end
   // end

endmodule // drv_one_signal

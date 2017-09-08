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

   task get_packet();
      forever begin
	 @( posedge c2sif.req );
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    if( c2sif.fn == 0 ) begin // write
	       `debug_printf(("data: 0x%08x",c2sif.data[0]));
	       c2sif.ret = 3210;
	       c2sif.ack = 1;
	       `debug_printf(("set ack: 1"));
	       @( negedge c2sif.req );
	       `debug_printf(("found req: 0"));
	       c2sif.ack = 0;
	       `debug_printf(("set ack: 0"));
	    end
	 end // if ( c2sif.id == id )
      end
   endtask // get_packet

   initial begin
      fork
	 get_packet();
      join;
   end
   
endmodule // drv_one_signal

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

   logic 	 din_r0;
   logic 	 din_r1;
   event 	 push_event;
   
   task get_packet();
      forever begin
	 @( posedge c2sif.req );
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    if( c2sif.fn == 0 ) begin // write
	       `debug_printf(("data: 0x%08x",c2sif.data[0]));
	       din_r0 = c2sif.data[0] & 1'b1;
	       c2sif.ret = 0;
	       @( push_event.triggered );
	       c2sif.ack = 1'b1;
	       `debug_printf(("set ack: 1"));
	       @( negedge c2sif.req );
	       `debug_printf(("found req: 0"));
	       c2sif.ack = 1'b0;
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

   always @( posedge clk or posedge rst ) begin
      if( rst == 1'b1 )
	din_r1 <= 1'b0;
      else begin
	 din_r1 <= din_r0;
	 -> push_event;
      end
   end
   assign din = din_r1;
   
endmodule // drv_one_signal

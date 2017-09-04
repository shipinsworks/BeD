`include "macro.svh"
`include "s2cif.svh"

module drv_dff
  #(
    parameter id = 0
    )
   (
    s2cif s2cif,
    input logic clk,
    input logic rst,
    output logic din,
    input logic dout
    );

   logic 	din_r0;
   pkt_s pkt;
   
   int ret;

   initial begin
      s2cif.func_setup( id, 0, &ret ); // dff_get_data
      if( ret != 0 ) $finish();
   end
   
   always @( posedge clk, posedge rst ) begin
      if( rst == 1'b1 )
	din_r0 <= 1'b0;
      else begin
	 pkt.id = id;
	 pkt.fn = 0;
	 s2cif.func_call( id, 0, ret, pkt.data ); // dff_get_data
	 `debug_printf(("func_call called: ret:%d",ret));
	 if( ret == 0 ) begin
	    din_r0 <= pkt.data[0] & 1'b1;
	    `debug_printf(("din_r0:%d",din_r0));
	 end
	 else if( ret < 0 ) din_r0 <= 1'b0; // data end
	 else begin
	    `error_printf(("ret:%d", ret));
	    #1 $finish();
	 end
      end
   end

endmodule // drv_dff

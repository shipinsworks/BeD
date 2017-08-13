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
   
   uint32 ret;
   
   always @( posedge clk, posedge rst ) begin
      if( rst == 1'b1 )
	din_r0 <= 1'b0;
      else begin
	 `debug_printf("call s2cif.get_data.");
	 pkt.id = id;
	 pkt.fn = 0;
	 s2cif.get_data( pkt );
	 `debug_printf($sformatf("data[0]:%08x", pkt.data[0]));
	 if( ret == 0 ) din_r0 <= pkt.data[0] & 1'b1;
	 else if( ret == 1 ) din_r0 <= 1'b0; // data end
	 else #100 $finish();
      end
   end

endmodule // drv_dff

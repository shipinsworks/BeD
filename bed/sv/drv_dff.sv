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
	 // `debug_printf($sformatf("id:%d fn:%d",id,0));
	 s2cif.func_call( id, 0, ret, pkt.data ); // dff_get_data
	 // `debug_printf($sformatf("data[0]:%08x", pkt.data[0]));
	 if( ret == 0 ) din_r0 <= pkt.data[0] & 1'b1;
	 else if( ret == 1 ) din_r0 <= 1'b0; // data end
	 else #100 $finish();
      end
   end

endmodule // drv_dff

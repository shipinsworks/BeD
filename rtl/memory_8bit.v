// 8bit Memory Module

`default_nettype none

  module memory_8bit #(
		       parameter integer C_S_AXI_ADDR_WIDTH = 32,
		       parameter integer C_MEMORY_SIZE = 512    // Word (not byte)
		       )(
			 input wire 			     clk,
			 input wire [C_S_AXI_ADDR_WIDTH-1:0] waddr,
			 input wire [7:0] 		     write_data,
		         input wire 			     write_enable,
			 input wire 			     byte_enable,
			 input wire [C_S_AXI_ADDR_WIDTH-1:0] raddr,
			 output wire [7:0] 		     read_data
			 );

   // Beyond Circuts, Constant Function in Verilog 2001を参照しました
   // http://www.beyond-circuits.com/wordpress/2008/11/constant-functions/
   function integer log2;
      input integer 					     addr;
      begin
	 addr = addr - 1;
	 for (log2=0; addr>0; log2=log2+1)
	   addr = addr >> 1;
      end
   endfunction

   reg        [7:0]    mem    [0:C_MEMORY_SIZE-1];
   wire [log2(C_MEMORY_SIZE)-1:0] mem_waddr;
   wire [log2(C_MEMORY_SIZE)-1:0] mem_raddr;
   integer 			  i;

   // initialization
   initial begin
      for (i=0; i < C_MEMORY_SIZE; i=i+1) begin
	 mem[i] = 8'd0;
      end
   end

   // The Address is byte address
   assign mem_waddr = waddr[(log2(C_MEMORY_SIZE)+log2((C_S_AXI_ADDR_WIDTH/8)))-1:log2((C_S_AXI_ADDR_WIDTH/8))];
   assign mem_raddr = raddr[(log2(C_MEMORY_SIZE)+log2((C_S_AXI_ADDR_WIDTH/8)))-1:log2((C_S_AXI_ADDR_WIDTH/8))];

   // Write
   always @(posedge clk) begin
      if (write_enable & byte_enable)
	mem[mem_waddr] <= write_data;
   end

   // Read
   // always @(posedge clk) begin
   assign read_data = mem[mem_raddr];
   // end
endmodule

`default_nettype wire


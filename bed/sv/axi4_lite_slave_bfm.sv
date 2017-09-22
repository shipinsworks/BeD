// AXI4-Lite Slave BFM
// データ幅：３２ビットのみサポート
// ３２ビット幅の読み書きのみサポート（WSTRB=4'hf固定）
`include "macro.svh"
`include "s2cif.svh"

module axi4_lite_slave_bfm
  #(
    parameter id = 0
    )
   (
    // DPI-C interface s->c
    s2cif s2cif,
    // System Signals
    input logic aclk,
    input logic aresetn,
    // Write Address Chanel Ports
    input logic [31:0] s_awaddr,
    input logic [3:0] s_awcache,
    input logic [2:0] s_awprot,
    input logic s_awvalid,
    output logic s_awready = 1,
    // Write Data Chanel Ports
    input logic [31:0] s_wdata,
    input logic [3:0]  s_wstrb,
    input logic s_wvalid,
    output logic s_wready = 0,
    // Write Respons Chanel Ports
    output logic [1:0] s_bresp = 2'b00,
    input logic s_bready,
    output logic s_bvalid = 0,
    // Read Address Chanel Ports
    input logic [31:0] s_araddr,
    input logic [3:0] s_arcache,
    input logic [2:0] s_arprot,
    input logic s_arvalid,
    output logic s_arready = 1,
    // Read Data Chanel Ports
    output logic [31:0] s_rdata = 32'h00000000,
    output logic [1:0] s_rresp = 2'b00,
    input logic s_rready,
    output logic s_rvalid = 0
    );

   int 		 awready_posedge_delay = 2;
   int 		 awready_negedge_delay = 2;
   int 		 wready_posedge_delay = 2;
   int 		 wready_negedge_delay = 2;
   int 		 bvalid_posedge_delay = 2;
   int 		 bvalid_negedge_delay = 2;
   int 		 arready_posedge_delay = 2;
   int 		 arready_negedge_delay = 2;
   int 		 rvalid_posedge_delay = 2;
   int 		 rvalid_negedge_delay = 2;

   int 		 ret;
   uint32_t  size = 1;
   
   // 応答関数の設定要求
   initial begin
      s2cif.func_setup( id, 1, &ret ); // axi4_lite_slave_write
      if( ret != 0 ) $finish();
      s2cif.func_setup( id, 2, &ret ); // axi4_lite_slave_read
      if( ret != 0 ) $finish();
   end

   logic [31:0] awaddr;
   logic [3:0] 	awcache;
   logic 	awready;
   int 		aw_state;
   
`define AW_IDLE     0
`define AW_GET_ADDR 1
`define AW_END_WAIT 2
   
   // Write Address Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b1 ) begin
	 case( aw_state )
	   `AW_IDLE: begin
	      if( s_awvalid == 1'b1 ) begin
		 awaddr = s_awaddr;
		 awcache = s_awcache;
		 awready = 1'b0;
		 aw_state = `AW_GET_ADDR;
	      end
	   end
	   `AW_GET_ADDR: begin
	      if( s_awvalid == 1'b0 ) begin
		 aw_state = `AW_END_WAIT;
	      end
	   end
	   `AW_END_WAIT: begin
	      if( s_bready == 1'b1 ) begin
		 awready = 1'b1;
		 aw_state = `AW_IDLE;
	      end
	   end
	 endcase
      end
   end

   always @( awready ) begin
      if( awready == 1'b1 )
	#(awready_posedge_delay) s_awready = awready;
      else
	#(awready_negedge_delay) s_awready = awready;
   end

   uint32_t     wdata[`S2CIF_DATA_SIZE];
   logic [3:0] 	wstrb;
   logic 	wready;
   int 		w_state;

`define W_IDLE     0
`define W_GET_DATA 1
`define W_END_WAIT 2
   
   // Write Data Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b1 ) begin
	 case( w_state )
	   `W_IDLE: begin
	      if( s_wvalid == 1'b1 ) begin
		 wdata[0] = s_wdata;
		 wstrb = s_wstrb;
		 wready = 1'b1;
		 w_state = `W_GET_DATA;
	      end
	   end
	   `W_GET_DATA: begin
	      wready = 1'b0;
	      w_state = `W_END_WAIT;
	   end
	   `W_END_WAIT: begin
	      if( s_bready == 1'b1 )
		w_state = `W_IDLE;
	   end
	 endcase
      end
   end
   
   always @( wready ) begin
      if( wready == 1'b1 )
	#(wready_posedge_delay) s_wready = wready;
      else
	#(wready_negedge_delay) s_wready = wready;
   end

   logic [1:0] bresp;
   logic       bvalid;
   int 	       b_state;
   
`define B_IDLE    0
`define B_RESP_ON 1

   // Write Response Cahanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b1 ) begin
	 case( b_state )
	   `B_IDLE: begin
	      if(( aw_state == `AW_END_WAIT ) && ( w_state == `W_END_WAIT )) begin
		 s2cif.data_push_call( id, 1, awaddr, size, ret, wdata ); // write data
		 if( ret == 0 )
		   bresp = 2'b00; // OKEY
		 else
		   bresp = 2'b10; // SLVERR
		 bvalid = 1'b1;
		 b_state = `B_RESP_ON;
	      end
	   end
	   `B_RESP_ON: begin
	      if( s_bready == 1'b1 ) begin
		 bvalid = 1'b0;
		 b_state = `B_IDLE;
	      end
	   end
	 endcase
      end
   end

   always @( bvalid ) begin
      if( bvalid == 1'b1 ) begin
	 #(bvalid_posedge_delay);
	 s_bvalid = bvalid;
	 s_bresp = bresp;
      end
      else begin
	 #(bvalid_negedge_delay);
	 s_bvalid = bvalid;
	 s_bresp = 2'b00;
      end
   end

   logic [31:0] araddr;
   logic [3:0] 	arcache;
   logic 	arready;
   logic [1:0] 	rresp;
   
   int 		ar_state;
   uint32_t data[`S2CIF_DATA_SIZE];
   
`define AR_IDLE     0
`define AR_GET_ADDR 1
`define AR_END_WAIT 2

   // Read Address Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b1 ) begin
	 case( ar_state )
	   `AR_IDLE: begin
	      if( s_arvalid == 1'b1 ) begin
		 araddr = s_araddr;
		 arcache = s_arcache;
		 s2cif.data_pull_call( id, 2, araddr, size, ret, data ); // read data
		 if( ret == 0 )
		   rresp = 2'b00;
		 else
		   rresp = 2'b10;
		 arready = 1'b0;
		 s_rdata = data[0];
		 ar_state = `AR_GET_ADDR;
	      end
	   end
	   `AR_GET_ADDR: begin
	      if( s_arvalid == 1'b0 ) begin
		 ar_state = `AR_END_WAIT;
	      end
	   end
	   `AR_END_WAIT: begin
	      if( s_rready == 1'b1 ) begin
		 arready = 1'b1;
		 ar_state = `AR_IDLE;
	      end
	   end
	 endcase
      end
   end

   always @( arready ) begin
      if( arready == 1'b1 )
	#(arready_posedge_delay) s_arready = arready;
      else
	#(arready_negedge_delay) s_arready = arready;
   end

   logic rvalid;
   int 	 r_state;
   
`define R_IDLE    0
`define R_RESP_ON 1
   
   // Read Data Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b1 ) begin
	 case( r_state )
	   `R_IDLE: begin
	      if( ar_state == `AR_END_WAIT ) begin
		 rvalid = 1'b1;
		 r_state = `R_RESP_ON;
	      end
	   end
	   `R_RESP_ON: begin
	      rvalid = 1'b0;
	      r_state = `R_IDLE;
	   end
	 endcase
      end
   end
   
   always @( rvalid ) begin
      if( rvalid == 1'b1 )
	#(rvalid_posedge_delay) s_rvalid = rvalid;
      else
	#(rvalid_negedge_delay) s_rvalid = rvalid;
   end

endmodule // axi4_lite_slave_bfm


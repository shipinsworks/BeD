// AXI4-Lite Slave BFM
// データ幅：３２ビットのみサポート
// ３２ビット幅の読み書きのみサポート（WSTRB=4'hf固定）
`include "macro.svh"
`include "s2cif.svh"
`include "c2sif.svh"

module axi4_lite_slave_bfm
  #(
    parameter id = 0
    )
   (
    // DPI-C interface s->c
    s2cif s2cif,
    c2sif c2sif,
    // System Signals
    input logic aclk,
    input logic aresetn,
    // Write Address Chanel Ports
    input logic [31:0] s_awaddr,
    input logic [3:0] s_awcache,
    input logic [2:0] s_awprot,
    input logic s_awvalid,
    output logic s_awready = 1'b0,
    // Write Data Chanel Ports
    input logic [31:0] s_wdata,
    input logic [3:0]  s_wstrb,
    input logic s_wvalid,
    output logic s_wready = 1'b0,
    // Write Respons Chanel Ports
    output logic [1:0] s_bresp = 2'b00,
    input logic s_bready,
    output logic s_bvalid = 1'b0,
    // Read Address Chanel Ports
    input logic [31:0] s_araddr,
    input logic [3:0] s_arcache,
    input logic [2:0] s_arprot,
    input logic s_arvalid,
    output logic s_arready = 1'b0,
    // Read Data Chanel Ports
    output logic [31:0] s_rdata = 32'h00000000,
    output logic [1:0] s_rresp = 2'b00,
    input logic s_rready,
    output logic s_rvalid = 1'b0
    );

   int 		 awready_positive_delay = 2;
   int 		 awready_negative_delay = 2;
   // 次のwriteアドレスの受け取りを引き延ばす
   int 		 awready_positive_wait_cycle = 0;
   int 		 wready_positive_delay = 2;
   int 		 wready_negative_delay = 2;
   // データの受け取りを引き延ばす
   int 		 wready_positive_wait_cycle = 0;
   int 		 bvalid_positive_delay = 2;
   int 		 bvalid_negative_delay = 2;
   // 応答を引き延ばす
   int 		 bvalid_positive_wait_cycle = 0;
   int 		 arready_positive_delay = 2;
   int 		 arready_negative_delay = 2;
   // 次のreadアドレスの受け取りを引き延ばす
   int 		 arready_positive_wait_cycle = 0;
   int 		 rvalid_positive_delay = 2;
   int 		 rvalid_negative_delay = 2;
   // 応答を引き延ばす
   int 		 rvalid_positive_wait_cycle = 0;

   int 		 ret;
   uint32_t  size = 1;
   int 		 cntr;
   
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
      if( aresetn == 1'b0 )
	awready = 1'b0;
      else begin
	 case( aw_state )
	   `AW_IDLE: begin
	      if( s_awvalid == 1'b1 ) begin
		 // アドレスを受け取る
		 awaddr = s_awaddr;
		 awcache = s_awcache;
		 awready = 1'b0;
		 aw_state = `AW_GET_ADDR;
	      end
	      else
		awready = 1'b1;
	   end
	   `AW_GET_ADDR: begin
	      if( s_awvalid == 1'b0 ) begin
		 aw_state = `AW_END_WAIT;
	      end
	   end
	   `AW_END_WAIT: begin
	      if( s_bready == 1'b1 ) begin
		 cntr = awready_positive_wait_cycle;
		 while( cntr > 0 ) begin
		    @( posedge aclk );
		    cntr --;
		 end
		 awready = 1'b1;
		 aw_state = `AW_IDLE;
	      end
	   end
	 endcase
      end
   end

   always @( awready ) begin
      if( awready == 1'b1 ) begin
	 #(awready_positive_delay) s_awready = awready;
	 `debug_printf(("awready = 1"));
      end
      else begin
	 #(awready_negative_delay) s_awready = awready;
	 `debug_printf(("awready = 0"));
      end
   end

   uint32_t     wdata[`S2CIF_DATA_SIZE];
   logic [3:0] 	wstrb = 4'hf;
   logic 	wready = 1'b0;
   int 		w_state;

`define W_IDLE     0
`define W_GET_DATA 1
`define W_END_WAIT 2
   
   // Write Data Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b0 )
	wready = 1'b0;
      else begin
	 case( w_state )
	   `W_IDLE: begin
	      if( s_wvalid == 1'b1 ) begin
		 wdata[0] = s_wdata;
		 wstrb = s_wstrb;
		 cntr = wready_positive_wait_cycle;
		 while( cntr > 0 ) begin
		    @( posedge aclk );
		    cntr --;
		 end
		 wready = 1'b1;
		 w_state = `W_GET_DATA;
	      end
	      else
		wready = 1'b0;
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
      if( wready == 1'b1 ) begin
	 #(wready_positive_delay) s_wready = wready;
	 `debug_printf(("wready = 1"));
      end
      else begin
	 #(wready_negative_delay) s_wready = wready;
	 `debug_printf(("wready = 0"));
      end
   end

   logic [1:0] bresp = 2'b00;
   logic       bvalid = 1'b0;
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
		 cntr = bvalid_positive_wait_cycle;
		 while( cntr > 0 ) begin
		    @( posedge aclk );
		    cntr --;
		 end
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
	 #(bvalid_positive_delay);
	 s_bvalid = bvalid;
	 s_bresp = bresp;
	 `debug_printf(("bvalid = 1"));
      end
      else begin
	 #(bvalid_negative_delay);
	 s_bvalid = bvalid;
	 s_bresp = 2'b00;
	 `debug_printf(("bvalid = 0"));
      end
   end

   logic [31:0] araddr = 32'h00000000;
   logic [3:0] 	arcache = 4'h2;
   logic 	arready = 1'b0;
   logic [1:0] 	rresp = 2'b00;
   
   int 		ar_state;
   uint32_t data[`S2CIF_DATA_SIZE];
   
`define AR_IDLE     0
`define AR_GET_ADDR 1
`define AR_END_WAIT 2

   // Read Address Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b0 ) begin
	 arready = 1'b0;
      end
      else begin
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
	      end // if ( s_arvalid == 1'b1 )
	      else
		arready = 1'b1;
	   end
	   `AR_GET_ADDR: begin
	      if( s_arvalid == 1'b0 ) begin
		 ar_state = `AR_END_WAIT;
	      end
	   end
	   `AR_END_WAIT: begin
	      if( s_rready == 1'b1 ) begin
		 cntr = arready_positive_wait_cycle;
		 while( cntr > 0 ) begin
		    @( posedge aclk );
		    cntr --;
		 end
		 arready = 1'b1;
		 ar_state = `AR_IDLE;
	      end
	   end
	 endcase
      end
   end

   always @( arready ) begin
      if( arready == 1'b1 ) begin
	 #(arready_positive_delay) s_arready = arready;
	 `debug_printf(("arready = 1"));
      end	 
      else begin
	 #(arready_negative_delay) s_arready = arready;
	 `debug_printf(("arready = 0"));
      end	 
   end

   logic rvalid = 1'b0;
   int 	 r_state;
   
`define R_IDLE    0
`define R_RESP_ON 1
`define R_END     2
   
   // Read Data Chanelの応答
   always @( posedge aclk ) begin
      if( aresetn == 1'b0 )
	rvalid = 1'b0;
      else begin
	 case( r_state )
	   `R_IDLE: begin
	      if( ar_state == `AR_END_WAIT ) begin
		 cntr = rvalid_positive_wait_cycle;
		 while( cntr > 0 ) begin
		    @( posedge aclk );
		    cntr --;
		 end
		 rvalid = 1'b1;
		 r_state = `R_RESP_ON;
	      end
	      else
		rvalid = 1'b0;
	   end
	   `R_RESP_ON: begin
	      if( s_rready == 1'b1 ) begin
		 rvalid = 1'b0;
		 r_state = `R_END;
	      end
	   end
	   `R_END: begin
	      if( ar_state == `AR_IDLE )
		r_state = `R_IDLE;
	   end
	 endcase
      end
   end
   
   always @( rvalid ) begin
      if( rvalid == 1'b1 ) begin
	 #(rvalid_positive_delay) s_rvalid = rvalid;
	 `debug_printf(("rvalid = 1"));
      end
      else begin
	 #(rvalid_negative_delay) s_rvalid = rvalid;
	 `debug_printf(("rvalid = 0"));
      end
   end

   // シナリオからの指示を処理する関数
   task get_packet();
      forever begin
	 @( posedge c2sif.req ); // シナリオ側からの呼び出し待ち
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    case( c2sif.fn )
	      0: begin // setup
		 awready_positive_wait_cycle = c2sif.data[0];
		 wready_positive_wait_cycle = c2sif.data[1];
		 bvalid_positive_wait_cycle = c2sif.data[2];
		 arready_positive_wait_cycle = c2sif.data[3];
		 rvalid_positive_wait_cycle = c2sif.data[4];
		 `debug_printf(("awready_positive_wait_cycle : %d",awready_positive_wait_cycle));
		 c2sif.ret = 0;
		 // C2SIFとのハンドシェイク
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: 0
	    endcase
	 end // if ( c2sif.id == id )
      end
   endtask // get_packet
   
   // DPI-Cインタフェースのタスク起動（このドライバではタスクが１つ）
   initial begin
      fork
	 get_packet();
      join;
   end
   
endmodule // axi4_lite_slave_bfm


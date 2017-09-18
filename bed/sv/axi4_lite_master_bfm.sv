// AXI4-Lite Master BFM
// データ幅：３２ビットのみサポート
// ３２ビット幅の読み書きのみサポート（WSTRB=4'hf固定）
`include "macro.svh"
`include "c2sif.svh"

module axi4_lite_master_bfm
  #(
    parameter id = 0,
    parameter reset_negative_after_delay = 30, // リセット終了後の未反応期間
    parameter awvalid_positive_delay = 2,
    parameter awvalid_negative_delay = 2,
    parameter wvalid_positive_delay = 2,
    parameter wvalid_negative_delay = 2,
    parameter bready_positive_delay = 2,
    parameter bready_negative_delay = 2,
    parameter arvalid_positive_delay = 2,
    parameter arvalid_negative_delay = 2,
    parameter rready_positive_delay = 2,
    parameter rready_negative_delay = 2
    )
   (
    // DPI-C interface c->s
    c2sif c2sif,
    // System Signals
    input logic aclk,
    input logic aresetn,
    // Write Address Chanel Ports
    output logic [31:0] m_awaddr = 0,
    output logic [3:0] m_awcache = 3,
    output logic [2:0] m_awprot = 0,
    output logic m_awvalid = 0,
    input logic m_awready,
    // Write Data Chanel Ports
    output logic [31:0] m_wdata = 0,
    output logic [3:0]  m_wstrb = 4'hf,
    output logic m_wvalid = 0,
    input logic m_wready,
    // Write Respons Chanel Ports
    input logic [1:0] m_bresp,
    output logic m_bready = 0,
    input logic m_bvalid,
    // Read Address Chanel Ports
    output logic [31:0] m_araddr = 0,
    output logic [3:0] m_arcache = 2,
    output logic [2:0] m_arprot = 0,
    output logic m_arvalid = 0,
    input logic m_arready,
    // Read Data Chanel Ports
    input logic [31:0] m_rdata,
    input logic [1:0] m_rresp,
    output logic m_rready = 0,
    input logic m_rvalid
    );

   // C2SIF インタフェース用
   logic [31:0] gp_awaddr;
   logic [31:0] gp_wdata;
   logic 	gp_write_flag;
   event 	gp_write_end_event;
   logic [31:0] gp_araddr;
   logic [31:0] gp_rdata;
   logic 	gp_read_flag;
   event 	gp_read_end_event;

   // シナリオからの指示を処理する関数
   task get_packet();
      forever begin
	 @( posedge c2sif.req ); // シナリオ側からの呼び出し待ち
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    case( c2sif.fn )
	      0: begin // write
		 gp_awaddr = c2sif.addr;
		 gp_wdata = c2sif.data[0];
		 `debug_printf(("get_packet c2sif.data: 0x%08x 0x%08x",c2sif.addr,c2sif.data[0]));
		 // Write動作の起動と完了待ち
		 gp_write_flag = 1'b1;
		 @( gp_write_end_event.triggered );
		 c2sif.ret = 0;
		 // C2SIFとのハンドシェイク
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: 0
	      1: begin // read
		 gp_araddr = c2sif.addr;
		 // Read動作の起動と完了待ち
		 gp_read_flag = 1'b1;
		 @( gp_read_end_event.triggered );
		 c2sif.ret = 0;
		 c2sif.data[0] = gp_rdata; // データ取り込み
		 // C2SIFとのハンドシェイク
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end
	    endcase
	 end // if ( c2sif.id == id )
      end
   endtask // get_packet
   
   // DPI-Cインタフェースのタスク起動（このドライバではタスクが１つ）
   initial begin
      gp_write_flag = 1'b0;
      gp_read_flag = 1'b0;
      
      fork
	 get_packet();
      join;
   end

   // Write動作の起動処理
   always @( posedge gp_write_flag ) begin
      // リセット期間中は動作を待たせる
      if( aresetn == 1'b0 ) begin
	 @( posedge aresetn );
	 #(reset_negative_after_delay);
      end
      `debug_printf(("call axi4_lite_master_write."));
      axi4_lite_master_write(gp_awaddr,gp_wdata);
      -> gp_write_end_event;
   end

   // Read動作の起動処理
   always @( posedge gp_read_flag ) begin
      // リセット期間中は動作を待たせる
      if( aresetn == 1'b0 ) begin
	 @( posedge aresetn );
	 #(reset_negative_after_delay);
      end
      `debug_printf(("call axi4_lite_master_read."));
      axi4_lite_master_read(gp_araddr,gp_rdata);
      -> gp_read_end_event;
   end

   task axi4_lite_master_write(
			       input logic [31:0] awaddr,
			       input logic [31:0] wdata
			       );
      begin
	 fork
	    axi4_lite_master_write_wac(awaddr);
	    axi4_lite_master_write_wdc(wdata);
	 join
	 axi4_lite_master_write_wrc();
      end
   endtask // axi4_lite_master_write

   task axi4_lite_master_write_wac(
			    input logic [31:0] awaddr
			    );
      @( posedge aclk );
      #(awvalid_positive_delay);
      m_awaddr = awaddr;
      m_awvalid = 1'b1;
      `debug_printf(("awvalid = 1"));
      @( posedge aclk );
      while( ~m_awready ) @( posedge aclk );
      #(awvalid_negative_delay);
      m_awvalid = 1'b0;
      `debug_printf(("awvalid = 0"));
   endtask // axi4_lite_master_write_wac

   task axi4_lite_master_write_wdc(
				   input logic [31:0] wdata
				   );
      @( posedge aclk );
      #(wvalid_positive_delay);
      m_wdata = wdata;
      m_wvalid = 1'b1;
      `debug_printf(("wvalid = 1"));
      while( ~m_wready ) @( posedge aclk );
      #(wvalid_negative_delay);
      m_wvalid = 1'b0;
      `debug_printf(("wvalid = 0"));
   endtask // axi4_lite_master_write_wdc

   task axi4_lite_master_write_wrc();
      while( ~m_bvalid ) @( posedge aclk );
      #(bready_positive_delay);
      m_bready = 1'b1;
      `debug_printf(("bready = 1"));
      @( posedge aclk );
      #(bready_negative_delay);
      m_bready = 1'b0;
      `debug_printf(("bready = 0"));
   endtask // axi4_lite_master_write_wrc
   
   task axi4_lite_master_read(
			      input logic [31:0]  araddr,
			      output logic [31:0] rdata
			      );
      axi4_lite_master_read_rac(araddr);
      axi4_lite_master_read_rdc(rdata);
   endtask // axi4_lite_master_read

   task axi4_lite_master_read_rac(
				  input logic [31:0] araddr
				  );
      @( posedge aclk );
      #(arvalid_positive_delay);
      m_araddr = araddr;
      m_arvalid = 1'b1;
      `debug_printf(("arvalid = 1"));
      @( posedge aclk );
      while( ~m_arready ) @( posedge aclk );
      #(arvalid_negative_delay);
      m_arvalid = 1'b0;
      `debug_printf(("arvalid = 0"));
   endtask // axi4_lite_master_read_rac

   task axi4_lite_master_read_rdc(
				  output logic [31:0] rdata
				  );
      while( ~m_rvalid ) @( posedge aclk );
      #(rready_positive_delay);
      m_rready = 1'b1;
      `debug_printf(("rready = 1"));
      rdata = m_rdata;
      @( posedge aclk );
      #(rready_negative_delay);
      m_rready = 1'b0;
      `debug_printf(("rready = 0"));
   endtask // axi4_lite_master_read_rdc
   
endmodule // axi4_lite_master_bfm

   
    

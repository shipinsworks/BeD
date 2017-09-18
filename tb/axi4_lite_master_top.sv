`include "macro.svh"
`include "axi4_lite_master_bfm.sv"
`include "c2sif.svh"

module axi4_lite_master_top;

   logic clk;
   logic rst;

   // System Signals
   wire  ACLK;
   wire  ARESETN;

   // Slave Interface Write Address Ports
   wire [0:0] S_AXI_AWID;
   wire [31:0] S_AXI_AWADDR;
   wire [8-1:0] S_AXI_AWLEN;
   wire [3-1:0] S_AXI_AWSIZE;
   wire [2-1:0] S_AXI_AWBURST;
   wire [2-1:0] S_AXI_AWLOCK;
   wire [4-1:0] S_AXI_AWCACHE;
   wire [3-1:0] S_AXI_AWPROT;
   wire [4-1:0] S_AXI_AWREGION;
   wire [4-1:0] S_AXI_AWQOS;
   wire [0:0] 	S_AXI_AWUSER;
   wire 	S_AXI_AWVALID;
   wire 	S_AXI_AWREADY;

   // Slave Interface Write Data Ports
   wire [0:0] 	S_AXI_WID;
   wire [31:0] 	S_AXI_WDATA;
   wire [3:0] 	S_AXI_WSTRB;
   wire 	S_AXI_WLAST;
   wire [0:0] 	S_AXI_WUSER;
   wire 	S_AXI_WVALID;
   wire 	S_AXI_WREADY;

   // Slave Interface Write Response Ports
   // wire [0:0] 	S_AXI_BID;
   wire [2-1:0] S_AXI_BRESP;
   // wire [0:0] 	S_AXI_BUSER;
   wire 	S_AXI_BVALID;
   wire 	S_AXI_BREADY;

   // Slave Interface Read Address Ports
   wire [0:0] 	S_AXI_ARID;
   wire [31:0] 	S_AXI_ARADDR;
   wire [8-1:0] S_AXI_ARLEN;
   wire [3-1:0] S_AXI_ARSIZE;
   wire [2-1:0] S_AXI_ARBURST;
   wire [2-1:0] S_AXI_ARLOCK;
   wire [4-1:0] S_AXI_ARCACHE;
   wire [3-1:0] S_AXI_ARPROT;
   wire [4-1:0] S_AXI_ARREGION;
   wire [4-1:0] S_AXI_ARQOS;
   wire [0:0] 	S_AXI_ARUSER;
   wire 	S_AXI_ARVALID;
   wire 	S_AXI_ARREADY;

   // Slave Interface Read Data Ports
   wire [0:0] 	S_AXI_RID;
   wire [31:0] 	S_AXI_RDATA;
   wire [2-1:0] S_AXI_RRESP;
   wire 	S_AXI_RLAST;
   wire [0:0] 	S_AXI_RUSER;
   wire 	S_AXI_RVALID;
   wire 	S_AXI_RREADY;
   
   initial begin
      clk = 1'b0;
      forever begin
	 #10 clk = ~clk;
      end
   end

   initial begin
      rst = 1'b1;
      #25 rst = 1'b0;
   end

   assign ACLK = clk;
   assign ARESETN = ~rst;
   
   // シナリオ側からのデータ投入インタフェース
   c2sif c2sif();

   initial begin
      $display("Scenario Call.");
      scenario();
      #100 $finish;
   end

   logic aclk;
   logic aresetn;
   
   assign aclk = clk;
   assign aresetn = ~rst;
   
   // Write Address Chanel Ports
   logic [31:0] awaddr;
   logic [3:0] 	awcache;
   logic [2:0] 	awprot;
   logic 	awvalid;
   logic 	awready;
   // Write Data Chanel Ports
   logic [31:0] wdata;
   logic [3:0] 	wstrb;
   logic 	wvalid;
   logic 	wready;
   // Write Respons Chanel Ports
   logic [1:0] 	bresp;
   logic 	bready;
   logic 	bvalid;
   // Read Address Chanel Ports
   logic [31:0] araddr;
   logic [3:0] 	arcache;
   logic [2:0] 	arprot;
   logic 	arvalid;
   logic 	arready;
   // Read Data Chanel Ports
   logic [31:0] rdata;
   logic [1:0] 	rresp;
   logic 	rready;
   logic 	rvalid;

   axi4_lite_master_bfm
     #(
       .id(1),
       .reset_negative_after_delay(30)
       )
     U1(
	.c2sif(c2sif),
	
	.aclk(aclk),
	.aresetn(aresetn),
	
	.m_awaddr(awaddr),
	.m_awcache(awcache),
	.m_awprot(awprot),
	.m_awvalid(awvalid),
	.m_awready(awready),

	.m_wdata(wdata),
	.m_wstrb(wstrb),
	.m_wvalid(wvalid),
	.m_wready(wready),

	.m_bresp(bresp),
	.m_bvalid(bvalid),
	.m_bready(bready),

	.m_araddr(araddr),
	.m_arcache(arcache),
	.m_arprot(arprot),
	.m_arvalid(arvalid),
	.m_arready(arready),

	.m_rdata(rdata),
	.m_rresp(rresp),
	.m_rready(rready),
	.m_rvalid(rvalid)
	);

   // 検証対象論理
   mem_sim_axi_slave
     DUT(
	 .ACLK(aclk),
	 .ARESETN(aresetn),
	 
	 .S_AXI_AWID(1'b0),
	 .S_AXI_AWADDR(awaddr),
	 .S_AXI_AWLEN(8'h00),
	 .S_AXI_AWSIZE(3'd2),
	 .S_AXI_AWBURST(2'b01),
	 .S_AXI_AWLOCK(2'b00),
	 .S_AXI_AWCACHE(awcache),
	 .S_AXI_AWPROT(awprot),
	 .S_AXI_AWREGION(4'h0),
	 .S_AXI_AWQOS(4'h0),
	 .S_AXI_AWUSER(1'b0),
	 .S_AXI_AWVALID(awvalid),
	 .S_AXI_AWREADY(awready),
	 
	 .S_AXI_WID(1'b0),
	 .S_AXI_WDATA(wdata),
	 .S_AXI_WSTRB(wstrb),
	 .S_AXI_WLAST(1'b1),
	 .S_AXI_WUSER(1'b0),
	 .S_AXI_WVALID(wvalid),
	 .S_AXI_WREADY(wready),

	 .S_AXI_BID(open),
	 .S_AXI_BRESP(bresp),
	 .S_AXI_BUSER(open),
	 .S_AXI_BVALID(bvalid),
	 .S_AXI_BREADY(bready),
	 
	 .S_AXI_ARID(1'b0),
	 .S_AXI_ARADDR(araddr),
	 .S_AXI_ARLEN(8'h00),
	 .S_AXI_ARSIZE(3'd2),
	 .S_AXI_ARBURST(2'b00),
	 .S_AXI_ARLOCK(2'b00),
	 .S_AXI_ARCACHE(arcache),
	 .S_AXI_ARPROT(arprot),
	 .S_AXI_ARREGION(4'h0),
	 .S_AXI_ARQOS(4'h0),
	 .S_AXI_ARUSER(1'b0),
	 .S_AXI_ARVALID(arvalid),
	 .S_AXI_ARREADY(arready),

	 .S_AXI_RID(open),
	 .S_AXI_RDATA(rdata),
	 .S_AXI_RRESP(rresp),
	 .S_AXI_RLAST(open),
	 .S_AXI_RUSER(open),
	 .S_AXI_RVALID(rvalid),
	 .S_AXI_RREADY(rready));
   
   // DPI-C用各種定義
`include "scenario_task.svh"
`include "dpi-c.svh"
	 
endmodule // axi_top

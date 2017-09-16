`include "macro.svh"
`include "AXI4_Master_BFM.sv"
`include "c2sif.svh"

module axi_top;

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
   wire [0:0] 	S_AXI_BID;
   wire [2-1:0] S_AXI_BRESP;
   wire [0:0] 	S_AXI_BUSER;
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

   AXI4_Master_BFM
     #( .id(1) )
     U1(
	.c2sif(c2sif),
	.clk(clk),
	.rst(rst),
	
	.ACLK(ACLK),

	.S_AXI_AWID(S_AXI_AWID),
	.S_AXI_AWADDR(S_AXI_AWADDR),
	.S_AXI_AWLEN(S_AXI_AWLEN),
	.S_AXI_AWSIZE(S_AXI_AWSIZE),
	.S_AXI_AWBURST(S_AXI_AWBURST),
	.S_AXI_AWLOCK(S_AXI_AWLOCK),
	.S_AXI_AWCACHE(S_AXI_AWCACHE),
	.S_AXI_AWPROT(S_AXI_AWPROT),
	.S_AXI_AWREGION(S_AXI_AWREGION),
	.S_AXI_AWQOS(S_AXI_AWQOS),
	.S_AXI_AWUSER(S_AXI_AWUSER),
	.S_AXI_AWVALID(S_AXI_AWVALID),
	.S_AXI_WID(S_AXI_WID),
	.S_AXI_WDATA(S_AXI_WDATA),
	.S_AXI_WSTRB(S_AXI_WSTRB),
	.S_AXI_WLAST(S_AXI_WLAST),
	.S_AXI_WUSER(S_AXI_WUSER),
	.S_AXI_WVALID(S_AXI_WVALID),
	.S_AXI_BREADY(S_AXI_BREADY),
	.S_AXI_ARID(S_AXI_ARID),
	.S_AXI_ARADDR(S_AXI_ARADDR),
	.S_AXI_ARLEN(S_AXI_ARLEN),
	.S_AXI_ARSIZE(S_AXI_ARSIZE),
	.S_AXI_ARBURST(S_AXI_ARBURST),
	.S_AXI_ARLOCK(S_AXI_ARLOCK),
	.S_AXI_ARCACHE(S_AXI_ARCACHE),
	.S_AXI_ARPROT(S_AXI_ARPROT),
	.S_AXI_ARREGION(S_AXI_ARREGION),
	.S_AXI_ARQOS(S_AXI_ARQOS),
	.S_AXI_ARUSER(S_AXI_ARUSER),
	.S_AXI_ARVALID(S_AXI_ARVALID),
	.S_AXI_RREADY(S_AXI_RREADY),

	.S_AXI_AWREADY(S_AXI_AWREADY),
	.S_AXI_WREADY(S_AXI_WREADY),
	.S_AXI_BID(S_AXI_BID),
	.S_AXI_BRESP(S_AXI_BRESP),
	.S_AXI_BUSER(S_AXI_BUSER),
	.S_AXI_BVALID(S_AXI_BVALID),
	.S_AXI_ARREADY(S_AXI_ARREADY),
	.S_AXI_RID(S_AXI_RID),
	.S_AXI_RDATA(S_AXI_RDATA),
	.S_AXI_RRESP(S_AXI_RRESP),
	.S_AXI_RLAST(S_AXI_RLAST),
	.S_AXI_RUSER(S_AXI_RUSER),
	.S_AXI_RVALID(S_AXI_RVALID)
	);
   

   // 検証対象論理
   mem_sim_axi_slave
     DUT(
	 .ACLK(ACLK),
	 .ARESETN(ARESETN),
	 
	 .S_AXI_AWID(S_AXI_AWID),
	 .S_AXI_AWADDR(S_AXI_AWADDR),
	 .S_AXI_AWLEN(S_AXI_AWLEN),
	 .S_AXI_AWSIZE(S_AXI_AWSIZE),
	 .S_AXI_AWBURST(S_AXI_AWBURST),
	 .S_AXI_AWLOCK(S_AXI_AWLOCK),
	 .S_AXI_AWCACHE(S_AXI_AWCACHE),
	 .S_AXI_AWPROT(S_AXI_AWPROT),
	 .S_AXI_AWREGION(S_AXI_AWREGION),
	 .S_AXI_AWQOS(S_AXI_AWQOS),
	 .S_AXI_AWUSER(S_AXI_AWUSER),
	 .S_AXI_AWVALID(S_AXI_AWVALID),
	 .S_AXI_AWREADY(S_AXI_AWREADY),
	 
	 .S_AXI_WID(S_AXI_WID),
	 .S_AXI_WDATA(S_AXI_WDATA),
	 .S_AXI_WSTRB(S_AXI_WSTRB),
	 .S_AXI_WLAST(S_AXI_WLAST),
	 .S_AXI_WUSER(S_AXI_WUSER),
	 .S_AXI_WVALID(S_AXI_WVALID),
	 .S_AXI_WREADY(S_AXI_WREADY),

	 .S_AXI_BID(S_AXI_BID),
	 .S_AXI_BRESP(S_AXI_BRESP),
	 .S_AXI_BUSER(S_AXI_BUSER),
	 .S_AXI_BVALID(S_AXI_BVALID),
	 .S_AXI_BREADY(S_AXI_BREADY),
	 
	 .S_AXI_ARID(S_AXI_ARID),
	 .S_AXI_ARADDR(S_AXI_ARADDR),
	 .S_AXI_ARLEN(S_AXI_ARLEN),
	 .S_AXI_ARSIZE(S_AXI_ARSIZE),
	 .S_AXI_ARBURST(S_AXI_ARBURST),
	 .S_AXI_ARLOCK(S_AXI_ARLOCK),
	 .S_AXI_ARCACHE(S_AXI_ARCACHE),
	 .S_AXI_ARPROT(S_AXI_ARPROT),
	 .S_AXI_ARREGION(S_AXI_ARREGION),
	 .S_AXI_ARQOS(S_AXI_ARQOS),
	 .S_AXI_ARUSER(S_AXI_ARUSER),
	 .S_AXI_ARVALID(S_AXI_ARVALID),
	 .S_AXI_ARREADY(S_AXI_ARREADY),

	 .S_AXI_RID(S_AXI_RID),
	 .S_AXI_RDATA(S_AXI_RDATA),
	 .S_AXI_RRESP(S_AXI_RRESP),
	 .S_AXI_RLAST(S_AXI_RLAST),
	 .S_AXI_RUSER(S_AXI_RUSER),
	 .S_AXI_RVALID(S_AXI_RVALID),
	 .S_AXI_RREADY(S_AXI_RREADY));
   
   // DPI-C用各種定義
`include "scenario_task.svh"
`include "dpi-c.svh"
	 
endmodule // axi_top

`include "macro.svh"
`include "axi4_lite_master_bfm.sv"
`include "c2sif.svh"
`include "axi4_lite_slave_bfm.sv"
`include "s2cif.svh"

module axi4_lite_both_top;

   logic clk;
   logic rst;
   
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

   // シナリオ側からのデータ投入インタフェース
   c2sif c2sif();
   s2cif s2cif();
   
   initial begin
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
       .id(1)
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

   axi4_lite_slave_bfm
     #(
       .id(2)
       )
   U2(
      .s2cif(s2cif),
      .c2sif(c2sif),
      
      .aclk(aclk),
      .aresetn(aresetn),

      .s_awaddr(awaddr),
      .s_awcache(awcache),
      .s_awprot(awprot),
      .s_awvalid(awvalid),
      .s_awready(awready),
      
      .s_wdata(wdata),
      .s_wstrb(wstrb),
      .s_wvalid(wvalid),
      .s_wready(wready),
      
      .s_bresp(bresp),
      .s_bvalid(bvalid),
      .s_bready(bready),
      
      .s_araddr(araddr),
      .s_arcache(arcache),
      .s_arprot(arprot),
      .s_arvalid(arvalid),
      .s_arready(arready),
      
      .s_rdata(rdata),
      .s_rresp(rresp),
      .s_rready(rready),
      .s_rvalid(rvalid)
      );
   
   // DPI-C用各種定義
`include "scenario_task.svh"
`include "dpi-c.svh"
	 
endmodule // axi4_lite_both_top

//-----------------------------------------------------------------------------
//-- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// AXI Slave
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   mem_sim_axi_slave
//
//--------------------------------------------------------------------------
//
// アクセスのデータ幅は、定義されたデータ幅だけに対応する
`default_nettype none

  module mem_sim_axi_slave # (
			      parameter integer C_S_AXI_ID_WIDTH = 1,
			      parameter integer C_S_AXI_ADDR_WIDTH = 32,
			      parameter integer C_S_AXI_DATA_WIDTH = 32,
			      parameter integer C_S_AXI_AWUSER_WIDTH = 1,
			      parameter integer C_S_AXI_ARUSER_WIDTH = 1,
		              parameter integer C_S_AXI_WUSER_WIDTH = 1,
			      parameter integer C_S_AXI_RUSER_WIDTH = 1,
			      parameter integer C_S_AXI_BUSER_WIDTH = 1,

			      parameter integer C_MEMORY_SIZE = 512    // Word (not byte)
			      ) (
				 // System Signals
				 input wire 			       ACLK,
				 input wire 			       ARESETN,

				 // Slave Interface Write Address Ports
				 input wire [C_S_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
				 input wire [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
				 input wire [8-1:0] 		       S_AXI_AWLEN,
				 input wire [3-1:0] 		       S_AXI_AWSIZE,
				 input wire [2-1:0] 		       S_AXI_AWBURST,
				 input wire [2-1:0] 		       S_AXI_AWLOCK,
				 input wire [4-1:0] 		       S_AXI_AWCACHE,
				 input wire [3-1:0] 		       S_AXI_AWPROT,
				 input wire [4-1:0] 		       S_AXI_AWREGION,
				 input wire [4-1:0] 		       S_AXI_AWQOS,
				 input wire [C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER,
				 input wire 			       S_AXI_AWVALID,
				 output wire 			       S_AXI_AWREADY,

				 // Slave Interface Write Data Ports
				 input wire [C_S_AXI_ID_WIDTH-1:0]     S_AXI_WID,
				 input wire [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
				 input wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
				 input wire 			       S_AXI_WLAST,
				 input wire [C_S_AXI_WUSER_WIDTH-1:0]  S_AXI_WUSER,
				 input wire 			       S_AXI_WVALID,
				 output wire 			       S_AXI_WREADY,

				 // Slave Interface Write Response Ports
				 output wire [C_S_AXI_ID_WIDTH-1:0]    S_AXI_BID,
				 output wire [2-1:0] 		       S_AXI_BRESP,
				 output wire [C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER,
				 output wire 			       S_AXI_BVALID,
				 input wire 			       S_AXI_BREADY,

				 // Slave Interface Read Address Ports
				 input wire [C_S_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
				 input wire [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
				 input wire [8-1:0] 		       S_AXI_ARLEN,
				 input wire [3-1:0] 		       S_AXI_ARSIZE,
				 input wire [2-1:0] 		       S_AXI_ARBURST,
				 input wire [2-1:0] 		       S_AXI_ARLOCK,
				 input wire [4-1:0] 		       S_AXI_ARCACHE,
				 input wire [3-1:0] 		       S_AXI_ARPROT,
				 input wire [4-1:0] 		       S_AXI_ARREGION,
				 input wire [4-1:0] 		       S_AXI_ARQOS,
				 input wire [C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER,
				 input wire 			       S_AXI_ARVALID,
				 output wire 			       S_AXI_ARREADY,

				 // Slave Interface Read Data Ports
				 output wire [C_S_AXI_ID_WIDTH-1:0]    S_AXI_RID,
				 output wire [C_S_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
				 output wire [2-1:0] 		       S_AXI_RRESP,
				 output wire 			       S_AXI_RLAST,
				 output wire [C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
				 output wire 			       S_AXI_RVALID,
				 input wire 			       S_AXI_RREADY

				 );

   // Value of S_AXI_BRESP
   localparam    RESP_OKAY =        2'b00,
     RESP_EXOKAY =    2'b01,
     RESP_SLVERR =    2'b10,
     RESP_DECERR =    2'b11;

   // Value of S_AXI_ARBURST
   localparam    AxBURST_FIXED =    2'b00,
     AxBURST_INCR =    2'b01,
     AxBURST_WRAP =    2'b10;

   localparam    IDLE_WADDR =         1'b0,
     AWREADY_HOLD_OFF =    1'b1;
   reg 								       waddr_sm_cs;
   reg 								       awready;
   reg 								       awid;
   reg [C_S_AXI_ADDR_WIDTH-1:0] 				       waddr;
   reg [C_S_AXI_ID_WIDTH-1:0] 					       wid;
   reg [2-1:0] 							       awburst;

   localparam    IDLE_WDATA =    1'b0,
     WREADY_ASSERT =    1'b1;
   reg 								       wdata_sm_cs;
   reg 								       wready;

   localparam    IDLE_WRES =        1'b0,
     BVALID_ASSERT =    1'b1;
   reg 								       wres_sm_cs;
   reg [2-1:0] 							       bresp;
   reg 								       bvalid;

   localparam    IDLE_RADDR =        1'b0,
     ARREADY_HOLD_OFF =    1'b1;
   reg 								       raddr_sm_cs;
   reg 								       arready;
   reg [C_S_AXI_ID_WIDTH-1:0] 					       arid;
   reg [C_S_AXI_ADDR_WIDTH-1:0] 				       raddr;

   localparam    IDLE_RDATA =    1'b0,
     RVALID_ASSERT =    1'b1;
   reg 								       rdata_sm_cs;
   reg 								       rvalid;
   reg [C_S_AXI_ID_WIDTH-1:0] 					       rid;
   reg [1:0] 							       rresp;
   reg [8:0] 							       rdata_count;

   localparam    IDLE_RLAST =     1'b0,
     RLAST_ASSERT =    1'b1;
   reg 								       rlast_sm_cs;
   reg 								       rlast;

   // instance memory_8bit
   generate
      genvar 							       i;

      for (i=(C_S_AXI_DATA_WIDTH/8-1); i>=0; i=i-1) begin : MEMORY_GEN
	 memory_8bit #(
		       .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
		       .C_MEMORY_SIZE(C_MEMORY_SIZE)
		       ) memory_8bit_i (
					.clk(ACLK),
					.waddr(waddr),
					.write_data(S_AXI_WDATA[i*8+7:i*8]),
					.write_enable(wready & S_AXI_WVALID),
					.byte_enable(S_AXI_WSTRB[i]),
					.raddr(raddr),
					.read_data(S_AXI_RDATA[i*8+7:i*8])
					);
      end
   endgenerate

   // Write Transaction
   assign S_AXI_BUSER = 1'd0;

   // waddr State Machine
   // awready is normally 1. if S_AXI_AWVALID is 1 then awready is 0.
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 waddr_sm_cs <= IDLE_WADDR;
	 awready <= 1'b1;
	 awid <= {C_S_AXI_ID_WIDTH{1'b0}};
	 awburst <= 2'd0;
      end else begin
	 case (waddr_sm_cs)
	   IDLE_WADDR :
	     if (S_AXI_AWVALID) begin
		waddr_sm_cs <= AWREADY_HOLD_OFF;
		awready <= 1'b0;
		awid <= S_AXI_AWID;
		awburst <= S_AXI_AWBURST;
	     end
	   AWREADY_HOLD_OFF :
	     if (bvalid) begin
		waddr_sm_cs <= IDLE_WADDR;
		awready <= 1'b1;
	     end
	 endcase
      end
   end
   assign S_AXI_AWREADY = awready;

   // waddr
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 waddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
   end else begin
      if (waddr_sm_cs == IDLE_WADDR & S_AXI_AWVALID)
	waddr <= S_AXI_AWADDR;
      else if (wready & S_AXI_WVALID)
	waddr <= waddr + C_S_AXI_DATA_WIDTH/8;
   end
   end

   // wdata State Machine
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 wdata_sm_cs <= IDLE_WDATA;
	 wready <= 1'b0;
      end else begin
	 case (wdata_sm_cs)
	   IDLE_WDATA :
	     if (waddr_sm_cs == IDLE_WADDR && S_AXI_AWVALID) begin // Write transaction start
		wdata_sm_cs <= WREADY_ASSERT;
		wready <= 1'b1;
	     end
	   WREADY_ASSERT :
	     if (S_AXI_WLAST & S_AXI_WVALID) begin    // Write transaction end
		wdata_sm_cs <= IDLE_WDATA;
		wready <= 1'b0;
	     end
	 endcase
      end
   end
   assign S_AXI_WREADY = wready;

   assign S_AXI_BID = awid;
   // Write Response State Machine
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 wres_sm_cs <= IDLE_WRES;
	 bvalid <= 1'b0;
      end else begin
	 case (wres_sm_cs)
	   IDLE_WRES :
	     if (wdata_sm_cs == WREADY_ASSERT & S_AXI_WLAST & S_AXI_WVALID) begin    // Write transaction end
		wres_sm_cs <= BVALID_ASSERT;
		bvalid <= 1'b1;
	     end
	   BVALID_ASSERT :
	     if (S_AXI_BREADY) begin
		wres_sm_cs <= IDLE_WRES;
		bvalid <= 1'b0;
	     end
	 endcase
      end
   end
   assign S_AXI_BVALID = bvalid;

   // bresp
   // if S_AXI_AWBURST is INCR then return OKAY else return SLVERR
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0)
	bresp <= 2'b0;
      else begin
	 if (waddr_sm_cs == AWREADY_HOLD_OFF) begin
	    if (awburst == AxBURST_INCR) // The burst type is Addres Increment Type
	      bresp <= RESP_OKAY; // The Write Transaction is success
	    else
	      bresp <= RESP_SLVERR; // Error
	 end
      end
   end
   assign S_AXI_BRESP = bresp;

   // Read Transaction
   assign S_AXI_RUSER = 0;

   // raddr State Machine
   // arready is normally 1. if S_AXI_ARVALID is 1 then arready is 0.
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 raddr_sm_cs <= IDLE_RADDR;
	 arready <= 1'b1;
	 arid <= {C_S_AXI_ID_WIDTH{1'b0}};
      end else begin
	 case (raddr_sm_cs)
	   IDLE_RADDR :
	     if (S_AXI_ARVALID) begin
		raddr_sm_cs <= ARREADY_HOLD_OFF;
		arready <= 1'b0;
		arid <= S_AXI_ARID;
	     end
	   ARREADY_HOLD_OFF :
	     if (rvalid & S_AXI_RREADY & S_AXI_RLAST) begin // Read Transaction End
		raddr_sm_cs <= IDLE_RADDR;
		arready <= 1'b1;
	     end
	 endcase
      end
   end
   assign S_AXI_ARREADY = arready;

   // raddr
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 raddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
   end else begin
      if (raddr_sm_cs == IDLE_RADDR & S_AXI_ARVALID)
	raddr <= S_AXI_ARADDR;
      else if (rvalid & S_AXI_RREADY)
	raddr <= raddr + C_S_AXI_ADDR_WIDTH/8;
   end
   end

   // rdata State Machine
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 rdata_sm_cs <= IDLE_RDATA;
	 rvalid <= 1'b0;
	 rid <= {C_S_AXI_ID_WIDTH{1'b0}};
      end else begin
	 case (rdata_sm_cs)
	   IDLE_RDATA :
	     if (raddr_sm_cs == IDLE_RADDR & S_AXI_ARVALID) begin
		rdata_sm_cs <= RVALID_ASSERT;
		rvalid <= 1'b1;
	     end
	   RVALID_ASSERT :
	     if (rlast & S_AXI_RREADY) begin
		rdata_sm_cs <= IDLE_RDATA;
		rvalid <= 1'b0;
	     end
	 endcase
      end
   end
   assign S_AXI_RVALID = rvalid;
   assign S_AXI_RID = arid;

   //     assign S_AXI_RRESP = RESP_OKAY;
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 rresp <= RESP_OKAY;
      end else if (rdata_sm_cs == RVALID_ASSERT && rid != arid) begin
	 rresp <= RESP_SLVERR;
      end
   end
   assign S_AXI_RRESP = rresp;

   // rdata_count
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 rdata_count <= 9'd0;
      end else begin
	 if (raddr_sm_cs == IDLE_RADDR & S_AXI_ARVALID)
	   rdata_count <= {1'b0, S_AXI_ARLEN} + 9'd1;
	 else if (rvalid & S_AXI_RREADY)
	   rdata_count <= rdata_count - 9'd1;
      end
   end

   // rlast
   always @(posedge ACLK) begin
      if (ARESETN == 1'b0) begin
	 rlast_sm_cs <= IDLE_RLAST;
	 rlast <= 1'b0;
      end else begin
	 case (rlast_sm_cs)
	   IDLE_RLAST :
	     if (rdata_count == 9'd2 && (rvalid & S_AXI_RREADY)) begin
		rlast_sm_cs <= RLAST_ASSERT;
		rlast <= 1'b1;
	     end else if (raddr_sm_cs==IDLE_RADDR && S_AXI_ARVALID==1'b1 && S_AXI_ARLEN==8'd0) begin
		// 転送数が1の時はデータ転送の最初からrlast を1にする
		rlast_sm_cs <= RLAST_ASSERT;
		rlast <= 1'b1;
	     end
	   RLAST_ASSERT :
	     if (rvalid & S_AXI_RREADY) begin
		rlast_sm_cs <= IDLE_RLAST;
		rlast <= 1'b0;
	     end
	 endcase
      end
   end
   assign S_AXI_RLAST = rlast;

endmodule

// AXI4 bus Master Bus Fucntion Mode
// 2012/10/24 : �C���AS_AXI_AWREADY��1�ɂȂ�̂��m�F���Ă���S_AXI_WVALID��1�ɂ��Ă����̂ł́AAXI�o�X�̔�W���ƂȂ�B
// ����āAAXI_MASTER_WAC ��AXI_MASTER_WDC ��fork ~ join �ŕ���Ɏ��s����
// 2013/12/14 : input �� DELAY������悤�ɕύX
//
`include "macro.svh"
`include "c2sif.svh"

`default_nettype none

  //`timescale 100ps / 1ps

  module AXI4_Master_BFM #(
			   parameter id = 0,
			   parameter DELAY	= 10 )
   (
    c2sif c2sif,
    input wire        clk,
    input wire        rst,
    input wire 	      ACLK,

    output reg [0:0]  S_AXI_AWID = 0,
    output reg [31:0] S_AXI_AWADDR = 0,
    output reg [7:0]  S_AXI_AWLEN = 0,
    output reg [2:0]  S_AXI_AWSIZE = 0,
    output reg [1:0]  S_AXI_AWBURST = 0,
    output reg [1:0]  S_AXI_AWLOCK = 0,
    output reg [3:0]  S_AXI_AWCACHE = 3, // Normal Non-cacheable bufferable
    output reg [2:0]  S_AXI_AWPROT = 0,
    output reg [3:0]  S_AXI_AWREGION = 0,
    output reg [3:0]  S_AXI_AWQOS = 0,
    output reg [0:0]  S_AXI_AWUSER = 0,
    output reg 	      S_AXI_AWVALID = 0,
    output reg [0:0]  S_AXI_WID = 0,
    output reg [31:0] S_AXI_WDATA = 0,
    output reg [3:0]  S_AXI_WSTRB = 0,
    output reg 	      S_AXI_WLAST = 0,
    output reg [0:0]  S_AXI_WUSER = 0,
    output reg 	      S_AXI_WVALID = 0,
    output reg 	      S_AXI_BREADY = 0,
    output reg [0:0]  S_AXI_ARID = 0,
    output reg [31:0] S_AXI_ARADDR = 0,
    output reg [7:0]  S_AXI_ARLEN = 0,
    output reg [2:0]  S_AXI_ARSIZE = 0,
    output reg [1:0]  S_AXI_ARBURST = 0,
    output reg [1:0]  S_AXI_ARLOCK = 0,
    output reg [3:0]  S_AXI_ARCACHE = 2, // Normal Non-cacheable bufferable
    output reg [2:0]  S_AXI_ARPROT = 0,
    output reg [3:0]  S_AXI_ARREGION = 0,
    output reg [3:0]  S_AXI_ARQOS = 0,
    output reg [0:0]  S_AXI_ARUSER = 0,
    output reg 	      S_AXI_ARVALID = 0,
    output reg 	      S_AXI_RREADY = 0,

    input wire 	      S_AXI_AWREADY,
    input wire 	      S_AXI_WREADY,
    input wire [0:0]  S_AXI_BID,
    input wire [1:0]  S_AXI_BRESP,
    input wire [0:0]  S_AXI_BUSER,
    input wire 	      S_AXI_BVALID,
    input wire 	      S_AXI_ARREADY,
    input wire [0:0]  S_AXI_RID,
    input wire [31:0] S_AXI_RDATA,
    input wire [1:0]  S_AXI_RRESP,
    input wire 	      S_AXI_RLAST,
    input wire [0:0]  S_AXI_RUSER,
    input wire 	      S_AXI_RVALID
    );
   
   reg [7:0] 	      awlen_hold = 0;
   reg [0:0] 	      wid_hold = 0;
   reg 		      axi_w_transaction_active = 0;
   reg 		      axi_r_transaction_active = 0;
   reg [7:0] 	      arlen_hold = 0;

   reg 		      S_AXI_AWREADY_d;
   reg 		      S_AXI_WREADY_d;
   reg [0:0] 	      S_AXI_BID_d;
   reg [1:0] 	      S_AXI_BRESP_d;
   reg [0:0] 	      S_AXI_BUSER_d;
   reg 		      S_AXI_BVALID_d;
   reg 		      S_AXI_ARREADY_d;
   reg [0:0] 	      S_AXI_RID_d;
   reg [31:0] 	      S_AXI_RDATA_d;
   reg [1:0] 	      S_AXI_RRESP_d;
   reg 		      S_AXI_RLAST_d;
   reg [0:0] 	      S_AXI_RUSER_d;
   reg 		      S_AXI_RVALID_d;

   logic [31:0]       awaddr_r0;
   logic [31:0]       wdata_r0;
   logic 	      write_flag;
   event 	      write_end_event;
   logic [31:0]       araddr_r0;
   logic [31:0]       rdata_r0;
   logic 	      read_flag;
   event 	      read_end_event;
   
   // �V�i���I����̎w������������֐�
   task get_packet();
      forever begin
	 @( posedge c2sif.req ); // �V�i���I������̌Ăяo���҂�
	 `debug_printf(("found req: 1"));
	 
	 if( c2sif.id == id ) begin
	    case( c2sif.fn )
	      0: begin // write
		 awaddr_r0 = c2sif.addr;
		 wdata_r0 = c2sif.data[0];
		 `debug_printf(("get_packet c2sif.data: 0x%08x 0x%08x",c2sif.addr,c2sif.data[0]));
		 // Write����̋N���Ɗ����҂�
		 write_flag = 1'b1;
		 @( write_end_event.triggered );
		 c2sif.ret = 0;
		 // C2SIF�Ƃ̃n���h�V�F�C�N
		 c2sif.ack = 1'b1;
		 `debug_printf(("set ack: 1"));
		 @( negedge c2sif.req );
		 `debug_printf(("found req: 0"));
		 c2sif.ack = 1'b0;
		 `debug_printf(("set ack: 0"));
	      end // case: 0
	      1: begin // read
		 araddr_r0 = c2sif.addr;
		 // Read����̋N���Ɗ����҂�
		 read_flag = 1'b1;
		 @( read_end_event.triggered );
		 c2sif.ret = 0;
		 c2sif.data[0] = rdata_r0; // �f�[�^��荞��
		 // C2SIF�Ƃ̃n���h�V�F�C�N
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

   // DPI-C�C���^�t�F�[�X�̃^�X�N�N���i���̃h���C�o�ł̓^�X�N���P�j
   initial begin
      write_flag = 1'b0;
      read_flag = 1'b0;
      
      fork
	 get_packet();
      join;
   end

   // Write����̋N������
   always @( posedge write_flag ) begin
      // ���Z�b�g���Ԓ��͓����҂�����
      if( rst == 1'b1 ) begin
	 @( negedge rst );
	 #(30);
      end
      `debug_printf(("call AXI_Master_1Seq_Write."));
      AXI_Master_1Seq_Write(0,awaddr_r0,0,4,0,wdata_r0,0,0);
      -> write_end_event;
   end

   // Read����̋N������
   always @( posedge read_flag ) begin
      // ���Z�b�g���Ԓ��͓����҂�����
      if( rst == 1'b1 ) begin
	 @( negedge rst );
	 #(30);
      end
      `debug_printf(("call AXI_Master_1Seq_Read."));
      AXI_Master_1Seq_Read(0,araddr_r0,0,4,0,0);
      -> read_end_event;
   end
   
   always @* S_AXI_AWREADY_d <= #DELAY S_AXI_AWREADY;
   always @* S_AXI_WREADY_d <= #DELAY S_AXI_WREADY;
   always @* S_AXI_BID_d <= #DELAY S_AXI_BID;
   always @* S_AXI_BRESP_d <= #DELAY S_AXI_BRESP;
   always @* S_AXI_BUSER_d <= #DELAY S_AXI_BUSER;
   always @* S_AXI_BVALID_d <= #DELAY S_AXI_BVALID;
   always @* S_AXI_ARREADY_d <= #DELAY S_AXI_ARREADY;
   always @* S_AXI_RID_d <= #DELAY S_AXI_RID;
   always @* S_AXI_RDATA_d <= #DELAY S_AXI_RDATA;
   always @* S_AXI_RRESP_d <= #DELAY S_AXI_RRESP;
   always @* S_AXI_RLAST_d <= #DELAY S_AXI_RLAST;
   always @* S_AXI_RUSER_d <= #DELAY S_AXI_RUSER;
   always @* S_AXI_RVALID_d <= #DELAY S_AXI_RVALID;

   // Write Channel
   // wait_clk_bready : 0 - bready �� Wait �͖����A0�ȊO - bready �� Wait�@�� wait_clk_bready�@�̒l�� Wait ������
   // wmax_wait : 0 - wvalid �� Wait �͖����A0�ȊO - wmax_wait ���ő�l�Ƃ��郉���_���Ȓl�� Wait ���@wvalid �ɓ���
   task AXI_Master_1Seq_Write;	// Write Address; Write Data, Write Response ���V�[�P���V�����ɃI�[�o�[���b�v�����ɍs���B
      input [0:0]	awid;
      input [31:0] 	awaddr;
      input [7:0] 	awlen;
      input [2:0] 	awsize;
      input [1:0] 	awburst;
      input [31:0] 	wdata;
      input [7:0] 	wait_clk_bready;
      input [7:0] 	wmax_wait;
      begin
	 fork
	    `debug_printf(("call AXI_Master_1Seq_Write. awaddr: 0x%08x wdata: 0x%08x",awaddr,wdata));
	    AXI_MASTER_WAC(awid, awaddr, awlen, awsize, awburst);
	    AXI_MASTER_WDC(wdata, wmax_wait);
	 join
	 AXI_MASTER_WRC(wait_clk_bready);
      end
   endtask

   // Write Address Channel
   task AXI_MASTER_WAC;
      input [0:0]	awid;
      input [31:0] 	awaddr;
      input [7:0] 	awlen;
      input [2:0] 	awsize;
      input [1:0] 	awburst;
      begin
	 `debug_printf(("call AXI_MASTER_WAC. awaddr: 0x%08x",awaddr));
	 
	 S_AXI_AWID		= awid;
	 S_AXI_AWADDR	= awaddr;
	 S_AXI_AWLEN		= awlen;
	 S_AXI_AWSIZE	= awsize;
	 S_AXI_AWBURST	= awburst;
	 S_AXI_AWVALID	= 1'b1;

	 if (axi_w_transaction_active == 1'b0) begin // AXI Write �g�����U�N�V�������J�n����Ă���ꍇ�͖߂�
	    axi_w_transaction_active = 1'b1; // AXI�g�����U�N�V�����J�n
	    
	    awlen_hold		= awlen; // Write Data Channel �̂��߂Ƀo�[�X�g��������Ă���
	    @(posedge ACLK);	// ���̃N���b�N��
	    
	    while (~S_AXI_AWREADY_d) begin	// S_AXI_AWREADY ��1�ɂȂ�܂ő҂�
	       #DELAY;
	       @(posedge ACLK);	// ���̃N���b�N��
	    end
	    
	    #DELAY;
	    S_AXI_AWID 		= 0;
	    S_AXI_AWADDR	= 0;
	    S_AXI_AWLEN 	= 0;
	    S_AXI_AWSIZE 	= 0;
	    S_AXI_AWBURST 	= 0;
	    S_AXI_AWVALID 	= 1'b0;
	    @(posedge ACLK);	// ���̃N���b�N��
	    #DELAY;
	 end
      end
   endtask

   // Write Data Channel
   // wmax_wait : 0 - wvalid �� Wait �͖����A0�ȊO - wmax_wait ���ő�l�Ƃ��郉���_���Ȓl�� Wait ���@wvalid �ɓ���
   task AXI_MASTER_WDC;	// WDATA ��+1����
      // �Ƃ肠�����AWSTRB�̓I�[��1�ɂ���
      input [31:0]	wdata;
      input [7:0] 	wmax_wait;	// Write���̍ő�wait��
      integer 		i, j, val;
      begin
	 `debug_printf(("call AXI_MASTER_WDC. wdata: 0x%08x",wdata));
	 
	 i = 0; j = 0;
	 S_AXI_WSTRB = 4'b1111;
	 
	 while (~S_AXI_AWVALID) begin	// S_AXI_AWVALID ��1�ɂȂ�܂ő҂�
	    @(posedge ACLK);	// ���̃N���b�N��
	    #DELAY;
	 end
	 
	 while (i<=awlen_hold) begin
	    if (wmax_wait == 0) // wmax_wait ��0�̎���$random �����s���Ȃ�
	      val = 0;
	    else
	      val = $unsigned($random) % (wmax_wait+1);
	    
	    if (val == 0) begin // wait�Ȃ�
	       S_AXI_WVALID = 1'b1;
	    end else begin // wait����
	       S_AXI_WVALID = 1'b0;
	       for (j=0; j<val; j=j+1) begin
		  @(posedge ACLK);	// ���̃N���b�N��
		  #DELAY;
	       end
	       S_AXI_WVALID = 1'b1; // wait�I��
	    end
	    
	    if (i == awlen_hold)
	      S_AXI_WLAST = 1'b1;
	    else
	      S_AXI_WLAST = 1'b0;
	    S_AXI_WDATA = wdata;
	    wdata = wdata + 1;
	    
	    @(posedge ACLK);	// ���̃N���b�N��
	    
	    while (~S_AXI_WREADY_d) begin	// S_AXI_WREADY ��0�̎���1�ɂȂ�܂ő҂�
	       #DELAY;
	       @(posedge ACLK);	// ���̃N���b�N��
	    end
	    #DELAY;
	    
	    i = i + 1;
	 end
	 S_AXI_WVALID = 1'b0;
	 S_AXI_WLAST = 1'b0;
	 S_AXI_WSTRB = 4'b0000;
      end
   endtask

   // Write Response Channel
   // wait_clk_bready : 0 - bready �� Wait �͖����A0�ȊO - bready �� Wait�@�� wait_clk_bready�@�̒l�� Wait ������
   task AXI_MASTER_WRC;	// wait_clk_bready
      input   [7:0]	wait_clk_bready;
      integer 		i;
      begin
	 `debug_printf(("call AXI_MASTER_WRC."));
	 
	 for (i=0; i<wait_clk_bready; i=i+1) begin
	    @(posedge ACLK);	// ���̃N���b�N��
	    #DELAY;
	 end
	 
	 S_AXI_BREADY = 1'b1;
	 
	 
	 @(posedge ACLK);	// ���̃N���b�N��
	 
	 while (~S_AXI_BVALID_d) begin // S_AXI_BVALID ��1�ɂȂ�܂�Wait
	    #DELAY;
	    @(posedge ACLK);	// ���̃N���b�N��
	 end
	 #DELAY;
	 
	 S_AXI_BREADY = 1'b0;
	 
	 axi_w_transaction_active = 1'b0; // AXI�g�����U�N�V�����I��
	 @(posedge ACLK);
	 #DELAY;
      end
   endtask

   // Read Channel
   task AXI_Master_1Seq_Read; // Read Address, Read Data ���V�[�P���V�����ɍs���B
      input [0:0]	arid;
      input [31:0] 	araddr;
      input [7:0] 	arlen;
      input [2:0] 	arsize;
      input [1:0] 	arburst;
      input [7:0] 	rmax_wait;	// Read���̍ő�wait��
      begin
	 AXI_MASTER_RAC(arid, araddr, arlen, arsize, arburst);
	 AXI_MASTER_RDC(rmax_wait);
      end
   endtask
   
   // Read Address Channel
   task AXI_MASTER_RAC;
      input	[0:0]	arid;
      input [31:0] 	araddr;
      input [7:0] 	arlen;
      input [2:0] 	arsize;
      input [1:0] 	arburst;
      begin
	 `debug_printf(("call AXI_MASTER_RAC. araddr: 0x%08x",araddr));

	 S_AXI_ARID 		= arid;
	 S_AXI_ARADDR	= araddr;
	 S_AXI_ARLEN		= arlen;
	 S_AXI_ARSIZE	= arsize;
	 S_AXI_ARBURST	= arburst;
	 S_AXI_ARVALID 	= 1'b1;

	 if (axi_r_transaction_active == 1'b0) begin // AXI Read �g�����U�N�V�������J�n����Ă���ꍇ�͖߂�
	    arlen_hold	=arlen; // Read Data Channel �̂��߂Ƀo�[�X�g��������Ă���
	    @(posedge ACLK);	// ���̃N���b�N��

	    while (~S_AXI_ARREADY_d) begin	// S_AXI_ARREADY ��1�ɂȂ�܂ő҂�
	       #DELAY;
	       @(posedge ACLK);	// ���̃N���b�N��
	    end

	    #DELAY;
	    S_AXI_ARID 		= 0;
	    S_AXI_ARADDR	= 0;
	    S_AXI_ARLEN 	= 0;
	    S_AXI_ARSIZE 	= 0;
	    S_AXI_ARBURST 	= 0;
	    S_AXI_ARVALID 	= 1'b0;
	    @(posedge ACLK);	// ���̃N���b�N��
	    #DELAY;
	    axi_r_transaction_active = 1'b1; // AXI�g�����U�N�V�����J�n
	 end
      end
   endtask

   // Read Data Channel
   task AXI_MASTER_RDC; // S_AXI_RLAST ���A�T�[�g�����܂�S_AXI_RREADY ���A�T�[�g����
      input	[7:0]	rmax_wait;	// Read���̍ő�wait��
      integer 		i, val;
      begin
	 `debug_printf(("call AXI_MASTER_RDC."));

	 while (~(S_AXI_RLAST_d & S_AXI_RVALID_d & S_AXI_RREADY)) begin // S_AXI_RLAST & S_AXI_RVALID & S_AXI_RREADY �ŏI��
	    if (rmax_wait == 0) begin // rmax_wait ��0�̎���$random �����s���Ȃ�
	       val = 0;
	       S_AXI_RREADY = 1'b1;
	    end else begin
	       val = $unsigned($random) % (rmax_wait+1);
	       if (val == 0)
		 S_AXI_RREADY = 1'b1;
	       else
		 S_AXI_RREADY = 1'b0;
	    end
	    #DELAY;

	    for (i=0; i<val; i=i+1) begin // �����_���l��Wait�Aval=0�̎��̓X�L�b�v
	       @(posedge ACLK);	// ���̃N���b�N��
	       #DELAY;
	    end

	    // �����Ńf�[�^��荞��
	    rdata_r0 = S_AXI_RDATA;
	    `debug_printf(("RDATA: 0x%08x",rdata_r0));
	    
	    S_AXI_RREADY = 1'b1;
	    @(posedge ACLK);	// ���̃N���b�N��
	    while (~S_AXI_RVALID_d) begin // S_AXI_RVALID ��1�ɂȂ�܂�Wait
	       #DELAY;
	       @(posedge ACLK);	// ���̃N���b�N��
	    end
	    #DELAY;
	 end
	 #DELAY;

	 S_AXI_RREADY = 1'b0;
	 axi_r_transaction_active = 1'b0; // AXI�g�����U�N�V�����I��
	 @(posedge ACLK);
	 #DELAY;
      end
   endtask

endmodule

`default_nettype wire

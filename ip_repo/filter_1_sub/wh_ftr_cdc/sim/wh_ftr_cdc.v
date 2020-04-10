//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Sat Mar  7 23:00:15 2020
//Host        : Helen running 64-bit major release  (build 9200)
//Command     : generate_target wh_ftr_cdc.bd
//Design      : wh_ftr_cdc
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "wh_ftr_cdc,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=wh_ftr_cdc,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_clkrst_cnt=2,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "wh_ftr_cdc.hwdef" *) 
module wh_ftr_cdc
   (ctrl_aclk,
    rd_data,
    rd_empty,
    rd_en,
    reset,
    video_aclk,
    wr_data,
    wr_en,
    wr_full);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CTRL_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CTRL_ACLK, CLK_DOMAIN wh_ftr_cdc_clk_100MHz, FREQ_HZ 100000000, PHASE 0.000" *) input ctrl_aclk;
  output [3:0]rd_data;
  output rd_empty;
  input rd_en;
  input reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.VIDEO_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.VIDEO_ACLK, CLK_DOMAIN wh_ftr_cdc_clk_100MHz_1, FREQ_HZ 100000000, PHASE 0.000" *) input video_aclk;
  input [3:0]wr_data;
  input wr_en;
  output wr_full;

  wire clk_100MHz_1;
  wire clk_100MHz_1_1;
  wire [3:0]din_0_1;
  wire [3:0]fifo_generator_0_dout;
  wire fifo_generator_0_empty;
  wire fifo_generator_0_full;
  wire rd_en_0_1;
  wire rst_0_1;
  wire wr_en_0_1;

  assign clk_100MHz_1 = ctrl_aclk;
  assign clk_100MHz_1_1 = video_aclk;
  assign din_0_1 = wr_data[3:0];
  assign rd_data[3:0] = fifo_generator_0_dout;
  assign rd_empty = fifo_generator_0_empty;
  assign rd_en_0_1 = rd_en;
  assign rst_0_1 = reset;
  assign wr_en_0_1 = wr_en;
  assign wr_full = fifo_generator_0_full;
  wh_ftr_cdc_fifo_generator_0_0 fifo_generator_0
       (.din(din_0_1),
        .dout(fifo_generator_0_dout),
        .empty(fifo_generator_0_empty),
        .full(fifo_generator_0_full),
        .rd_clk(clk_100MHz_1_1),
        .rd_en(rd_en_0_1),
        .rst(rst_0_1),
        .wr_clk(clk_100MHz_1),
        .wr_en(wr_en_0_1));
endmodule

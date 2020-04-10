//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Mon Mar 16 15:49:57 2020
//Host        : Helen running 64-bit major release  (build 9200)
//Command     : generate_target avg_col_cdc24.bd
//Design      : avg_col_cdc24
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "avg_col_cdc24,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=avg_col_cdc24,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "avg_col_cdc24.hwdef" *) 
module avg_col_cdc24
   (fifo_rd_clk,
    fifo_rd_data,
    fifo_rd_empty,
    fifo_rd_en,
    fifo_wr_clk,
    fifo_wr_data,
    fifo_wr_en,
    fifo_wr_full,
    reset);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FIFO_RD_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FIFO_RD_CLK, CLK_DOMAIN avg_col_cdc24_rd_clk_0, FREQ_HZ 100000000, PHASE 0.000" *) input fifo_rd_clk;
  output [23:0]fifo_rd_data;
  output fifo_rd_empty;
  input fifo_rd_en;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.FIFO_WR_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.FIFO_WR_CLK, CLK_DOMAIN avg_col_cdc24_wr_clk_0, FREQ_HZ 100000000, PHASE 0.000" *) input fifo_wr_clk;
  input [23:0]fifo_wr_data;
  input fifo_wr_en;
  output fifo_wr_full;
  input reset;

  wire [23:0]din_0_1;
  wire [23:0]fifo_generator_0_dout;
  wire fifo_generator_0_empty;
  wire fifo_generator_0_full;
  wire rd_clk_0_1;
  wire rd_en_0_1;
  wire rst_0_1;
  wire wr_clk_0_1;
  wire wr_en_0_1;

  assign din_0_1 = fifo_wr_data[23:0];
  assign fifo_rd_data[23:0] = fifo_generator_0_dout;
  assign fifo_rd_empty = fifo_generator_0_empty;
  assign fifo_wr_full = fifo_generator_0_full;
  assign rd_clk_0_1 = fifo_rd_clk;
  assign rd_en_0_1 = fifo_rd_en;
  assign rst_0_1 = reset;
  assign wr_clk_0_1 = fifo_wr_clk;
  assign wr_en_0_1 = fifo_wr_en;
  avg_col_cdc24_fifo_generator_0_0 fifo_generator_0
       (.din(din_0_1),
        .dout(fifo_generator_0_dout),
        .empty(fifo_generator_0_empty),
        .full(fifo_generator_0_full),
        .rd_clk(rd_clk_0_1),
        .rd_en(rd_en_0_1),
        .rst(rst_0_1),
        .wr_clk(wr_clk_0_1),
        .wr_en(wr_en_0_1));
endmodule


`timescale 1 ns / 1 ps

module averager_v1_0 #
(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH	= 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	= 7
)
(
    // Users to add ports here
    input pixel_clk,
    input [23:0] video_in_tdata,
    input video_in_tlast,
    input video_in_tuser,
    input video_in_tvalid,
    output video_in_tready,
    
    output [23:0] video_out_tdata,
    output video_out_tlast,
    output video_out_tuser,
    output video_out_tvalid,
    input video_out_tready,
    output [23:0] avg_out,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready
);

    reg [23:0] next_avg_out;
    
// Instantiation of Axi Bus Interface S00_AXI
	averager_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) averager_v1_0_S00_AXI_inst (
	    .avg_frame_color(next_avg_out),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here
// Instantiate averager module
    averager average_inst (
        .aclk(pixel_clk),
        .m_axis_video_tdata_in(video_in_tdata),
        .m_axis_video_tlast_in(video_in_tlast),
        .m_axis_video_tready_in(video_in_tready),
        .m_axis_video_tuser_in(video_in_tuser),
        .m_axis_video_tvalid_in(video_in_tvalid),
    
        .m_axis_video_tdata_out(video_out_tdata),
        .m_axis_video_tlast_out(video_out_tlast),
        .m_axis_video_tready_out(video_out_tready),
        .m_axis_video_tuser_out(video_out_tuser),
        .m_axis_video_tvalid_out(video_out_tvalid),
        .avg_out(avg_out)
    );
    
    
    /*
        cross clock domains
    */
    wire fifo_empty;
    wire fifo_full;
    wire [23:0] avg_out_rd_data;
    
    // cross which_filter between clock domains
    avg_col_cdc24 cc0 (
        .rd_clk(s00_axi_aclk),
        .wr_clk(pixel_clk),
        .reset(1'b0),
        .wr_data(avg_out),
        .wr_en(!fifo_full),
        .wr_full(fifo_full),
        .rd_data(avg_out_rd_data),
        .rd_en(!fifo_empty),
        .rd_empty(fifo_empty)
    );
    always @(posedge s00_axi_aclk)
        if(!s00_axi_aresetn)
            next_avg_out <= 24'b0;
        else if(!fifo_empty)
            next_avg_out <= avg_out_rd_data;

	// User logic ends

endmodule

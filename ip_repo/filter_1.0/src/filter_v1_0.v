`timescale 1 ns / 1 ps

module filter_v1_0 #
(
    // Users to add parameters here
    
    parameter integer COLOR_WIDTH = 8,
    
    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface ctrl
    parameter integer C_ctrl_DATA_WIDTH	= 32,
    parameter integer C_ctrl_ADDR_WIDTH	= 4
)
(
    // Users to add ports here

    input video_aclk,
    input video_aresetn,
    
    output video_in_tready,
    input [3*COLOR_WIDTH-1:0] video_in_tdata,
    input video_in_tuser,
    input video_in_tlast,
    input video_in_tvalid,
    
    input video_out_tready,
    output [3*COLOR_WIDTH-1:0] video_out_tdata,
    output video_out_tuser,
    output video_out_tlast,
    output video_out_tvalid,
    
    input [3*COLOR_WIDTH-1 : 0] avg_color,
    
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface ctrl
    input wire  ctrl_aclk,
    input wire  ctrl_aresetn,
    input wire [C_ctrl_ADDR_WIDTH-1 : 0] ctrl_awaddr,
    input wire [2 : 0] ctrl_awprot,
    input wire  ctrl_awvalid,
    output wire  ctrl_awready,
    input wire [C_ctrl_DATA_WIDTH-1 : 0] ctrl_wdata,
    input wire [(C_ctrl_DATA_WIDTH/8)-1 : 0] ctrl_wstrb,
    input wire  ctrl_wvalid,
    output wire  ctrl_wready,
    output wire [1 : 0] ctrl_bresp,
    output wire  ctrl_bvalid,
    input wire  ctrl_bready,
    input wire [C_ctrl_ADDR_WIDTH-1 : 0] ctrl_araddr,
    input wire [2 : 0] ctrl_arprot,
    input wire  ctrl_arvalid,
    output wire  ctrl_arready,
    output wire [C_ctrl_DATA_WIDTH-1 : 0] ctrl_rdata,
    output wire [1 : 0] ctrl_rresp,
    output wire  ctrl_rvalid,
    input wire  ctrl_rready
);

	localparam WHICH_FILTER_WIDTH = 4;
	wire [WHICH_FILTER_WIDTH-1:0] requested_filter, filter_out;
	reg [WHICH_FILTER_WIDTH-1:0] next_filter;
	
// Instantiation of Axi Bus Interface ctrl
	filter_v1_0_ctrl # ( 
	    .WHICH_FILTER_WIDTH(WHICH_FILTER_WIDTH),
	    
		.C_S_AXI_DATA_WIDTH(C_ctrl_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_ctrl_ADDR_WIDTH)
	) filter_v1_0_ctrl_inst (
	    .which_filter(requested_filter),
	
		.S_AXI_ACLK(ctrl_aclk),
		.S_AXI_ARESETN(ctrl_aresetn),
		.S_AXI_AWADDR(ctrl_awaddr),
		.S_AXI_AWPROT(ctrl_awprot),
		.S_AXI_AWVALID(ctrl_awvalid),
		.S_AXI_AWREADY(ctrl_awready),
		.S_AXI_WDATA(ctrl_wdata),
		.S_AXI_WSTRB(ctrl_wstrb),
		.S_AXI_WVALID(ctrl_wvalid),
		.S_AXI_WREADY(ctrl_wready),
		.S_AXI_BRESP(ctrl_bresp),
		.S_AXI_BVALID(ctrl_bvalid),
		.S_AXI_BREADY(ctrl_bready),
		.S_AXI_ARADDR(ctrl_araddr),
		.S_AXI_ARPROT(ctrl_arprot),
		.S_AXI_ARVALID(ctrl_arvalid),
		.S_AXI_ARREADY(ctrl_arready),
		.S_AXI_RDATA(ctrl_rdata),
		.S_AXI_RRESP(ctrl_rresp),
		.S_AXI_RVALID(ctrl_rvalid),
		.S_AXI_RREADY(ctrl_rready)
	);

	// Add user logic here
    
    apply_filter # (
        .WHICH_FILTER_WIDTH(WHICH_FILTER_WIDTH),
        .COLOR_WIDTH(COLOR_WIDTH)
    ) af (
        .clk(video_aclk),
        .aresetn(video_aresetn),
        
        .next_filter(next_filter),
        .avg_color(avg_color),
        
        .video_in_tdata(video_in_tdata),
        .video_in_tuser(video_in_tuser),
        .video_in_tlast(video_in_tlast),
        .video_in_tvalid(video_in_tvalid),
        .video_in_tready(video_in_tready),
        
        .video_out_tdata(video_out_tdata),
        .video_out_tuser(video_out_tuser),
        .video_out_tlast(video_out_tlast),
        .video_out_tvalid(video_out_tvalid),
        .video_out_tready(video_out_tready)
    );
    
    
    
    /*
        cross clock domains
    */
    wire fifo_empty;
    wire fifo_full;
    
    // cross which_filter between clock domains
    wh_ftr_cdc cc0 (
        .ctrl_aclk(ctrl_aclk),
        .video_aclk(video_aclk),
        .reset(!ctrl_aresetn),
        .wr_data(requested_filter),
        .wr_en(!fifo_full),
        .wr_full(fifo_full),
        .rd_data(filter_out),
        .rd_en(!fifo_empty),
        .rd_empty(fifo_empty)
    );
    always @(posedge video_aclk or negedge video_aresetn)
        if(!video_aresetn)
            next_filter <= {WHICH_FILTER_WIDTH{1'b0}};
        else if(!fifo_empty)
            next_filter <= filter_out;
            
	// User logic ends

endmodule

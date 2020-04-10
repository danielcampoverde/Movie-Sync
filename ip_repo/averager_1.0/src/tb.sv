`timescale 1 ns / 1 ps

module tb();
    localparam COLOR_WIDTH = 8;
    
    logic [23:0] avg_out;
    logic [23:0] next_avg_out;
    
    logic s00_axi_aclk;
    logic s00_axi_aresetn;
    initial begin
        s00_axi_aclk = 1;
        forever
            #5ns s00_axi_aclk = ~s00_axi_aclk;
    end
    initial begin
        s00_axi_aresetn = 0;
        #40;
        s00_axi_aresetn = 1;
    end
        
    logic pixel_clk;
    initial begin
        pixel_clk = 1;
        forever
            #4.166ns pixel_clk = ~pixel_clk;
    end
    
        
    logic video_in_tready;
    logic [3*COLOR_WIDTH-1:0] video_in_tdata;
    logic video_in_tuser;
    logic video_in_tlast;
    logic video_in_tvalid;
    
    logic video_out_tready;
    logic [3*COLOR_WIDTH-1:0] video_out_tdata;
    logic video_out_tuser;
    logic video_out_tlast;
    logic video_out_tvalid;
    
    integer count;
    initial begin
        video_in_tvalid = 0;
        #50;
        count = -1;
        video_out_tready = 1;
        forever begin
            @(posedge pixel_clk);
            video_in_tdata = $urandom;
            video_in_tvalid = 1;
            video_in_tlast = (count % 1920 == 1919);
            video_in_tuser = (count % (1920*1080) == 0);
            count++;
        end
    end
    
    averager dut (
        .aclk(pixel_clk),
        
        .m_axis_video_tdata_in(video_in_tdata),
        .m_axis_video_tlast_in(video_in_tlast),
        .m_axis_video_tuser_in(video_in_tuser),
        .m_axis_video_tvalid_in(video_in_tvalid),
        .m_axis_video_tready_in(video_in_tready),
        
        .m_axis_video_tdata_out(video_out_tdata),
        .m_axis_video_tlast_out(video_out_tlast),
        .m_axis_video_tuser_out(video_out_tuser),
        .m_axis_video_tvalid_out(video_out_tvalid),
        .m_axis_video_tready_out(video_out_tready),
        
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
        .reset(!s00_axi_aresetn),
        .wr_data(avg_out),
        .wr_en(!fifo_full),
        .wr_full(fifo_full),
        .rd_data(avg_out_rd_data),
        .rd_en(!fifo_empty),
        .rd_empty(fifo_empty)
    );
    always @(posedge s00_axi_aclk)
        next_avg_out <= avg_out_rd_data;
        
endmodule

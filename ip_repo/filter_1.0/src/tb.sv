`timescale 1 ns / 1 ps

module tb();
    localparam COLOR_WIDTH = 8;
    localparam WHICH_FILTER_WIDTH = 4;
    
    logic [WHICH_FILTER_WIDTH-1:0] requested_filter, filter_out;
    logic [WHICH_FILTER_WIDTH-1:0] next_filter;
    
    logic ctrl_aclk;
    logic ctrl_aresetn;
    initial begin
        ctrl_aclk = 1;
        forever
            #5ns ctrl_aclk = ~ctrl_aclk;
    end
    initial begin
        ctrl_aresetn = 0;
        #40;
        ctrl_aresetn = 1;
    end
        
    logic video_aclk;
    logic video_aresetn;
    initial begin
        video_aclk = 1;
        forever
            #4.166ns video_aclk = ~video_aclk;
    end
    initial begin
        video_aresetn = 0;
        #30;
        video_aresetn = 1;
    end
    
    initial begin
        requested_filter = 4;
//        #50;
//        forever begin
//            #100ns;
//            requested_filter = 3;
//            #100ns;
//            requested_filter = 0;
//        end            
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
    
    logic [3*COLOR_WIDTH-1:0] avg_color;
    
    integer count;
    initial begin
        video_in_tvalid = 0;
        #30;
        count = 0;
        avg_color = {8'hFF, 8'h80, 8'h80};
        forever begin
            @(posedge video_aclk);
            video_in_tdata = $urandom;
            video_in_tvalid = 1;
            video_in_tlast = (count % 10 == 9);
            video_in_tuser = (count % 100 == 0);
            count++;
            video_out_tready = 1;
        end
    end
    
    apply_filter # (
        .WHICH_FILTER_WIDTH(WHICH_FILTER_WIDTH),
        .COLOR_WIDTH(COLOR_WIDTH),
        .X_WIDTH(10),
        .Y_WIDTH(10)
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

endmodule

`timescale 1 ns / 1 ps

module apply_filter #(
    parameter WHICH_FILTER_WIDTH = 3,
    parameter COLOR_WIDTH = 8,
    parameter X_WIDTH = 1920,
    parameter Y_WIDTH = 1080
)
(
    input wire clk,
	input wire aresetn,
	
	input [WHICH_FILTER_WIDTH-1:0] next_filter,
	input [3*COLOR_WIDTH-1 : 0] avg_color,
	
    input wire [3*COLOR_WIDTH-1 : 0] video_in_tdata,
    input wire  video_in_tlast,
    input wire  video_in_tuser,
    input wire  video_in_tvalid,
    output logic  video_in_tready,
    
    output logic [3*COLOR_WIDTH-1 : 0] video_out_tdata,
    output logic  video_out_tlast,
    output logic  video_out_tuser,
    output logic  video_out_tvalid,
    input wire  video_out_tready
);
    /**
        NOTES:
        
        - To make changing filters without shear easy, all filters must comply with the DELAY
            requirement. All filters return data DELAY cycles after recieving it.
            - Exception: tready should be returned the same cycle. 
        
        - X, Y are aligned with the input data.
    
     */
    localparam NUM_FILTERS = 4;
    localparam DELAY = 8;
    integer i;
    
    logic XY_synced, XY_sync_en;
    logic [10:0] X, Y, nextX, nextY;
        
    logic [WHICH_FILTER_WIDTH-1:0] current_filter, which_filter;
    logic [3*COLOR_WIDTH-1 : 0] tdata [NUM_FILTERS:0];
    logic tlast [NUM_FILTERS:0];
    logic tuser [NUM_FILTERS:0];
    logic tvalid [NUM_FILTERS:0];
    logic tready [NUM_FILTERS:0];
    
    /*
        This section is intended to generate the current X,Y coordinate of the
        current input pixel.
        
        - The origin is the top left. X is the column as it goes across a row, Y is the row.
        - X and Y should be zero until they synchronize (they see a valid tuser).
        - I saw a problem where X and Y became desynchronized when connecting and disconecting peripherals
          so I am synchronizing them at every tuser (beginning of each frame)
    */
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn)
            XY_synced <= 1'b0;
        else if(XY_sync_en)
            XY_synced <= 1'b1;
    end
    always_ff @(posedge clk or negedge aresetn) begin 
        if(!aresetn) begin
            X <= 11'b0;
            Y <= 11'b0;
        end
        else if(video_in_tvalid) begin
            X <= nextX;
            Y <= nextY;
        end
    end
    always_comb begin
        XY_sync_en = video_in_tuser && video_in_tvalid;
        
        nextX = X;
        nextY = Y;
        if(XY_sync_en) begin
            nextX = 1;
            nextY = 0;
        end
        else if(XY_synced) begin
            if(X < (X_WIDTH-1)) begin
                nextX = X + 1;
            end
            else begin
                nextX = 0;
                if(Y < (Y_WIDTH-1))
                    nextY = Y + 1;
                else
                    nextY = 0;
            end
        end
    end
    
    /*
        which_filter is the current filter to use.
        
        - This logic delays the change of filter until the change of frame.
    */
    always_ff @(posedge clk or negedge aresetn)
        if(!aresetn)
            current_filter <= '0;
        else if(video_out_tvalid && video_out_tuser)
            current_filter <= next_filter;
    
    always_comb begin
        if(tvalid[0] && tuser[0])
            which_filter = next_filter;
        else
            which_filter = current_filter;
    end

    /*
        This multiplexes which filter's output to display.
        
        - Default is filter 0
        
        ---------
        filter 0: no change
        filter 1: greyscale
        filter 2: vignette with black
        filter 3: vignette with most prominent color - weaker
        filter 4: vignette with most prominent color - stronger
        
        filter 6: vignette with black - stronger
        filter 7: test pattern
    */
    always_comb begin
        video_out_tdata     = tdata[0];
        video_out_tlast     = tlast[0];
        video_out_tuser     = tuser[0];
        video_out_tvalid    = tvalid[0];
        video_in_tready     = tready[0];
        
        case(which_filter)
            'd1: begin
                video_out_tdata = tdata[1];
            end
            'd2: begin
                video_out_tdata = tdata[2];
            end
            'd3: begin
                video_out_tdata = tdata[2];
            end
            'd4: begin
                video_out_tdata = tdata[2];
            end
            'd6: begin
                video_out_tdata = tdata[2];
            end
            'd7: begin
                video_out_tdata = tdata[3];
            end

        endcase
//        for(i = 1 ; (i < (1 << WHICH_FILTER_WIDTH)) && (i <= NUM_FILTERS) ; i++) begin
//            if(which_filter == i) begin
//                video_out_tdata     = tdata[i];
//                video_out_tlast     = tlast[i];
//                video_out_tuser     = tuser[i];
//                video_out_tvalid    = tvalid[i];
//                video_in_tready     = tready[i];
//            end
//        end
    end
    
    /*
        This section instantiates each filter.
        
        - To make changing filters without shear easy, all filters must comply with the DELAY
            requirement. All filters return data DELAY cycles after recieving it.
            - Exception: tready should be returned the same cycle.
            
            - All filters are expected to immediately clock the inputs
            - if the delay is 1 then they should clock the result into out on the following clock edge
            - DELAY is the number of cycles that there are between the input and output registers.
        
        - filter 0 is reserved for the no change filter
    */
    
    filter_0 # (
        .DELAY(DELAY),
        .COLOR_WIDTH(COLOR_WIDTH)
    ) f0 (
        .clk,
        .aresetn,
        
        .video_in_tdata,
        .video_in_tuser,
        .video_in_tlast,
        .video_in_tvalid,
        .video_in_tready(tready[0]),
        
        .video_out_tdata(tdata[0]),
        .video_out_tuser(tuser[0]),
        .video_out_tlast(tlast[0]),
        .video_out_tvalid(tvalid[0]),
        .video_out_tready
    );
        
    filter_1 # (
        .DELAY(DELAY),
        .COLOR_WIDTH(COLOR_WIDTH)
    ) f1 (
        .clk,
        .aresetn,
        .video_in_tdata,
        .video_out_tdata(tdata[1])
    );    
    
    filter_4 # (
        .DELAY(DELAY),
        .COLOR_WIDTH(COLOR_WIDTH),
        .WHICH_FILTER_WIDTH(WHICH_FILTER_WIDTH)
    ) f2 (
        .clk,
        .aresetn,
        
        .video_in_X(X),
        .video_in_Y(Y),
        .avg_color(avg_color),
        .filter(which_filter),
        
        .video_in_tdata,
        .video_in_tuser,
        .video_in_tlast,
        .video_in_tvalid,
        .video_in_tready(tready[2]),
        
        .video_out_tdata(tdata[2]),
        .video_out_tuser(tuser[2]),
        .video_out_tlast(tlast[2]),
        .video_out_tvalid(tvalid[2]),
        .video_out_tready
    );
    
    filter_3 # (
        .DELAY(DELAY),
        .COLOR_WIDTH(COLOR_WIDTH)
    ) f3 (
        .clk,
        .aresetn,
        
        .video_in_X(X),
        .video_in_Y(Y),
                
        .video_in_tdata,
        .video_in_tuser,
        .video_in_tlast,
        .video_in_tvalid,
        .video_in_tready(tready[3]),
        
        .video_out_tdata(tdata[3]),
        .video_out_tuser(tuser[3]),
        .video_out_tlast(tlast[3]),
        .video_out_tvalid(tvalid[3]),
        .video_out_tready
    );
    
endmodule
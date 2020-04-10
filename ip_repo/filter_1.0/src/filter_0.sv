`timescale 1 ns / 1 ps

module filter_0 #(
    parameter DELAY = 1,
    parameter COLOR_WIDTH = 8
)
(
    input wire clk,
	input wire aresetn,
	
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

    assign video_in_tready = video_out_tready && aresetn;
    
    logic [3*COLOR_WIDTH-1:0] tdata[DELAY:0];
    logic tlast[DELAY:0];
    logic tuser[DELAY:0];
    logic tvalid[DELAY:0];
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[0] <= {3{{COLOR_WIDTH{1'b0}}}};
            tlast[0] <= 1'b0;
            tuser[0] <= 1'b0;
            tvalid[0] <= 1'b0;
        end
        else begin
            tdata[0] <= video_in_tdata;
            tvalid[0] <= video_in_tvalid;
            tlast[0] <= video_in_tlast;
            tuser[0] <= video_in_tuser;
        end
    end
    
    integer i;
    always_ff @(posedge clk or negedge aresetn) begin
        for(i = 1 ; i <= DELAY ; i++) begin
            if(!aresetn) begin
                tdata[i] <= {3{{COLOR_WIDTH{1'b0}}}};
                tlast[i] <= 1'b0;
                tuser[i] <= 1'b0;
                tvalid[i] <= 1'b0;
            end
            else begin
                tdata[i] <= tdata[i-1];
                tlast[i] <= tlast[i-1];
                tuser[i] <= tuser[i-1];
                tvalid[i] <= tvalid[i-1];
            end
        end
    end
    
    always_comb begin
        video_out_tdata = tdata[DELAY];
        video_out_tlast = tlast[DELAY];
        video_out_tuser = tuser[DELAY];
        video_out_tvalid = tvalid[DELAY];
    end
    
endmodule
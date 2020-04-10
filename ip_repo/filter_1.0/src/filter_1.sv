`timescale 1 ns / 1 ps

module filter_1 #(
    parameter DELAY = 1,
    parameter COLOR_WIDTH = 8
)
(
    input wire clk,
	input wire aresetn,
	
	input wire [3*COLOR_WIDTH-1 : 0] video_in_tdata,
    output logic [3*COLOR_WIDTH-1 : 0] video_out_tdata
);

    logic [3*COLOR_WIDTH-1:0] tdata[DELAY:0];
    
    localparam Rt = 3*COLOR_WIDTH-1;// R top
    localparam Rb = 2*COLOR_WIDTH;  // R bottom
    localparam Bt = 2*COLOR_WIDTH-1;// B top
    localparam Bb = COLOR_WIDTH;    // B bottom
    localparam Gt = COLOR_WIDTH-1;  // G top
    localparam Gb = 0;              // G bottom 
    
    /**     scaling factors     **
        new_component = (old_component * mul) >> div
            =  (old_component * mul) / 2^div
    */
    localparam Rmul = 4899; // true = 0.299
    localparam Rdiv = 14; // approx = 
    localparam Bmul = 7471; // true = 0.114
    localparam Bdiv = 16; // approx = 
    localparam Gmul = 4809; // true = 0.587
    localparam Gdiv = 13; // approx = 

    logic [COLOR_WIDTH-1:0] grey_sum;
        
    /*
        Clock data upon input.
    */
    // cycle 0
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[0] <= {3{{COLOR_WIDTH{1'b0}}}};
            tdata[1] <= {3{{COLOR_WIDTH{1'b0}}}};
            tdata[2] <= {3{{COLOR_WIDTH{1'b0}}}};
        end
        else begin
            tdata[0] <= video_in_tdata;
            
            tdata[1][Rt:Rb] <= (tdata[0][Rt:Rb] * Rmul) >> Rdiv;
            tdata[1][Bt:Bb] <= (tdata[0][Bt:Bb] * Bmul) >> Bdiv;
            tdata[1][Gt:Gb] <= (tdata[0][Gt:Gb] * Gmul) >> Gdiv;
            
            tdata[2][Rt:Rb] <= grey_sum;
            tdata[2][Bt:Bb] <= grey_sum;
            tdata[2][Gt:Gb] <= grey_sum;
        end        
    end
    always_comb begin
        grey_sum = tdata[1][Rt:Rb] + tdata[1][Bt:Bb] + tdata[1][Gt:Gb];
    end
    
    integer i;
    always_ff @(posedge clk or negedge aresetn) begin
        for(i = 3 ; i <= DELAY ; i++) begin
            if(!aresetn)
                tdata[i] <= {3{{COLOR_WIDTH{1'b0}}}};
            else
                tdata[i] <= tdata[i-1];
        end
    end
    always_comb begin
        video_out_tdata = tdata[DELAY];
    end
endmodule
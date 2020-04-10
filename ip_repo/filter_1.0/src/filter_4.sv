`timescale 1 ns / 1 ps

module filter_4 #(
    parameter DELAY = 8,
    parameter COLOR_WIDTH = 8,
    parameter X_MID = 960,
    parameter Y_MID = 540,
    parameter WHICH_FILTER_WIDTH = 3
)
(
    input wire clk,
	input wire aresetn,
	
	input [10:0] video_in_X,
	input [10:0] video_in_Y,
	input [3*COLOR_WIDTH-1 : 0] avg_color,
	input [WHICH_FILTER_WIDTH-1:0] filter,
	
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
    
    always_ff @(posedge clk)
        if(!aresetn)
            tlast <= {tlast[DELAY-1:0], 1'b0};
        else
            tlast <= {tlast[DELAY-1:0], video_in_tlast};
    always_ff @(posedge clk)
        if(!aresetn)
            tuser <= {tlast[DELAY-1:0], 1'b0};
        else
            tuser <= {tlast[DELAY-1:0], video_in_tuser};
    always_ff @(posedge clk)
        if(!aresetn)
            tvalid <= {tlast[DELAY-1:0], 1'b0};
        else
            tvalid <= {tlast[DELAY-1:0], video_in_tvalid};
    
    
    logic [10:0] X[2:0], Y[2:0];
    logic top_1, left_1;
    logic [18:0] aX2_3, bY2_3;
    logic [18:0] R2_4;
    
    localparam MUL_BITS = 8;
    localparam RGB_DIV = MUL_BITS;
    logic [MUL_BITS-1:0] RGB_mul_5;
    logic [MUL_BITS-1:0] inv_RGB_mul_6;
    
    logic [3*COLOR_WIDTH-1 : 0] avg_col[7:1];
    
    
    logic [WHICH_FILTER_WIDTH-1:0] filt[4:0];
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn)
            filt[0] <= {WHICH_FILTER_WIDTH{1'b0}};
        else
            filt[0] <= filter; 
    end
    always_ff @(posedge clk or negedge aresetn) begin
        for(integer i = 1 ; i <= 4 ; i++) begin
            if(!aresetn) begin
                filt[i] <= {WHICH_FILTER_WIDTH{1'b0}};
            end
            else begin
                filt[i] <= filt[i-1]; 
            end
        end
    end
    logic stronger_dropoff_4, use_avg_col_0;
    assign stronger_dropoff_4 = filt[4][2]; // 4-7
    assign use_avg_col_0 = filt[0][1:0] != 2'b10; // not 2 nor 6 
    
    localparam VIGNETTE_BITS = 10;
    localparam VIGNETTE_MEM_SIZE = 1024;
    (* rom_type="block" *) logic [MUL_BITS-1:0] vignette_xform_25 [VIGNETTE_MEM_SIZE-1:0];
    (* rom_type="block" *) logic [MUL_BITS-1:0] vignette_xform_10 [VIGNETTE_MEM_SIZE-1:0];
    initial begin
        $readmemh("vignette_xform.mem", vignette_xform_25);
        $readmemh("vignette_xform_10.mem", vignette_xform_10);
    end
    
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[0] <= {3{{COLOR_WIDTH{1'b0}}}};
            X[0] <= 11'b0;
            Y[0] <= 11'b0;
        end
        else begin
            tdata[0] <= video_in_tdata;
            X[0] <= video_in_X;
            Y[0] <= video_in_Y;
        end
    end
        
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[1] <= {3{{COLOR_WIDTH{1'b0}}}};
            X[1] <= 11'b0;
            Y[1] <= 11'b0;
            top_1 <= 1'b0;
            left_1 <= 1'b0;
            avg_col[1] <= {3{{COLOR_WIDTH{1'b0}}}};
        end
        else begin
            tdata[1] <= tdata[0];
            X[1] <= X[0];
            Y[1] <= Y[0];
            left_1 <= X[0] < X_MID;
            top_1 <= Y[0] < Y_MID;
            
            /** We take this in one cycle later since it takes one cycle after the end of the frame
                to be produced in the averaging block.
                We must also transform it from the averaging output of RGB
                to the standard video stream input of RBG
            */
            if(use_avg_col_0)
                avg_col[1] <= {avg_color[3*COLOR_WIDTH-1:2*COLOR_WIDTH], avg_color[COLOR_WIDTH-1:0], avg_color[2*COLOR_WIDTH-1:COLOR_WIDTH]};
            else
                avg_col[1] <= {3{{COLOR_WIDTH{1'b0}}}};
        end
    end
    
    always_ff @(posedge clk or negedge aresetn) begin
        for(integer i = 2 ; i <= 6 ; i++) begin
            if(!aresetn) begin
                avg_col[i] <= {3{{COLOR_WIDTH{1'b0}}}};
            end
            else begin
                avg_col[i] <= avg_col[i-1]; 
            end
        end
    end
        
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[2] <= {3{{COLOR_WIDTH{1'b0}}}};
            X[2] <= 11'b0;
            Y[2] <= 11'b0;
        end
        else begin
            tdata[2] <= tdata[1];
            if(left_1)
                X[2] <= X_MID - X[1];
            else
                X[2] <= X[1] - X_MID;
            if(top_1)
                Y[2] <= Y_MID - Y[1];
            else
                Y[2] <= Y[1] - Y_MID;
        end
    end
        
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[3] <= {3{{COLOR_WIDTH{1'b0}}}};
            aX2_3 <= 19'b0;
            bY2_3 <= 19'b0;
        end
        else begin
            tdata[3] <= tdata[2];
            aX2_3 <= X[2][10:1] * X[2][10:1];
            bY2_3 <= Y[2] * Y[2];
        end
    end
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[4] <= {3{{COLOR_WIDTH{1'b0}}}};
            R2_4 <= 19'b0;
        end
        else begin
            tdata[4] <= tdata[3];
            R2_4 <= aX2_3 + bY2_3;
        end
    end
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[5] <= {3{{COLOR_WIDTH{1'b0}}}}; 
            RGB_mul_5 <= {MUL_BITS{1'b0}};
        end
        else begin
            tdata[5] <= tdata[4];
            if(stronger_dropoff_4)
                RGB_mul_5 <= vignette_xform_10[R2_4[18:18-VIGNETTE_BITS+1]];
            else
                RGB_mul_5 <= vignette_xform_25[R2_4[18:18-VIGNETTE_BITS+1]];
        end
    end
    
    logic [COLOR_WIDTH+MUL_BITS-1:0] newR_56, newB_56, newG_56;
    always_comb begin
        newR_56 = (tdata[5][3*COLOR_WIDTH-1:2*COLOR_WIDTH] * RGB_mul_5) >> RGB_DIV;
        newB_56 = (tdata[5][2*COLOR_WIDTH-1:COLOR_WIDTH] * RGB_mul_5) >> RGB_DIV;
        newG_56 = (tdata[5][COLOR_WIDTH-1:0] * RGB_mul_5) >> RGB_DIV;
    end
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[6] <= {3{{COLOR_WIDTH{1'b0}}}};
            inv_RGB_mul_6 <= {MUL_BITS{1'b0}};
        end
        else begin
            tdata[6] <= {newR_56[COLOR_WIDTH-1:0], newB_56[COLOR_WIDTH-1:0], newG_56[COLOR_WIDTH-1:0]};
            inv_RGB_mul_6 <= 9'h100 - RGB_mul_5;
        end
    end
    
    logic [COLOR_WIDTH+MUL_BITS-1:0] newR_67_bkgnd, newB_67_bkgnd, newG_67_bkgnd;
    always_comb begin
        newR_67_bkgnd = (avg_col[6][3*COLOR_WIDTH-1:2*COLOR_WIDTH] * inv_RGB_mul_6) >> RGB_DIV;
        newB_67_bkgnd = (avg_col[6][2*COLOR_WIDTH-1:COLOR_WIDTH] * inv_RGB_mul_6) >> RGB_DIV;
        newG_67_bkgnd = (avg_col[6][COLOR_WIDTH-1:0] * inv_RGB_mul_6) >> RGB_DIV;
    end
        
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[7] <= {3{{COLOR_WIDTH{1'b0}}}};
        end
        else begin
            tdata[7] <= tdata[6];
            avg_col[7] <= {newR_67_bkgnd[COLOR_WIDTH-1:0], newB_67_bkgnd[COLOR_WIDTH-1:0], newG_67_bkgnd[COLOR_WIDTH-1:0]};
        end
    end
    
    logic [COLOR_WIDTH-1:0] newR_78, newB_78, newG_78;
    always_comb begin
        newR_78 = tdata[7][3*COLOR_WIDTH-1:2*COLOR_WIDTH] + avg_col[7][3*COLOR_WIDTH-1:2*COLOR_WIDTH];
        newB_78 = tdata[7][2*COLOR_WIDTH-1:COLOR_WIDTH] + avg_col[7][2*COLOR_WIDTH-1:COLOR_WIDTH];
        newG_78 = tdata[7][COLOR_WIDTH-1:0] + avg_col[7][COLOR_WIDTH-1:0];
    end
    
    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            tdata[8] <= {3{{COLOR_WIDTH{1'b0}}}};
        end
        else begin
            tdata[8] <= {newR_78, newB_78, newG_78};
        end
    end
        
    always_ff @(posedge clk or negedge aresetn) begin
        for(integer i = 9 ; i <= DELAY ; i++) begin
            if(!aresetn) begin
                tdata[i] <= {3{{COLOR_WIDTH{1'b0}}}};
            end
            else begin
                tdata[i] <= tdata[i-1]; 
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
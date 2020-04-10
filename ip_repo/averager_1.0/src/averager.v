// Part of a custom IP that will find the average RGB values for a section of the screen

`timescale 1 ps / 1 ps

module averager (
	input 			aclk,
	
	input 	[23:0] 	m_axis_video_tdata_in,
	input 			m_axis_video_tlast_in,
	input 			m_axis_video_tuser_in,
	input 			m_axis_video_tvalid_in,
	output 			m_axis_video_tready_in,
	
	output	[23:0]	m_axis_video_tdata_out,
	output			m_axis_video_tlast_out,
	output			m_axis_video_tuser_out,
	output			m_axis_video_tvalid_out,
	input			m_axis_video_tready_out,
	
	output  [23:0]  avg_out
	);

// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2

 function integer clogb2 (input integer bit_depth);
     begin
     for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
         bit_depth = bit_depth >> 1;
     end
 endfunction

// Parameters (for opportunities to make the verilog more modular)
parameter integer PIXEL_DATA_DEPTH = 24;
parameter integer COLOR_DATA_DEPTH = PIXEL_DATA_DEPTH/3;
parameter integer FRAME_WIDTH = 1080;
parameter integer FRAME_HEIGHT = 1920;
parameter integer NUM_BLOCKS_X = 1;
parameter integer NUM_BLOCKS_Y = 1;
parameter integer BLOCK_PIXEL_WIDTH = FRAME_WIDTH / NUM_BLOCKS_X; // Make sure the math here checks out, no decimals!
parameter integer BLOCK_PIXEL_HEIGHT = FRAME_HEIGHT / NUM_BLOCKS_Y;
parameter integer BLOCK_PIXEL_TOTAL = BLOCK_PIXEL_HEIGHT * BLOCK_PIXEL_WIDTH;
parameter integer SUMDEPTH = clogb2(BLOCK_PIXEL_TOTAL) + COLOR_DATA_DEPTH;

// Wires & Regs
wire [COLOR_DATA_DEPTH-1:0] data_in_red; //[7:0]
wire [COLOR_DATA_DEPTH-1:0] data_in_green; //[7:0]
wire [COLOR_DATA_DEPTH-1:0] data_in_blue; //[7:0]

(* mark_debug = "True" *) reg [SUMDEPTH-1:0] sum_red; //[28:0]
(* mark_debug = "True" *) reg [SUMDEPTH-1:0] sum_green; //[28:0]
(* mark_debug = "True" *) reg [SUMDEPTH-1:0] sum_blue; //[28:0]

wire [COLOR_DATA_DEPTH-1:0] avg_red; //[7:0]
wire [COLOR_DATA_DEPTH-1:0] avg_green; //[7:0]
wire [COLOR_DATA_DEPTH-1:0] avg_blue; //[7:0]

reg [PIXEL_DATA_DEPTH-1:0] avg_block_color; //[23:0]
reg [NUM_BLOCKS_X * NUM_BLOCKS_Y - 1:0] block_counter; //[0:0]

// Continuous Assignments
assign data_in_red = m_axis_video_tdata_in[PIXEL_DATA_DEPTH-1:PIXEL_DATA_DEPTH-COLOR_DATA_DEPTH]; //[23:16]
assign data_in_green = m_axis_video_tdata_in[COLOR_DATA_DEPTH-1:0]; //[7:0]
assign data_in_blue = m_axis_video_tdata_in[(2*COLOR_DATA_DEPTH)-1:COLOR_DATA_DEPTH]; //[15:8]

// The average pixel color is approximated with sum of all RGB values, then divided (left shift) by #pixels in the frame
assign avg_red = sum_red[SUMDEPTH-1:SUMDEPTH-COLOR_DATA_DEPTH]; //sum_red[27:20]
assign avg_green = sum_green[SUMDEPTH-1:SUMDEPTH-COLOR_DATA_DEPTH]; //sum_green[27:20]
assign avg_blue = sum_blue[SUMDEPTH-1:SUMDEPTH-COLOR_DATA_DEPTH]; //sum_blue[27:20]

// Pass through these control signals without altering them for now
assign m_axis_video_tdata_out = m_axis_video_tdata_in;
assign m_axis_video_tready_in = m_axis_video_tready_out;
assign m_axis_video_tvalid_out = m_axis_video_tvalid_in;	// will have to update when filtering is implemented
assign m_axis_video_tuser_out = m_axis_video_tuser_in;
assign m_axis_video_tlast_out = m_axis_video_tlast_in;

// Assign the average frame (for now) color out
assign avg_out = avg_block_color;

// summing pixel inputs
always @ (posedge aclk) 
begin
    if(m_axis_video_tvalid_in && m_axis_video_tuser_in)
        begin
            // start of new frame, restart the pixel accumulation in sum regs
            sum_red <= {20'b0, data_in_red};
            sum_green <= {20'b0, data_in_green};
            sum_blue <= {20'b0, data_in_blue};
            
            // update the average block RGB value (this should be of the previous frame)
            // may have timing issues because throwing in 3 wires that are updated by regs at the same time
            avg_block_color <= {avg_red, avg_green, avg_blue};
        end
    else if(m_axis_video_tvalid_in && ~m_axis_video_tuser_in)
        begin
            // accumulate pixel values in the frame to the sum regs
            sum_red <= sum_red + data_in_red;
            sum_green <= sum_green + data_in_green;
            sum_blue <= sum_blue + data_in_blue;
        end
end

//
endmodule

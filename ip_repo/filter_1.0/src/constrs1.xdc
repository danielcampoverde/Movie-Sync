#Clock Signal
create_clock -period 10.000 -name ctrl_aclk -waveform {0.000 5.000} -add [get_ports ctrl_aclk]
create_clock -period 8.333 -name video_aclk -waveform {0.000 4.166} -add [get_ports video_aclk]

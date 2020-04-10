#Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports sys_clk_i]
create_clock -period 10.000 -name sys_clk_i -waveform {0.000 5.000} -add [get_ports sys_clk_i]

set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports reset]

##LEDs
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS25 } [get_ports { led[0] }]; #IO_L15P_T2_DQS_13 Sch=led[0]
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS25 } [get_ports { led[1] }]; #IO_L15N_T2_DQS_13 Sch=led[1]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { led[2] }]; #IO_L17P_T2_13 Sch=led[2]
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS25 } [get_ports { led[3] }]; #IO_L17N_T2_13 Sch=led[3]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS25 } [get_ports { led[4] }]; #IO_L14N_T2_SRCC_13 Sch=led[4]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS25 } [get_ports { led[5] }]; #IO_L16N_T2_13 Sch=led[5]
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS25 } [get_ports { led[6] }]; #IO_L16P_T2_13 Sch=led[6]
#set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS25 } [get_ports { led[7] }]; #IO_L5P_T0_13 Sch=led[7]


## Buttons
#set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS12 } [get_ports { btnc }]; #IO_L20N_T3_16 Sch=btnc
#set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS12 } [get_ports { btnd }]; #IO_L22N_T3_16 Sch=btnd
#set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS12 } [get_ports { btnl }]; #IO_L20P_T3_16 Sch=btnl
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS12 } [get_ports { btnr }]; #IO_L6P_T0_16 Sch=btnr
#set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS12 } [get_ports { btnu }]; #IO_0_16 Sch=btnu
#set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports { cpu_resetn }]; #IO_L12N_T1_MRCC_35 Sch=cpu_resetn

##Switches
#set_property -dict { PACKAGE_PIN E22  } [get_ports { sw[0] }]; #IO_L22P_T3_16 Sch=sw[0]
#set_property -dict { PACKAGE_PIN F21  } [get_ports { sw[1] }]; #IO_25_16 Sch=sw[1]
#set_property -dict { PACKAGE_PIN G21  } [get_ports { sw[2] }]; #IO_L24P_T3_16 Sch=sw[2]
#set_property -dict { PACKAGE_PIN G22  } [get_ports { sw[3] }]; #IO_L24N_T3_16 Sch=sw[3]
#set_property -dict { PACKAGE_PIN H17  } [get_ports { sw[4] }]; #IO_L6P_T0_15 Sch=sw[4]
#set_property -dict { PACKAGE_PIN J16  } [get_ports { sw[5] }]; #IO_0_15 Sch=sw[5]
#set_property -dict { PACKAGE_PIN K13  } [get_ports { sw[6] }]; #IO_L19P_T3_A22_15 Sch=sw[6]
#set_property -dict { PACKAGE_PIN M17  } [get_ports { sw[7] }]; #IO_25_15 Sch=sw[7]


##OLED Display
#set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports { oled_dc }]; #IO_L7N_T1_D10_14 Sch=oled_dc
#set_property -dict { PACKAGE_PIN U21   IOSTANDARD LVCMOS33 } [get_ports { oled_res }]; #IO_L4N_T0_D05_14 Sch=oled_res
#set_property -dict { PACKAGE_PIN W21   IOSTANDARD LVCMOS33 } [get_ports { oled_sclk }]; #IO_L7P_T1_D09_14 Sch=oled_sclk
#set_property -dict { PACKAGE_PIN Y22   IOSTANDARD LVCMOS33 } [get_ports { oled_sdin }]; #IO_L9N_T1_DQS_D13_14 Sch=oled_sdin
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD LVCMOS33 } [get_ports { oled_vbat }]; #IO_0_14 Sch=oled_vbat
#set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports { oled_vdd }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=oled_vdd


#HDMI in
#set_property -dict { PACKAGE_PIN AA5   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L10P_T1_34 Sch=hdmi_rx_cec
set_property -dict {PACKAGE_PIN W4 IOSTANDARD TMDS_33} [get_ports TMDS_IN_clk_n]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD TMDS_33} [get_ports TMDS_IN_clk_p]
# **** orig
#create_clock -period 12.500 -name tmds_clk_pin -waveform {0.000 6.250} -add [get_ports TMDS_IN_clk_p]
# **** mine
#create_clock -period 8.000 -name tmds_clk_pin -waveform {0.000 4.000} -add [get_ports TMDS_IN_clk_p]
create_clock -period 8.333 -name tmds_clk_pin -waveform {0.000 4.166} -add [get_ports TMDS_IN_clk_p]
# ****
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS25} [get_ports hdmi_hpd]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports DDC_scl_io]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports DDC_sda_io]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_txen]
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_n[0]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_p[0]}]
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_n[1]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_p[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_n[2]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD TMDS_33} [get_ports {TMDS_IN_data_p[2]}]


##HDMI out
#set_property -dict { PACKAGE_PIN AA4   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L11N_T1_SRCC_34 Sch=hdmi_tx_cec
set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports TMDS_OUT_clk_n]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports TMDS_OUT_clk_p]
#set_property -dict { PACKAGE_PIN AB13  IOSTANDARD LVCMOS25 } [get_ports { hdmi_hpd }]; #IO_L3N_T0_DQS_13 Sch=hdmi_tx_hpd
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rscl }]; #IO_L6P_T0_34 Sch=hdmi_tx_rscl
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rsda }]; #IO_L6N_T0_VREF_34 Sch=hdmi_tx_rsda
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_n[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_p[0]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_n[1]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_p[1]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_n[2]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports {TMDS_OUT_data_p[2]}]






################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name fifo_rd_clk -period 10 [get_ports fifo_rd_clk]
create_clock -name fifo_wr_clk -period 10 [get_ports fifo_wr_clk]

################################################################################
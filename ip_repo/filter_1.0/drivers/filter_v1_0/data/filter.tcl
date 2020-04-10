

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "filter" "NUM_INSTANCES" "DEVICE_ID"  "C_ctrl_BASEADDR" "C_ctrl_HIGHADDR"
}

export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export VLOG ?= vlog +incdir+$(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript

comp_I2C_MB:
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: clean comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug: compile simulate

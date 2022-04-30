export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export VLOG ?= vlog +incdir+$(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg

#TEST_TYPE ?= i2c_write_test
#TEST_TYPE ?= i2c_read_test
#TEST_TYPE ?= i2c_random_test
TEST_TYPE ?= i2c_rep_start_test
#TEST_TYPE ?= reg_reset_test
#TEST_TYPE ?= reg_access_test
#TEST_TYPE ?= clock_sync_test
#TEST_TYPE ?= arbitration_test
#TEST_TYPE ?= wait_test
#TEST_TYPE ?= clock_stretch_test

TEST_SEED ?= 12345

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript

clean_coverage:
	rm -rf *.ucdb

comp_I2C_MB:
	vcom -cover s ../rtl/iicmb_int_pkg.vhd
	vcom -cover s ../rtl/iicmb_pkg.vhd
	vcom -cover s ../rtl/mbyte.vhd
	vcom -cover s ../rtl/mbit.vhd
	vcom -cover s ../rtl/bus_state.vhd
	vcom -cover s ../rtl/filter.vhd
	vcom -cover s ../rtl/conditioner.vhd
	vcom -cover s ../rtl/conditioner_mux.vhd
	vcom -cover s ../rtl/iicmb_m.vhd
	vcom -cover s ../rtl/regblock.vhd
	vcom -cover s ../rtl/wishbone.vhd
	vcom -cover s ../rtl/iicmb_m_wb.vhd


comp_bench: comp_I2C_MB comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: clean comp_I2C_MB comp_bench optimize

run_cli:
	vsim  -c -coverage -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(TEST_TYPE); coverage save $(TEST_TYPE).$(TEST_SEED).ucdb; quit -f" +TEST_TYPE=$(TEST_TYPE) optimized_debug_top_tb

run_gui:
	vsim  -DTESTNAME=HELLO -sv_seed $(TEST_SEED) -do "do wave.do;run -a" +TEST_TYPE=$(TEST_TYPE) optimized_debug_top_tb

cli: compile run_cli

debug: compile run_gui

convert_testplan:
	xml2ucdb -format Excel ./test_plan.xml ./test_plan.ucdb

merge_coverage:
	vcover merge -stats=none -strip 0 -totals merged.ucdb ./*.ucdb
	#coverage open ./merge.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./merged.ucdb

# testlist.sh 
# Runs all tests and reports coverage

# Compile Testbench
make compile

# Remove Old Test Results
make clean_coverage

# Run Tests
TEST_TYPE="i2c_write_test"     make run_cli
TEST_TYPE="i2c_read_test"      make run_cli
TEST_TYPE="i2c_random_test"    make run_cli
TEST_TYPE="i2c_rep_start_test" make run_cli
TEST_TYPE="reg_reset_test"     make run_cli
TEST_TYPE="reg_access_test"    make run_cli
TEST_TYPE="clock_sync_test"    make run_cli
TEST_TYPE="arbitration_test"   make run_cli
TEST_TYPE="wait_test"          make run_cli
TEST_TYPE="clock_stretch_test" make run_cli

# Merge Coverage
make convert_testplan
make merge_coverage

# Report Coverage
make report_coverage


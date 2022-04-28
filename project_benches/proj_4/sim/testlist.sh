# testlist.sh 
# Runs all tests and reports coverage

# Compile Testbench
make compile

# Run Tests
TEST_TYPE="i2c_test"        make run_cli
TEST_TYPE="i2c_rep_start"   make run_cli
TEST_TYPE="i2c_random_test" make run_cli
TEST_TYPE="reg_access_test" make run_cli
TEST_TYPE="clock_sync_test" make run_cli

# Merge Coverage
make convert_testplan
make merge_coverage

# Report Coverage
make report_coverage


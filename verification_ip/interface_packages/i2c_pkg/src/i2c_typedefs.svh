// Determines whether a transaction is a write or a read
typedef enum bit { WRITE=0, READ=1 } i2c_op_t;

localparam int I2C_NUM_BUSSES = 1;
localparam int I2C_ADDR_WIDTH = 7;
localparam int I2C_DATA_WIDTH = 8;
typedef bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
typedef bit [I2C_DATA_WIDTH-1:0] i2c_data;
typedef bit [I2C_DATA_WIDTH-1:0] i2c_data_array [$];


// Determines whether a transaction is a write or a read
typedef enum bit { READ, WRITE } wb_op_t;

localparam int WB_ADDR_WIDTH = 2;
localparam int WB_DATA_WIDTH = 8;
typedef bit [WB_ADDR_WIDTH-1:0] wb_addr;
typedef bit [WB_DATA_WIDTH-1:0] wb_data;

// Enumerates the registers contained within the i2cmb
enum wb_addr {
    CSR  = 0, 
    DPR  = 1, 
    CMDR = 2, 
    FSMR = 3
} i2cmb_register;

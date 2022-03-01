`timescale 10us / 1ns

import i2c_pkg::*;

interface i2c_if #(
  int NUM_BUSSES = 1,
  int ADDR_WIDTH = 7,
  int DATA_WIDTH = 8,
  bit [ADDR_WIDTH-1:0] MY_ADDRESS = 0
)( inout triand sda, inout triand scl );
   reg sda_o = 1'b1;   
   reg scl_o = 1'b1;   
   reg sda_i = 1'b1;   
   reg scl_i = 1'b1;   
 
   typedef bit [DATA_WIDTH-1:0] data_array_t[$]; 
   
   assign sda = sda_o;
   assign scl = scl_o;

   always@(sda) sda_i = sda;
   always@(scl) scl_i = scl;

   initial reset_bus();

   // ****************************************************************************
   // RESETS I2C BUS
   // ****************************************************************************
   task reset_bus();
     // set sda and scl to 0
     sda_o <= 1'b1;
     scl_o <= 1'b1;
   endtask

   // ****************************************************************************
   // GENERATES READ DATA
   // ****************************************************************************
   integer read_iter = -1;
   function data_array_t generate_read_data();
     // increment read_iter
     read_iter++;

     // send read data
     if (read_iter < 32) return {100 + read_iter}; // return 100 to 131
     else return {(63 + 32) - read_iter};          // return 63 to 0
   endfunction

   // ****************************************************************************
   // WAITS FOR AND CAPTURES TRANSFER START
   // ****************************************************************************
   task automatic wait_for_i2c_transfer(
      output                      i2c_op_t op,
      output                      data_array_t write_data
   );
     // address of slave
     bit [ADDR_WIDTH-1:0] addr = 0;
     
     // create an iterator to count number of bytes recieved during a read
     integer num_bytes = 0;

     // wait for start command
     forever @(negedge sda_i) if (scl_i) break;
       
     // read address
     foreach (addr[i]) @(posedge scl_i) addr[ADDR_WIDTH-1-i] = sda_i;

     // read operation
     @(posedge scl_i) op = sda_i ?  READ : WRITE;

     // send acknowledge if address matches
     if (addr == MY_ADDRESS) begin 
       @(posedge scl_i) sda_o = 1'b0;
       @(negedge scl_i) sda_o = 1'b1;
     end else $finish;
     
     if (op == READ) return;

     /// collect write data
     forever begin
       bit [DATA_WIDTH-1:0] tmp_data;
       for (integer i = 0; i < DATA_WIDTH; i++)
         @(posedge scl_i) tmp_data[DATA_WIDTH-1-i] = sda_i;
       write_data.push_back(tmp_data);

       /// send ack
       @(posedge scl_i) sda_o = 1'b0;
       @(negedge scl_i) sda_o = 1'b1;

       // increment bytes recieved count 
       num_bytes++;
     end
   endtask

   // ****************************************************************************
   // PROVIDES DATA FOR READ OPERATION
   // ****************************************************************************
   task automatic provide_read_data(
      input      data_array_t read_data,
      output bit transfer_complete
   );

     // send read data to bus
     foreach (read_data[i]) begin
        foreach (read_data[,j]) begin
          sda_o = read_data[i][j];
          @(negedge scl_i);
        end

        // accept ack
        sda_o = 1'b1;
        @(posedge scl_i)
        @(posedge scl_i);

     end
      
     // return transfer_complete
     sda_o = 1'b1;
     transfer_complete = 1;
      
   endtask

   // ****************************************************************************
   // RETURNS DATA OBSERVED
   // ****************************************************************************
   task automatic monitor(
      output bit [ADDR_WIDTH-1:0] addr,
      output                      i2c_op_t op,
      output                      data_array_t data
   );

     // wait for start command
     forever @(negedge sda_i) if (scl_i) break;
     fork

        // handle the stop command
        begin forever @(posedge sda_i) if (scl_i) break; end

        // handle commands
        begin

          integer num_bytes = 0;

          // read address
          foreach (addr[i]) @(posedge scl_i) addr[ADDR_WIDTH-1-i] = sda_i;

          // read operation
          @(posedge scl_i) op = sda_i ?  READ : WRITE;

          // skip acknowledgement
          @(posedge scl_i); @(negedge scl_i);

          /// collect write data
          forever begin
            bit [DATA_WIDTH-1:0] tmp_data;
            for (integer i = 0; i < DATA_WIDTH; i++)
              @(posedge scl_i) tmp_data[DATA_WIDTH-1-i] = sda_i;
            data.push_back(tmp_data);

            /// skip ack
            @(posedge scl_i);
            @(negedge scl_i);

            // increment bytes recieved count 
            num_bytes++;
          end
        end
      join_any
      disable fork;
    endtask
endinterface

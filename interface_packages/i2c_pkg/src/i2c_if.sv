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
   bit NO_STOP = 1'b0;
 
   typedef bit [DATA_WIDTH-1:0] read_array_t[]; 
   
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
   function read_array_t generate_read_data();
     // increment read_iter
     read_iter++;
     // $display("READ_ITER: %d", read_iter);

     // send read data
     if (read_iter < 32) return {100 + read_iter}; // return 100 to 131
     else return {(63 + 32) - read_iter};          // return 63 to 0
   endfunction

   // ****************************************************************************
   // WAITS FOR AND CAPTURES TRANSFER START
   // ****************************************************************************
   task automatic wait_for_i2c_transfer(
      // output                      i2c_op_t op,
      // output bit [DATA_WIDTH-1:0] write_data []
   );

      i2c_op_t op;
      bit [DATA_WIDTH-1:0] write_data [];
     
     // wait for start command
     forever @(negedge sda_i) if (scl_i) break;
     // $display("Slave detected start command");
       
     fork

        // handle the stop command
        begin : handle_stop_command
          forever @(posedge sda_i) if (scl_i) break;
          // $display("Slave detected stop command");
        end

        // handle commands
        begin : handle_commands

          // read address
          bit [ADDR_WIDTH-1:0] slave_address = 0;
          foreach (slave_address[i]) 
            @(posedge scl_i) slave_address[ADDR_WIDTH-1-i] = sda_i;
          // $display("Slave read slave_address: 0x%h", slave_address);

          // read operation
          @(posedge scl_i) op = sda_i ?  READ : WRITE;

          // send acknowledge if address matches
          if (slave_address == MY_ADDRESS) begin 
            @(posedge scl_i) sda_o = 1'b0;
            @(negedge scl_i) sda_o = 1'b1;
          end else $finish;

          // handle operations
          case (op)

            // handle read ooperation
            READ: begin : handle_read_operation
                    // send read data
                    bit transfer_complete = 0;
                    bit [DATA_WIDTH-1:0] read_data[] = generate_read_data();

                    // $display("Slave detected read command");
                    
                    // $display("Read data generated: %b", read_data[0]);

                    provide_read_data(read_data, transfer_complete);

                    // handle transfer failure
                    if (!transfer_complete) begin
                      // $display("Slave failed to send read data");
                      $finish;
                    end
                  end

            // handle write operation
            WRITE: begin : handle_write_operation
                     // create an iterator to count number of bytes recieved
                     integer num_bytes = 0;

                     // $display("Slave detected write command");

                     /// collect write data
                     forever begin
                       for (integer i = 0; i < DATA_WIDTH; i++)
                         @(posedge scl_i) write_data[num_bytes][DATA_WIDTH-1-i] 
                           = sda_i;

                       /// send ack
                       @(posedge scl_i) sda_o = 1'b0;
                       @(negedge scl_i) sda_o = 1'b1;

                       // do something with write
                       // $display("Slave recieved write data: %d", write_data[num_bytes]);

                       // increment bytes recieved count 
                       num_bytes++;
                     end
                   end
         endcase       
       end
     join_any
     disable fork;
   endtask

   // ****************************************************************************
   // PROVIDES DATA FOR READ OPERATION
   // ****************************************************************************
   task automatic provide_read_data(
      input bit [DATA_WIDTH-1:0]  read_data [],
      output bit                  transfer_complete
   );
     NO_STOP = 1'b1;

     // send read data to bus
     foreach (read_data[i]) begin
        foreach (read_data[,j]) begin
          sda_o = read_data[i][j];
          @(negedge scl_i);
          // $display("READ BIT: %b", sda);
        end

        // accept ack
        sda_o = 1'b1;
        @(posedge scl_i) //if (sda == 0) $display("Acknowledged!");
        @(posedge scl_i);

     end
      
     // return transfer_complete
     sda_o = 1'b1;
     transfer_complete = 1;
     NO_STOP = 1'b0;
      
   endtask

   // ****************************************************************************
   // RETURNS DATA OBSERVED
   // ****************************************************************************
   task automatic monitor(
      output bit [ADDR_WIDTH-1:0] addr,
      output                      i2c_op_t op,
      output bit [DATA_WIDTH-1:0] data []
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
          foreach (addr[i]) 
            @(posedge scl_i) addr[ADDR_WIDTH-1-i] = sda_i;

           // read operation
           @(posedge scl_i) op = sda_i ?  READ : WRITE;

           // skip acknowledgement
           @(posedge scl_i); @(negedge scl_i);

           /// collect write data
           forever begin
             for (integer i = 0; i < DATA_WIDTH; i++)
               @(posedge scl_i) data[num_bytes][DATA_WIDTH-1-i] = sda_i;

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

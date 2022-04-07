`timescale 10us / 1ns

import i2c_pkg::*;

interface i2c_if(inout triand sda, inout triand scl);

   reg sda_o = 1'b1;
   reg scl_o = 1'b1;
   reg sda_i = 1'b1;
   reg scl_i = 1'b1;
   
   assign sda = sda_o;
   assign scl = scl_o;

   always@(sda) sda_i = sda;
   always@(scl) scl_i = scl;

   // ****************************************************************************
   // MONITOR I2C BUS
   // ****************************************************************************
   task monitor(
      output i2c_addr addr,
      output i2c_op_t op,
      output i2c_data_array data
   );
      wait_for_start_command();
      read_address(addr);
      read_operation(op);
      skip_acknowledgement();
      watch_write_data(data);
   endtask

   // ****************************************************************************
   // CAPTURES TRANSACTION
   // ****************************************************************************
   task capture_transfer(
      input  i2c_addr  my_addr,
      output i2c_op_t op,
      output i2c_data_array write_data
   );
     automatic i2c_addr addr = 0;
     write_data.delete();
     wait_for_start_command();
     read_address(addr);
     read_operation(op);
     send_acknowledge(addr, my_addr);
     if (op == READ) return;
     collect_write_data(write_data);
   endtask

   // ****************************************************************************
   // PROVIDES DATA FOR READ OPERATION
   // ****************************************************************************
   task provide_read_data(input i2c_data_array read_data);
     // Providing Read Data
     // $display("PROVIDING READ DATA %p", read_data);

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
     sda_o = 1'b1;
   endtask

   // ****************************************************************************
   // TASKS USED IN MONITOR AND CAPTURE METHODS
   // ****************************************************************************
   task watch_write_data(output i2c_data_array data);
      data.delete();
      fork 
         wait_for_stop_command();
         forever begin
            i2c_data tmp_data;
            for (integer i = 0; i < I2C_DATA_WIDTH; i++)
              @(posedge scl_i) tmp_data[I2C_DATA_WIDTH-1-i] = sda_i;
            data.push_back(tmp_data);

            /// skip ack
            @(posedge scl_i);
            @(negedge scl_i);
         end
      join_any disable fork;
   endtask

   task collect_write_data(output i2c_data_array data);
      data.delete();
      fork 
         wait_for_stop_command();
         forever begin
            i2c_data tmp_data;
            for (integer i = 0; i < I2C_DATA_WIDTH; i++)
              @(posedge scl_i) tmp_data[I2C_DATA_WIDTH-1-i] = sda_i;
            data.push_back(tmp_data);

            /// skip ack
            @(posedge scl_i) sda_o = 1'b0;
            @(negedge scl_i) sda_o = 1'b1;
         end
      join_any disable fork;
   endtask

   task skip_acknowledgement;
      @(posedge scl_i) @(negedge scl_i);
   endtask

   task send_acknowledge(input i2c_addr addr, i2c_addr my_addr);
     if (addr == my_addr) begin 
       @(posedge scl_i) sda_o = 1'b0;
       @(negedge scl_i) sda_o = 1'b1;
     end else begin $display("ACK NOT SENT"); $finish; end
   endtask

   task read_operation(output i2c_op_t op_type);
      @(posedge scl_i) op_type = sda_i ?  READ : WRITE;
      // $display("Type = %b", op_type);
   endtask
   
   task read_address(output i2c_addr addr);
      foreach (addr[i]) begin 
         @(posedge scl_i) addr[I2C_ADDR_WIDTH-1-i] = sda_i;
         // $display("A%0d = %b", i, sda_i);
      end
   endtask
   
   task wait_for_start_command;
      forever @(negedge sda) if (scl) break;
   endtask

   task wait_for_stop_command;
      forever @(posedge sda) if (scl) break;
   endtask
endinterface

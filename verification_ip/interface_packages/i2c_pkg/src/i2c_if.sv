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
   task monitor(inout i2c_transaction trans);
      wait_for_start_command();
      read_address(trans.addr);
      read_operation(trans.op);
      skip_ack();
      read_data(trans.data);
      skip_ack();
   endtask

   // ****************************************************************************
   // CAPTURES TRANSACTION
   // ****************************************************************************
   task capture_transfer(inout i2c_transaction trans);
      trans = new;
      wait_for_start_command();
      read_address(trans.addr);
      read_operation(trans.op);
      send_ack();
      if (trans.op == READ) return;
      read_data(trans.data);
      send_ack();
   endtask

   // ****************************************************************************
   // PROVIDES DATA FOR READ OPERATION
   // ****************************************************************************
   task send_read_data(input i2c_data read_data);
     foreach (read_data[i]) begin
        sda_o = read_data[i];
        @(negedge scl_i);
     end
     accept_ack();
   endtask

   // ****************************************************************************
   // TASKS USED IN MONITOR AND CAPTURE METHODS
   // ****************************************************************************
   task read_data(output i2c_data data);
      for (integer i = 0; i < I2C_DATA_WIDTH; i++)
        @(posedge scl_i) data[I2C_DATA_WIDTH-1-i] = sda_i;
   endtask

   task accept_ack();
      sda_o = 1'b1;
      @(posedge scl_i);
      @(negedge scl_i);
   endtask
      
   
   task skip_ack();
      @(posedge scl_i);
      @(negedge scl_i);
   endtask

   task send_ack();
      @(posedge scl_i) sda_o = 1'b0;
      @(negedge scl_i) sda_o = 1'b1;
   endtask

   task read_operation(output i2c_op_t op_type);
      @(posedge scl_i) op_type = sda_i ? READ : WRITE;
   endtask
   
   task read_address(output i2c_addr addr);
      foreach (addr[i]) @(posedge scl_i) addr[i] = sda_i;
   endtask
   
   task wait_for_start_command;
      forever @(negedge sda) if (scl) break;
   endtask

   task wait_for_stop_command;
      forever @(posedge sda) if (scl) break;
   endtask
endinterface

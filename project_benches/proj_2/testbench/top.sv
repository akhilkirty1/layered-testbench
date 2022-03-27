`timescale 1ns / 10ps

import ncsu_pkg::*;
import i2cmb_env_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;

module top();
  
  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;
  parameter int NUM_I2C_BUSSES = 1;
  
  // My Parameters
  parameter int I2C_ADDR_WIDTH = 7;
  parameter int I2C_DATA_WIDTH = 8;
     
  bit  clk;
  bit  rst = 1'b1;
  wire cyc;
  wire stb;
  wire we;
  tri1 ack;
  wire [WB_ADDR_WIDTH-1:0] adr;
  wire [WB_DATA_WIDTH-1:0] dat_wr_o;
  wire [WB_DATA_WIDTH-1:0] dat_rd_i;
  wire irq;
  triand [NUM_I2C_BUSSES-1:0] scl;
  triand [NUM_I2C_BUSSES-1:0] sda;

  // Clock generator
  initial begin : clk_gen
      clk = 1'b0;
      forever #5ns clk <= ~clk;
  end
  
  // Reset generator
  initial begin : rst_gen
     rst = 1'b1;
     #113 rst = ~rst;
  end

  enum bit[1:0] {
      CSR  = 2'b00, 
      DPR  = 2'b01, 
      CMDR = 2'b10, 
      FSMR = 2'b11
  } Registers;

  i2cmb_test tst;
   
  // Define the flow of the simulation
  initial begin : test_flow

     // Place virtual interface handles into ncsu_config_db
     ncsu_config_db#(virtual wb_if)::set("tst.env.p0_agent", p0_bus);
     ncsu_config_db#(virtual i2c_if)::set("tst.env.p1_agent", p1_bus);
     p0_bus.enable_driver = 1'b1;

     // Construct the test class
     tst = new("tst", null);
     
     // Execute the run task of the test after reset is released
     wait (rst == 1);         // Wait until reset is over
     tst.run();               // Run the test

     // Execute $finish after test complete
     #100 $finish();

  end
     
  // starts the i2c slave
  task i2c_slave_start();
   forever begin
     fork 
        // handle the stop command
        begin : handle_stop_command
          forever @(posedge sda) if (scl) break;
        end

        // handle read and write operations
        begin : handle_operations
          // wires required to call wait_for_i2c_transfer 
          i2c_op_t op;
          bit [I2C_DATA_WIDTH-1:0] write_data[];
          
          // wires required to call provide_read_data 
          static bit transfer_complete = 0;
          static bit [I2C_DATA_WIDTH-1:0] read_data[];

          // wait and capture an i2c transfer
          i2c_bus.wait_for_i2c_transfer(op, write_data); 
         
          // generate read data 
          read_data = i2c_bus.generate_read_data();

          // process read data
          i2c_bus.provide_read_data(read_data, transfer_complete);

          // handle transfer failure
          if (!transfer_complete) begin
            $display("Slave failed to send read data");
            $finish;
          end

        end
     join_any
     disable fork;
   end
  endtask

  
  task iicmb_enable();
     // Write byte "1xxxxxxx" to the CSR register 
     // // This sets bit E to '1', enabling the core
     wb_bus.master_write(CSR, 8'b1100_0000);
  endtask
 
  task iicmb_write(
     input bit [WB_ADDR_WIDTH-1:0] bus_id,
     input bit [I2C_ADDR_WIDTH-1:0] slave_addr,
     input bit [I2C_DATA_WIDTH-1:0] write_data
  );

    logic [7:0] tmp_data;
     
     //*****************************************************************
     // SELECT BUS
     //*****************************************************************
     // Write bus_id to the DPR
     wb_bus.master_write(DPR, bus_id);
     
     // Write byte "xxxxx110" to the CMDR
     // This is "Set Bus" command
     wb_bus.master_write(CMDR, 8'b110);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
  
     //*****************************************************************
     // CAPTURE BUS
     //*****************************************************************
     // Write byte "xxxxx100" to the CMDR 
     // This is the "Start" command
     wb_bus.master_write(CMDR, 8'b100);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
     
     //*****************************************************************
     // INITIATE CONTACT WITH SLAVE ON I2C BUS
     //*****************************************************************
     // Write slave address to the DPR 
     // The rightmost bit, 0 means writing
     wb_bus.master_write(DPR, {slave_addr, 1'b0});
     
     // Write byte "xxxxx001" to the CMDR
     // This is the "Write" command
     wb_bus.master_write(CMDR, 8'b001);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
     
     //*****************************************************************
     // SEND WRITE COMMAND TO SLAVE ON I2C BUS
     //*****************************************************************
     // Write byte to the DPR
     wb_bus.master_write(DPR, write_data);
     
     // Write byte "xxxxx001" to the CMDR
     // This is "Write" command
     wb_bus.master_write(CMDR, 8'b001);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
  
     //*****************************************************************
     // FREE SELECTED BUS
     //*****************************************************************
     // Write byte "xxxxx101" to the CMDR. 
     // This is "Stop" command
     wb_bus.master_write(CMDR, 8'b101);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     wait(irq); wb_bus.master_read(CMDR, tmp_data);

  endtask
  
  task iicmb_read(
     input bit [WB_ADDR_WIDTH-1:0] bus_id,
     input bit [I2C_ADDR_WIDTH-1:0] slave_addr,
     output bit [I2C_DATA_WIDTH-1:0] read_data
  );

    logic [7:0] tmp_data;
     
     //*****************************************************************
     // SELECT BUS
     //*****************************************************************
     // Write bus_id to the DPR
     wb_bus.master_write(DPR, bus_id);
     
     // Write byte "xxxxx110" to the CMDR
     // This is "Set Bus" command
     wb_bus.master_write(CMDR, 8'b110);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
  
     //*****************************************************************
     // CAPTURE BUS
     //*****************************************************************
     // Write byte "xxxxx100" to the CMDR 
     // This is the "Start" command
     wb_bus.master_write(CMDR, 8'b100);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
     
     //*****************************************************************
     // INITIATE CONTACT WITH SLAVE ON I2C BUS
     //*****************************************************************
     // Write slave address to the DPR 
     // The rightmost bit, 1 means reading
     wb_bus.master_write(DPR, {slave_addr, 1'b1});
     
     // Write byte "xxxxx001" to the CMDR
     // This is the "Write" command
     wb_bus.master_write(CMDR, 8'b001);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     // If instead of DON the NAK bit is '1', then slave doesn't respond
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
     
     //*****************************************************************
     // SEND READ COMMAND TO SLAVE ON I2C BUS
     //*****************************************************************
     // Write byte "xxxxx010" to the CMDR
     // This is "Read With Ack" command
     wb_bus.master_write(CMDR, 8'b010);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     wait(irq); wb_bus.master_read(CMDR, tmp_data);
    
     // Get returned data 
     wb_bus.master_read(DPR, read_data);
  
     //*****************************************************************
     // FREE SELECTED BUS
     //*****************************************************************
     // Write byte "xxxxx101" to the CMDR. 
     // This is "Stop" command
     wb_bus.master_write(CMDR, 8'b101);
     
     // Wait for interrupt or until DON bit of CMDR reads '1'
     wait(irq); wb_bus.master_read(CMDR, tmp_data);

  endtask
  
  // Instantiate the Wishbone master Bus Functional Model
  wb_if #(
          .ADDR_WIDTH(WB_ADDR_WIDTH),
          .DATA_WIDTH(WB_DATA_WIDTH)
          )
  p0_bus (
    // System sigals
    .clk_i(clk),
    .rst_i(rst),
    // Master signals
    .cyc_o(cyc),
    .stb_o(stb),
    .ack_i(ack),
    .adr_o(adr),
    .we_o(we),
    // Slave signals
    .cyc_i(),
    .stb_i(),
    .ack_o(),
    .adr_i(),
    .we_i(),
    // Shared signals
    .dat_o(dat_wr_o),
    .dat_i(dat_rd_i)
    );
  
  
  // Instantiate the I2C Interface
  i2c_if #(
           .NUM_BUSSES(NUM_I2C_BUSSES),
           .ADDR_WIDTH(I2C_ADDR_WIDTH),
           .DATA_WIDTH(I2C_DATA_WIDTH)
           )
  p1_bus(.scl(scl[0]), .sda(sda[0]));
     
  
  // Instantiate the DUT - I2C Multi-Bus Controller
  \work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
    (
      // -- Wishbone signals:
      .clk_i(clk),  // in    std_logic;       -- Clock
      .rst_i(rst),  // in    std_logic;       -- Synchronous reset (active high)
      // -------------
      .cyc_i(cyc),  // in    std_logic;       -- Valid bus cycle indication
      .stb_i(stb),  // in    std_logic;       -- Slave selection
      .ack_o(ack),  //   out std_logic;       -- Acknowledge output
      .we_i(we),    // in    std_logic;       -- Write enable
     
      .adr_i(adr),  // in    std_logic_vector(1 to 0);  -- Low bits of Wishbone address
      .dat_i(dat_wr_o),    // in    std_logic_vector(7 to 0);  -- Data input
      .dat_o(dat_rd_i),    //   out std_logic_vector(7 to 0);  -- Data output
     
      // -- Interrupt request:
      .irq(irq),    //   out std_logic;       -- Interrupt request
     
      // -- I2C interfaces:
      .scl_i(scl),  // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
      .sda_i(sda),  // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
      .scl_o(scl),  //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
      .sda_o(sda)   //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    );
 
endmodule

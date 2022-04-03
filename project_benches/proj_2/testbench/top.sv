`timescale 1ns / 10ps

import ncsu_pkg::*;
import i2cmb_env_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;

module top();

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
  triand [I2C_NUM_BUSSES-1:0] scl;
  triand [I2C_NUM_BUSSES-1:0] sda;

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

  i2cmb_test tst;
  
  // Instantiate the Wishbone master Bus Functional Model
  wb_if wb_bus (
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
    .dat_i(dat_rd_i),
    .irq_i(irq)
    );
  
  
  // Instantiate the I2C Interface
  i2c_if i2c_bus(.scl(scl[0]), .sda(sda[0]));
     
  
  // Instantiate the DUT - I2C Multi-Bus Controller
  \work.iicmb_m_wb(str) #(.g_bus_num(I2C_NUM_BUSSES)) DUT
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
   
  // Define the flow of the simulation
  initial begin : test_flow

     // Place virtual interface handles into ncsu_config_db
     ncsu_config_db#(virtual wb_if)::set("p0_agent", wb_bus);
     ncsu_config_db#(virtual i2c_if)::set("p1_agent", i2c_bus);

     // Construct the test class
     tst = new("tst");
     
     // Execute the run task of the test after reset is released
     wait (rst == 1);         // Wait until reset is over
     tst.run();               // Run the test

     // Execute $finish after test complete
     #100 $finish();

  end
endmodule

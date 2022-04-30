`timescale 10us / 1ns
class i2cmb_test extends ncsu_component;
   
   i2cmb_environment env;
   i2cmb_generator   gen;
   i2cmb_env_configuration cfg;
   string test_type;

   //******************************************************
   // CONSTRUCTOR
   //******************************************************
   function new(string name = "");

      // Call the constructor of the parent class
      super.new(name, this);

      // Obtain the test type from command line argument
      if (!$value$plusargs("TEST_TYPE=%s", test_type))
         $fatal(1, "+TEST_TYPE plusarg not found on command line");
      $display("%m found +TEST_TYPE=%s", test_type);

      // Initiates and construct environment configuration
      cfg = new("cfg", this);

      // Initiates and construct environment
      env = new("env", this);
      env.set_configuration(cfg);
      env.build();

      // Initiates and construct generator
      gen = new("gen", this);
      gen.set_p0_agent(env.get_p0_agent());
      gen.set_p1_agent(env.get_p1_agent());
      gen.set_configuration(cfg);

      // Tell environment about generator
      env.set_generator(gen);
   endfunction

   //******************************************************
   // RUN ENVIRONMENT, GENERATOR, AND TESTS
   //******************************************************
   virtual task run();

      // Run Environment and Generator
      env.run();
      gen.run();
      
      // Enable i2cmb
      gen.enable();

      // Wait for i2cmb to settle after enable
      #3us;
      
      // Run Tests
      case (test_type)
         "i2c_write_test":      i2c_write_test();
         "i2c_read_test":       i2c_read_test();
         "i2c_random_test":     i2c_random_test();
         "i2c_rep_start_test":  i2c_rep_start_test();
         "reg_reset_test":      reg_reset_test();
         "reg_access_test":     reg_access_test();
         "clock_sync_test":     clock_sync_test();
         "arbitration_test":    arbitration_test();
         "wait_test":           wait_test();
         "clock_stretch_test":  clock_stretch_test();
         default: $fatal(1, "Unknown Test Type");
      endcase
      $display("");
      $display("Test Finished Successfully");
      $display("");
   endtask

   //***********************************************************
   // I2C WRITE TEST
   //***********************************************************
   // Test i2c write functionality
   task i2c_write_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#                   I2C Write Test                  ");
      $display("#===================================================");
      $display("#===================================================");

      for(int i = 1; i <= 100; i++) begin
         $display("");
         $display("Write %3d/100", i);
         gen.write();
      end
   endtask
   
   //***********************************************************
   // I2C READ TEST
   //***********************************************************
   // Test i2c read functionality
   task i2c_read_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#                   I2C Read Test                   ");
      $display("#===================================================");
      $display("#===================================================");

      for(int i = 1; i <= 100; i++) begin
         $display("");
         $display("Read %3d/100", i);
         gen.read();
      end
   endtask
   
   //***********************************************************
   // I2C REP START TEST
   //***********************************************************
   // Test i2c repeated start functionality
   task i2c_rep_start_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#              I2C Repeated Start Test              ");
      $display("#===================================================");
      $display("#===================================================");

      // Tell the system to not use the stop command
      cfg.dont_stop = 1'b1;
      
      // Send and verify 10,000 random i2c transactions
      // using the wb interface
      for (int i = 1; i <= 100; i++) begin
         // Choose a random i2c operation to test
         i2c_op_t rand_op = i2c_op_t'($urandom_range(0, 1));

         // Send i2c command
         $display("");
         $display("Transaction %3d/100", i);
         case (rand_op)
            i2c_pkg::READ:  gen.read();
            i2c_pkg::WRITE: gen.write();
         endcase
         $display("");
      end
   endtask

   //***********************************************************
   // RANDOM TEST
   //***********************************************************
   task i2c_random_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#                   I2C Random Test                 ");
      $display("#===================================================");
      $display("#===================================================");
      
      // Send and verify 10,000 random i2c transactions
      // using the wb interface
      for (int i = 1; i <= 100; i++) begin
         // Choose a random i2c operation to test
         i2c_op_t rand_op = i2c_op_t'($urandom_range(0, 1));

         // Send i2c command
         $display("");
         $display("Transaction %3d/100", i);
         case (rand_op)
            i2c_pkg::READ:  gen.read();
            i2c_pkg::WRITE: gen.write();
         endcase
         $display("");
      end
   endtask

   //***********************************************************
   // REG RESET TEST
   //***********************************************************
   // Test the reset values of I2CMB registers
   task reg_reset_test();

      // Declarations
      i2cmb_reg curr_reg;
      wb_data pred_val;
      wb_data acc_val;

      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#            Running Register Reset Test            ");
      $display("#===================================================");
      $display("#===================================================");

      // Loop through registers and verify that each is correct
      curr_reg = curr_reg.first;
      do begin

         // Send a command to read the register
         wb_data data = 0;
         gen.p0_agent.bl_create_put(curr_reg, wb_pkg::READ, data);
        
         // Log which register is being tested
         $display("");
         $display("Testing %s...", curr_reg.name);

         // Get predicted and actual values
         pred_val = env.pred.read_reg(curr_reg);
         acc_val  = gen.p0_agent.monitor.monitored_read_data;
         
         // Log predicted and actual values
         $display("Expected: %b", pred_val);
         $display("Actual:   %b", acc_val);
         
         // Verify that predicted register values are equal to actual values 
         reg_reset_assert: 
            assert (acc_val == pred_val)
            else $fatal(1, "%s was incorrectly reset", curr_reg.name);
         $display("%s was correctly reset", curr_reg.name);
         $display("");

         // Advance to next register
         curr_reg = curr_reg.next;
         
      end
      while (curr_reg != curr_reg.first);
   endtask

   //***********************************************************
   // REG ACCESS TEST
   //***********************************************************
   // Test the access permissions of I2CMB registers
   task reg_access_test();

      // Declarations
      i2cmb_reg curr_reg;
      wb_data pred_val1;
      wb_data acc_val1;
      wb_data pred_val0;
      wb_data acc_val0;

      // Dont wait for command completion
      cfg.wb_config.wait_for_comp = 1'b0;
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#            Running Register Access Test           ");
      $display("#===================================================");
      $display("#===================================================");

      // Loop through all registers
      // Check access for each 
      curr_reg = curr_reg.first;
      do begin

         // Reenable I2CMB
         gen.enable();
         
         // Log which register is being tested
         $display("");
         $display("Testing %s...", curr_reg.name);
         
         // Write all ones to register
         gen.write_reg(curr_reg, 8'b1111_1111);
         
         // Get predicted and actual values
         pred_val1 = env.pred.read_reg(curr_reg);
         acc_val1  = gen.p0_agent.monitor.monitored_read_data;
         
         // Log predicted and actual values
         $display("Expected: %b", pred_val1);
         $display("Actual:   %b", acc_val1);
         
         // Write all zeros to register
         gen.write_reg(curr_reg, 8'b0000_0000);
         
         // Get predicted and actual values
         pred_val0 = env.pred.read_reg(curr_reg);
         acc_val0  = gen.p0_agent.monitor.monitored_read_data;
         
         // Log predicted and actual values
         $display("Expected: %b", pred_val0);
         $display("Actual:   %b", acc_val0);
         
         // Verify that predicted register values are equal to actual values 
         reg_access_assert: 
            assert ((acc_val1 == pred_val1) && (acc_val0 == pred_val0))
            else $fatal(1, "%s has incorrect access", curr_reg.name);
         $display("%s has correct access", curr_reg.name);
         $display("");
         
         // Advance to next register
         curr_reg = curr_reg.next;
         
      end
      while (curr_reg != curr_reg.first);
   endtask

   // Test the system clock speed at multiple speeds
   task system_clock_speed_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#               System Clock Speed Test             ");
      $display("#===================================================");
      $display("#===================================================");
      
      // Instantiate 16 IICMB with different clock speeds
      // 1MHz,   5MHz,   10MHz,  25MHz, 50MHz, 100MHz, 200MHz, 300MHz
      // 400MHz, 500MHz, 

      // Make sure that each set clock speed is obeyed
      // fork forever @(clk_s)

      // Wait for ten clock cycles of the clock with the longest period
      
   endtask
      
   // Test that the master can communicate over multiple busses
   task multi_bus_test();
      
      // Get the driver
      i2c_driver driver = gen.p1_agent.driver;
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#               Running Multi-Bus Test              ");
      $display("#===================================================");
      $display("#===================================================");
      
      // Instantiate 16 i2c_busses with different clock speeds
      // 1MHz,   5MHz,   10MHz,  25MHz, 50MHz, 100MHz, 200MHz, 300MHz
      // 400MHz, 500MHz, 

      // Make sure that each set clock speed is obeyed
      // for (int i = 0; i < 16; i++)
      //   fork forever @(driver.bus.scl[i]) 
      //      assert (driver.bus.scl[i] == driver.bus.scl_o[i]);
      //   join_none

      // For each bus, send 10 writes and 10 reads
      // repeat(10) gen.read(32);

   endtask
   
   //***********************************************************
   // CLOCK SYNC TEST
   //***********************************************************
   // Test Multi-Master Clock Synchronization
   task clock_sync_test();

      // Get the driver
      i2c_driver driver = gen.p1_agent.driver;
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#        Running Clock Synchronization Test         ");
      $display("#===================================================");
      $display("#===================================================");

      // Disable the scoreboard
      cfg.scbd_enable = 1'b0;
      
      fork
         // Tell I2CMB to wait 100 ms
         // gen.wait_cmd(100);
         gen.read();

         // Drive scl with a second clock
         begin
            // Wait for scl to go high
            @(posedge driver.bus.scl);
            
            // Delay second clock
            #2us driver.bus.scl_o = 1'b0;
            
            // Drive second clock
            forever #5us driver.bus.scl_o++;
         end
         
         // Watch SCL and make sure that second clock is followed
         @(posedge driver.bus.scl) #5us forever @(driver.bus.scl) begin
            assert (driver.bus.scl == driver.bus.scl_o)
            else $fatal(1, "Test Failed");
            $display("Clock is Synced");
         end
      join_any disable fork;
   endtask
   
   //***********************************************************
   // WAIT TEST
   //***********************************************************
   task wait_test();
      
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#             Running Wait Command Test             ");
      $display("#===================================================");
      $display("#===================================================");

      // Disable scoreboard
      cfg.scbd_enable = 1'b0;

      // Don't wait for commmand completion
      cfg.wb_config.wait_for_comp = 1'b0;
      
      // Test the wait command with different time values
      for (int i = 1; i <= 5; i++) begin
         
         // Declarations
         longint start_time;
         longint end_time;
         wb_data tmp_data;
         wb_data pred_time;
         wb_data acc_time;

         $display("");
         $display("Test %1d/5", i);
         
         // Generate a random amount of time to wait
         pred_time = $urandom_range(0, 999);
         $display("Predicted Time %3dms", pred_time);
         
         // Get current time
         start_time = $time / 100_000_000;
         
         // Run the wait command
         gen.wait_cmd(pred_time);

         // Get current time
         end_time = $time / 100_000_000;
         
         // Calculate the duration of the wait command
         acc_time = end_time - start_time;
         $display("Actual Time    %3dms", acc_time);

         // Read cmdr to clear irq
         gen.read_reg(CMDR, tmp_data);

         // Verify that the time is as expected
         assert (pred_time == acc_time)
         else $fatal(1, "FAILURE\n");
         $display("SUCCESS\n");
         
      end
   endtask
   
   //***********************************************************
   // ARBITRATION TEST
   //***********************************************************
   task arbitration_test();
      
      // Announce that we should lose arbitration
      cfg.wb_config.lose_arbitration = 1'b1;
            
      // Disable scoreboard
      cfg.scbd_enable = 1'b0;

      // Test multi-master arbitration on the write command
      begin : lose_arb_on_write
            
         $display("");
         $display("Testing Write Command");
         
         // Capture bus
         gen.set_bus();
         gen.capture_bus();
         
         // Hold sda down before the I2CMB can
         gen.p1_agent.driver.bus.sda_o = 1'b0;

         // Send write
         gen.initiate_write();
         
         // Relieve sda
         gen.p1_agent.driver.bus.sda_o = 1'b1;
         
         $display("SUCCESS");
         $display("");
         
      end
      
      // Test multi-master arbitration on the read command
      begin : lose_arb_on_read
         
         $display("");
         $display("Testing Read Command");
            
         // Capture bus
         gen.set_bus();
         gen.capture_bus();
         
         // Hold sda down before the I2CMB can
         gen.p1_agent.driver.bus.sda_o = 1'b0;

         // Send read
         gen.initiate_read();

         // Relieve sda
         gen.p1_agent.driver.bus.sda_o = 1'b1;
         
         $display("SUCCESS");
         $display("");
         
      end
   endtask
   
   //***********************************************************
   // CLOCK STRETCH TEST
   //***********************************************************
   task clock_stretch_test();
      // Tell the I2C driver to stretch the clock
      cfg.i2c_config.stretch = 1'b1;

      // Send 50 writes to test clock stretching
      for (int i = 1; i <= 50; i++) begin
         $display("");
         $display("Test %2d/50", i);
         gen.read();
         $display("SUCCESS");
         $display("");
      end
      
   endtask
endclass

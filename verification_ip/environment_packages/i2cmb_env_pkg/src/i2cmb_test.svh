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
      if (!$value$plusargs("TEST_TYPE=%s", test_type)) begin
         $display("FATAL: +TEST_TYPE plusarg not found on command line");
         $fatal;
      end
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

      // Run Tests
      case (test_type)
         "i2c_test":            i2c_test();
         "i2c_rep_start_test":  i2c_rep_start_test();
         "reg_reset_test":      reg_reset_test();
         "reg_access_test":     reg_access_test();
         "clock_sync_test":     clock_sync_test();
         default: begin
            $display("FATAL: Unknown Test Type");
            $fatal;
         end
      endcase
      $display("");
      $display("Test Finished Successfully");
      $display("");
   endtask

   //***********************************************************
   // I2C REP START TEST
   //***********************************************************
   // Test basic i2c functionality using repeated starts
   task i2c_rep_start_test();

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
   task i2c_test();
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
         assert (acc_val == pred_val)
         else $error("%s was incorrectly reset", curr_reg.name);
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
         for (int i = 0; i <= 1; i++) begin
            wb_data acc_val;
            gen.write_reg(curr_reg, i * 8'b1111_1111);
            acc_val = env.pred.read_reg(curr_reg);
            assert_reg_access: assert (acc_val == i);
            curr_reg = curr_reg.next;
         end
      end
      while (curr_reg != curr_reg.first);
   endtask

   //***********************************************************
   // CLOCK SYNC TEST
   //***********************************************************
   // Test Multi-Master Clock Synchronization
   task clock_sync_test();
      $display("");
      $display("#===================================================");
      $display("#===================================================");
      $display("#        Running Clock Synchronization Test         ");
      $display("#===================================================");
      $display("#===================================================");
      
      // Generate a random clock period
      //delay=$urandom_range(0,1000);

      // Generate a second clock

      // Drive SCL with second clock (Slower than Default)

      // Watch SDA and make sure that second clock is followed
   endtask
endclass

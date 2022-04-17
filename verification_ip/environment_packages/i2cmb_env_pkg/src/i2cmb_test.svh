`timescale 10us / 1ns
class i2cmb_test extends ncsu_component;
   
   string test_type;

   i2cmb_env_configuration    cfg;
   i2cmb_environment          env;
   i2cmb_generator            gen;

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
      cfg.sample_coverage();

      // Initiates and construct environment
      env = new("env", this);
      env.set_configuration(cfg);
      env.build();

      // Initiates and construct generator
      gen = new("gen");
      gen.set_p0_agent(env.get_p0_agent());
      gen.set_p1_agent(env.get_p1_agent());
      gen.set_configuration(cfg);
   endfunction

   // Runs environment and generator
   virtual task run();
      env.run();
      gen.run();
      
      // Enable i2cmb
      gen.enable();

      case (test_type)
         "i2c_test":            i2c_test();
         "i2c_rep_start_test":  i2c_rep_start_test();
         "i2c_random_test":     i2c_random_test();
         "reg_reset_test":      reg_reset_test();
         "reg_access_test":     reg_access_test();
         "clock_sync_test":     clock_sync_test();
         default: begin
            $display("FATAL: Unknown Test Type");
            $fatal;
         end
      endcase
   endtask

   /************************************************************
   /*                        I2C TEST
   /************************************************************/
   // Test basic i2c functionality
   task i2c_test;
      // Run the write test
      #1000 write_test();
      
      // Run the read with ack test
      #1000 read_with_ack_test();
      
      // Run the read with nack test
      //#1000 read_with_nack_test();
      
      // Run the read/write test
      #1000 read_write_test();
   endtask
   
   // Write 32 incrementing values, from 0 to 31, to the i2c_bus
   task write_test;
    if (cfg.log_tests) begin
       $display("");
       $display("#===================================================");
       $display("#===================================================");
       $display("#                 Running Write Test                ");
       $display("#===================================================");
       $display("#===================================================");
    end

    for (i2c_data data = 0; data < 32; data++) begin
      if (cfg.log_sub_tests) begin
         $display("");
         $display("#---------------------------------------------------");
         $display("#                 Writing 0x%2x                     ", data);
         $display("#---------------------------------------------------");
      end
      gen.write(0, 0, data);
    end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_ack_test;
      if (cfg.log_tests) begin
         $display("");
         $display("#===================================================");
         $display("#===================================================");
         $display("#                 Running Read Test                 ");
         $display("#===================================================");
         $display("#===================================================");
      end

      for (integer i = 100; i < 132; i++) begin 
         if (cfg.log_sub_tests) begin
            $display("");
            $display("#---------------------------------------------------");
            $display("#                     Reading %0d                   ", i);
            $display("#---------------------------------------------------");
         end
         env.pred.prediction_data.push_back('{i});
         //gen.provide_data.push_back('{i});
         gen.read(0, 0);
      end
   endtask
   
   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_nack_test;
      if (cfg.log_tests) begin
         $display("");
         $display("#===================================================");
         $display("#===================================================");
         $display("#                 Running Read Test                 ");
         $display("#===================================================");
         $display("#===================================================");
      end

      for (integer i = 100; i < 132; i++) begin 
         if (cfg.log_sub_tests) begin
            $display("");
            $display("#---------------------------------------------------");
            $display("#                     Reading %0d                   ", i);
            $display("#---------------------------------------------------");
         end
         env.pred.prediction_data.push_back('{i});
         //gen.provide_data.push_back('{i});
         gen.read(0, 0);
      end
   endtask

   // Alternate writes and reads for 64 transfers 
   //     Write data from 64 to 127
   //     Read data from 63 to 0
   task read_write_test;
       if (cfg.log_tests) begin
          $display("");
          $display("#===================================================");
          $display("#===================================================");
          $display("#              Running Read/Write Test              ");
          $display("#===================================================");
          $display("#===================================================");
       end

       // Write data from 64 to 127
       for (integer i = 0; i < 64; i++) begin
          if (cfg.log_sub_tests) begin
             $display("");
             $display("#---------------------------------------------------");
             $display("#                 Writing 0x%2x                     ", 64 + i);
             $display("#---------------------------------------------------");
          end
          gen.write(0, 0, 64 + i);

          // Read data from 63 to 0
          if (cfg.log_sub_tests) begin
             $display("");
             $display("#---------------------------------------------------");
             $display("#                     Reading %0d                    ", 63 - i);
             $display("#---------------------------------------------------");
          end
          env.pred.prediction_data.push_back('{63 - i});
          //gen.provide_data.push_back('{63 - i});
          gen.read(0, 0);
       end
   endtask

   /************************************************************
   /*                   I2C REP START TEST
   /************************************************************/
   // Test basic i2c functionality using repeated starts
   task i2c_rep_start_test;
      // Run the write test
      #1000 write_test_rep_start();
      
      // Run the read with ack test
      #1000 read_with_ack_test_rep_start();
      
      // Run the read with nack test
      //#1000 read_with_nack_test_rep_start();
   endtask

   // Write 32 incrementing values, from 0 to 31, to the i2c_bus
   task write_test_rep_start;
    if (cfg.log_tests) begin
       $display("");
       $display("#===================================================");
       $display("#===================================================");
       $display("#                 Running Write Test                ");
       $display("#===================================================");
       $display("#===================================================");
    end

    for (i2c_data data = 0; data < 32; data++) begin
      if (cfg.log_sub_tests) begin
         $display("");
         $display("#---------------------------------------------------");
         $display("#                 Writing 0x%2x                     ", data);
         $display("#---------------------------------------------------");
      end
      gen.write(0, 0, data);
    end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_ack_test_rep_start;
      i2c_data_array data;
      for (integer i = 100; i < 132; i++) data.push_back(i);
      if (cfg.log_tests) begin
         $display("");
         $display("#===================================================");
         $display("#===================================================");
         $display("#                 Running Read Test                 ");
         $display("#===================================================");
         $display("#===================================================");
      end

      env.pred.prediction_data.push_back(data);
      //gen.provide_data.push_back(data);

      if (cfg.log_sub_tests) begin
         $display("");
         $display("#---------------------------------------------------");
         $display("#              Reading 100 to 131                   ");
         $display("#---------------------------------------------------");
      end

      gen.read(0, 0);
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_nack_test_rep_start;
      i2c_data_array data;
      for (integer i = 100; i < 132; i++) data.push_back(i);
      if (cfg.log_tests) begin
         $display("");
         $display("#===================================================");
         $display("#===================================================");
         $display("#                 Running Read Test                 ");
         $display("#===================================================");
         $display("#===================================================");
      end

      env.pred.prediction_data.push_back(data);
      //gen.provide_data.push_back(data);

      if (cfg.log_sub_tests) begin
         $display("");
         $display("#---------------------------------------------------");
         $display("#              Reading 100 to 131                   ");
         $display("#---------------------------------------------------");
      end

      gen.read(0, 0);
   endtask

   /************************************************************
   /*                        RANDOM TEST
   /************************************************************/
   task i2c_random_test;
      $display("#===================================================");
      $display("#===================================================");
      $display("#                 Running Random Test               ");
      $display("#===================================================");
      $display("#===================================================");
   endtask

   /************************************************************
   /*                     REG RESET TEST
   /************************************************************/
   // Test the reset values of I2CMB registers
   task reg_reset_test;
      $display("#===================================================");
      $display("#===================================================");
      $display("#            Running Register Reset Test            ");
      $display("#===================================================");
      $display("#===================================================");
   endtask

   /************************************************************
   /*                     REG ACCESS TEST
   /************************************************************/
   // Test the access permissions of I2CMB registers
   task reg_access_test;
      $display("#===================================================");
      $display("#===================================================");
      $display("#            Running Register Access Test           ");
      $display("#===================================================");
      $display("#===================================================");
   endtask

   /************************************************************
   /*                     CLOCK SYNC TEST
   /************************************************************/
   // Test Multi-Master Clock Synchronization
   task clock_sync_test;
      $display("#===================================================");
      $display("#===================================================");
      $display("#        Running Clock Synchronization Test         ");
      $display("#===================================================");
      $display("#===================================================");
   endtask
endclass

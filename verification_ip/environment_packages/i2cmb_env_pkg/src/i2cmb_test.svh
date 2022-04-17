`timescale 10us / 1ns
class i2cmb_test extends ncsu_component;
   
   i2cmb_env_configuration    cfg;
   i2cmb_environment          env;
   i2cmb_generator            gen;

   function new(string name = "");
      // Call base class constructor
      super.new(name);

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

      // Run the write test
      #1000 write_test(0, 0);

      // Run the read with ack test
      #1000 read_with_ack_test(0, 0);

      // Run the read with nack test
      //#1000 read_with_nack_test(0, 0);

      // Run the read/write test
      #1000 read_write_test(0, 0);
   endtask

   // Test the reset values of I2CMB registers
   task reg_reset_test;
   endtask

   // Test the access permissions of I2CMB registers
   task reg_access_test;
   endtask

   // Test Multi-Master Clock Synchronization

   // Write 32 incrementing values, from 0 to 31, to the i2c_bus
   task write_test(
      input wb_addr  bus_id,
      input i2c_addr slave_addr
   );
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
      gen.write(bus_id, slave_addr, data);
    end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_ack_test(
      input wb_addr bus_id,
      input i2c_addr slave_addr
   );
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
         gen.read(bus_id, slave_addr);
      end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_nack_test(
      input wb_addr bus_id,
      input i2c_addr slave_addr
   );
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
         gen.read(bus_id, slave_addr);
      end
   endtask

   // Alternate writes and reads for 64 transfers 
   //     Write data from 64 to 127
   //     Read data from 63 to 0
   task read_write_test(
      input wb_addr  bus_id,
      input i2c_addr slave_addr
   );
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
          gen.write(bus_id, slave_addr, 64 + i);

          // Read data from 63 to 0
          if (cfg.log_sub_tests) begin
             $display("");
             $display("#---------------------------------------------------");
             $display("#                     Reading %0d                    ", 63 - i);
             $display("#---------------------------------------------------");
          end
          env.pred.prediction_data.push_back('{63 - i});
          //gen.provide_data.push_back('{63 - i});
          gen.read(bus_id, slave_addr);
       end
   endtask

   // Write 32 incrementing values, from 0 to 31, to the i2c_bus
   task write_test_rep_start(
      input wb_addr  bus_id,
      input i2c_addr slave_addr
   );
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
      gen.write(bus_id, slave_addr, data);
    end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_ack_test_rep_start(
      input wb_addr bus_id,
      input i2c_addr slave_addr
   );
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

      gen.read(bus_id, slave_addr);
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_with_nack_test_rep_start(
      input wb_addr bus_id,
      input i2c_addr slave_addr
   );
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

      gen.read(bus_id, slave_addr);
   endtask
endclass

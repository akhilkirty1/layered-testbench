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
   endfunction

   // Runs environment and generator
   virtual task run();
      env.run();
      gen.run();

      // Enable i2cmb
      $display("");
      $display("#----------------------------");
      $display("# Enabling I2CMB");
      $display("#----------------------------");
      gen.enable();
      $display("");

      // Run the write test
      $display("#----------------------------");
      $display("# Running Write Test");
      $display("#----------------------------");
      #1000 write_test(0, 0);

      // Run the read test
      $display("#----------------------------");
      $display("# Running Read Test");
      $display("#----------------------------");
      #1000 read_test(0, 0);

      // Run the read/write test
      $display("#----------------------------");
      $display("# Running Write/Read Test");
      $display("#----------------------------");
      #1000 read_write_test(0, 0);
   endtask

   task write_test(
      input wb_addr  bus_id,
      input i2c_addr slave_addr
   );
    // Write 32 incrementing values, from 0 to 31, to the i2c_bus
    for (i2c_data data = 0; data < 32; data++) begin
      $display("Writing %x", data);
      gen.write(bus_id, slave_addr, data);
      $display("");
    end
   endtask

   // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
   task read_test(
      input wb_addr bus_id,
      input i2c_addr slave_addr
   );
      repeat(32) begin 
         $display("Reading");
         gen.read(bus_id, slave_addr);
         $display("");
      end
   endtask

   // Alternate writes and reads for 64 transfers 
   //     Write data from 64 to 127
   //     Read data from 63 to 0
   task read_write_test(
      input wb_addr  bus_id,
      input i2c_addr slave_addr
   );
    for (integer i = 0; i < 64; i++) begin
      gen.write(bus_id, slave_addr, 64 + i);
      gen.read(bus_id, slave_addr);
      $display("");
    end
   endtask
endclass

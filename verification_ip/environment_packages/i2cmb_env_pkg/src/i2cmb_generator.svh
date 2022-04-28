class i2cmb_generator extends ncsu_component;
   
   wb_agent  p0_agent;
   i2c_agent p1_agent;
   i2cmb_env_configuration cfg;
   i2c_data_array provide_data;

   //*****************************************************************
   // CONSTRUCTOR
   //*****************************************************************
   function new(string name="", ncsu_component parent=null); 
      super.new(name, this);
   endfunction

   //*****************************************************************
   // SET CONFIRURATION
   //*****************************************************************
   function void set_configuration(i2cmb_env_configuration conf);
      this.cfg = conf;
   endfunction

   //*****************************************************************
   // SET P0 AGENT
   //*****************************************************************
   function void set_p0_agent(wb_agent agent);
      p0_agent = agent;
   endfunction

   //*****************************************************************
   // SET P1 AGENT
   //*****************************************************************
   function void set_p1_agent(i2c_agent agent);
      p1_agent = agent;
   endfunction

   //*****************************************************************
   // RUN GENERATOR
   //*****************************************************************
   virtual task run();
      fork
        // Start I2C Driver
        forever begin
            // Wait for I2C Transfer
            i2c_transaction trans;
            p1_agent.bl_put(trans);
        end
      join_none
   endtask

   //*****************************************************************
   // ENABLE I2CMB
   //*****************************************************************
   task enable();
      wb_data data;
      if (cfg.log_tests) begin
         $display("");
         $display("#===================================================");
         $display("#===================================================");
         $display("#                   Enabling I2CMB                  ");
         $display("#===================================================");
         $display("#===================================================");
      end
      data = {1'b1, cfg.enable_irq, 6'b0};
      p0_agent.bl_create_put(CSR, wb_pkg::WRITE, data);
   endtask
   
   //*****************************************************************
   // READ A I2CMB REGISTER
   //*****************************************************************
   task read_reg(input i2cmb_reg reg_to_read, output wb_data reg_value);
      p0_agent.bl_create_put(reg_to_read, wb_pkg::READ, reg_value);
   endtask

   //*****************************************************************
   // WRITE A I2CMB REGISTER
   //*****************************************************************
   task write_reg(input i2cmb_reg reg_to_write, input wb_data data);
      p0_agent.bl_create_put(reg_to_write, wb_pkg::WRITE, data);
   endtask

   //*****************************************************************
   // WRITE TO A SLAVE ON I2C BUS
   //*****************************************************************
   task write();
      set_bus();
      capture_bus();
      initiate_write(); 
      send_write();
      free_bus();
   endtask

   //*****************************************************************
   // READ FROM A SLAVE ON I2C BUS
   //*****************************************************************
   task read();
      // Use random read data
      int num_bytes = $urandom_range(1, 5);
      for (int i = 0; i < num_bytes; i++) begin
         i2c_data data = $urandom();
         provide_data.push_back(data);
      end

      set_bus();
      capture_bus();
      initiate_read();
      send_read();
      free_bus();
   endtask

   //*****************************************************************
   // SET BUS
   //*****************************************************************
   task set_bus();

      // Use a random bus id
      wb_data bus_id = $urandom_range(I2C_NUM_BUSSES-1);

      if (cfg.log_commands) $display("#### Setting the Bus");

      // Write bus_id to the DPR
      if (cfg.log_commands) $display("# Writing busid to dpr");
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, bus_id);
   
      // Write byte "xxxxx110" to the CMDR
      // This is "Set Bus" command
      if (cfg.log_commands) $display("# Running set bus command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b110);
   endtask

   //*****************************************************************
   // CAPTURE BUS
   //*****************************************************************
   task capture_bus();
      if (cfg.log_commands) $display("### Capturing Bus");

      // Write byte "xxxxx100" to the CMDR 
      // This is the "Start" command
      if (cfg.log_commands) $display("# Running start command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b100);
   endtask

   //*****************************************************************
   // INITIATE WRITE WITH SLAVE ON I2C BUS
   //*****************************************************************
   task initiate_write();

      // Use a random slave address
      i2c_addr slave_addr = $urandom();

      if (cfg.log_commands) $display("### Contacting Slave");

      // Write slave address to the DPR 
      // The rightmost bit, 0 means writing
      if (cfg.log_commands) $display("# Writing slave address to dpr");
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, {slave_addr, 1'b0});
      
      // Write byte "xxxxx001" to the CMDR
      // This is the "Write" command
      if (cfg.log_commands) $display("# Running write command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b001);
   endtask

   //*****************************************************************
   // INITIATE READ WITH SLAVE ON I2C BUS
   //*****************************************************************
   task initiate_read();

      // Use a random slave address
      i2c_addr slave_addr = $urandom();

      if (cfg.log_commands) $display("### Contacting Slave");

      // Write slave address to the DPR 
      // The rightmost bit, 1 means writing
      if (cfg.log_commands) $display("# Writing slave address to dpr");
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, {slave_addr, 1'b1});
      
      // Write byte "xxxxx001" to the CMDR
      // This is the "Write" command
      if (cfg.log_commands) $display("# Running write command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b001);
   endtask

   //*****************************************************************
   // SEND WRITE COMMAND TO SLAVE ON I2C BUS
   //*****************************************************************
   task send_write();

      // Use random write data
      wb_data write_data = $urandom();

      // Log if necessary
      if (cfg.log_commands) $display("### Sending Write");

      // Write byte to the DPR
      if (cfg.log_commands) $display("# Writing data to dpr");
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, write_data);
      
      // Write byte "xxxxx001" to the CMDR
      // This is "Write" command
      if (cfg.log_commands) $display("# Running write command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b001);
   endtask

   //*****************************************************************
   // SEND READ COMMAND TO SLAVE ON I2C BUS
   //*****************************************************************
   task send_read();
      if (cfg.log_commands) $display("### Sending Read");

      // Write byte "xxxxx010" to the CMDR
      // This is "Read With Ack" command
      if (cfg.log_commands) $display("# Running read command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b010);
   endtask

   //*****************************************************************
   // FREE SELECTED BUS
   //*****************************************************************
   task free_bus();
      if (cfg.log_commands) $display("### Freeing Bus");

      // Write byte "xxxxx101" to the CMDR. 
      // This is "Stop" command
      if (cfg.log_commands) $display("# Running stop command");
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b101);
   endtask
endclass

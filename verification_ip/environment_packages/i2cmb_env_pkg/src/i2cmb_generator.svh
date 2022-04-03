class i2cmb_generator extends ncsu_component;
   wb_agent  p0_agent;
   i2c_agent p1_agent;

   function new(string name="", ncsu_component parent=null); 
      super.new(name, this);
   endfunction

   function void set_p0_agent(wb_agent agent);
      p0_agent = agent;
   endfunction

   function void set_p1_agent(i2c_agent agent);
      p1_agent = agent;
   endfunction

   virtual task run();
      fork run_i2c(); join_none
      run_wb();
   endtask

   task run_wb();
   endtask

   // ****************************************************************
   // RUN I2C GENERATION
   // ****************************************************************
   task run_i2c();
      forever begin
         // Wait for I2C Transfer
         i2c_transaction trans;
         p1_agent.bl_put(trans);
      end
   endtask

   //*****************************************************************
   // ENABLE I2CMB
   //*****************************************************************
   task enable;
      p0_agent.bl_create_put(CSR, wb_pkg::WRITE, 8'b1100_0000);
   endtask

   //*****************************************************************
   // WRITE TO A SLAVE ON I2C BUS
   //*****************************************************************
   task write(
      input wb_addr bus_id,
      input i2c_addr slave_addr,
      input i2c_data write_data
   );
      set_bus(bus_id);
      capture_bus();
      initiate_contact(slave_addr); 
      send_write(write_data);
      free_bus();
   endtask

   //*****************************************************************
   // READ FROM A SLAVE ON I2C BUS
   //*****************************************************************
   task read(
      input wb_addr  bus_id,
      input i2c_data slave_addr
   );
      set_bus(bus_id);
      capture_bus();
      initiate_contact(slave_addr); 
      send_read();
      free_bus();
   endtask

   //*****************************************************************
   // INITIATE CONTACT WITH SLAVE ON I2C BUS
   //*****************************************************************
   task initiate_contact(input i2c_addr slave_addr);
      // Write slave address to the DPR 
      // The rightmost bit, 0 means writing
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, {slave_addr, 1'b0});
      
      // Write byte "xxxxx001" to the CMDR
      // This is the "Write" command
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b001);
   endtask

   //*****************************************************************
   // SET BUS
   //*****************************************************************
   task set_bus(input wb_addr bus_id);
      // Write bus_id to the DPR
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, bus_id);
   
      // Write byte "xxxxx110" to the CMDR
      // This is "Set Bus" command
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b110);
   endtask

   //*****************************************************************
   // CAPTURE BUS
   //*****************************************************************
   task capture_bus;
      // Write byte "xxxxx100" to the CMDR 
      // This is the "Start" command
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b100);
   endtask

   //*****************************************************************
   // SEND WRITE COMMAND TO SLAVE ON I2C BUS
   //*****************************************************************
   task send_write(input i2c_data write_data);
      // Write byte to the DPR
      p0_agent.bl_create_put(DPR, wb_pkg::WRITE, write_data);
      
      // Write byte "xxxxx001" to the CMDR
      // This is "Write" command
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b001);
   endtask

   //*****************************************************************
   // SEND READ COMMAND TO SLAVE ON I2C BUS
   //*****************************************************************
   task send_read;
     // Write byte "xxxxx010" to the CMDR
     // This is "Read With Ack" command
     p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b010);
   endtask

   //*****************************************************************
   // FREE SELECTED BUS
   //*****************************************************************
   task free_bus;
      // Write byte "xxxxx101" to the CMDR. 
      // This is "Stop" command
      p0_agent.bl_create_put(CMDR, wb_pkg::WRITE, 8'b101);
   endtask
endclass

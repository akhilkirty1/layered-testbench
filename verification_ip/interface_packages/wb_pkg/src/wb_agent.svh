class wb_agent extends ncsu_component#(.T(wb_transaction));

   wb_configuration    cfg;
   wb_driver           driver;
   wb_monitor          monitor;
   ncsu_component #(T) subscribers[$];
   virtual wb_if       bus;

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      if ( !(ncsu_config_db#(virtual wb_if)::get(get_full_name(), this.bus))) begin;
        $display("wb_agent::ncsu_config_db::get() failed for name: %s ", 
           get_full_name());
        $finish;
      end
   endfunction

   //****************************************************************
   // SET CONFIGURATION
   //****************************************************************
   function void set_configuration(wb_configuration cfg);
      this.cfg = cfg;
   endfunction

   //****************************************************************
   // BUILD
   //****************************************************************
   virtual function void build();
      driver = new("wb_driver", this);
      driver.set_configuration(cfg);
      driver.build();
      driver.bus = this.bus;
      monitor = new("monitor", this);
      monitor.set_configuration(cfg);
      monitor.build();
      monitor.bus = this.bus;
   endfunction

   //****************************************************************
   // NON-BLOCKING PUT
   //****************************************************************
   virtual function void nb_put(T trans);
      foreach (subscribers[i]) subscribers[i].nb_put(trans);
   endfunction

   //****************************************************************
   // BLOCKING PUT
   //****************************************************************
   virtual task bl_put(T trans);
      
      wb_data response;

      // Transaction to hold read data after command
      wb_transaction ret_trans = new;

      // Drive transaction
      driver.bl_put(trans);

      // Handle I2CMB Commands
      if (trans.address == CMDR && trans.op_type == WRITE) begin

         // Wait 3000ns for the command to finish
         #3000;
         
         // Verify that IRQ is high if enabled
         /*
         if (cfg.enable_irq) assert_irq_predicted: 
            assert (driver.bus.irq_i);
            else begin $display("Error: IRQ Low after Command"); $finish; end
         
         // Verify that the IRQ line is held low if it is disabled
         assert_irq_low_if_disabled:
            assert (cfg.enable_irq || (driver.bus.irq_i == 1'b0))
            else begin $display("Error: IRQ High when Disabled"); $finish; end
         */
         // Read CMDR for response
         bl_create_put(CMDR, READ, response);
         
         // Verify CMDR status flags
         //$display("WB RETURNED DATA: %b", response);
         if (!response[7]) begin $display("WB Command Failed"); $finish; end
      end
      #3000;
   endtask

   //****************************************************************
   // CONNECT SUBSCRIBER
   //****************************************************************
   virtual function void connect_subscriber(ncsu_component#(T) subscriber);
      subscribers.push_back(subscriber);
   endfunction

   //****************************************************************
   // START AGENT
   //****************************************************************
   virtual task run();
      fork monitor.run(); join_none
   endtask

   //****************************************************************
   // BLOCKING CREATE PUT
   //****************************************************************
   task bl_create_put(
      wb_addr address, 
      wb_op_t op_type, 
      wb_data data
   );
      wb_data returned_data;
      wb_transaction trans = new;
      trans.address = address;
      trans.op_type = op_type;
      trans.data    = data;
      bl_put(trans);
   endtask
endclass

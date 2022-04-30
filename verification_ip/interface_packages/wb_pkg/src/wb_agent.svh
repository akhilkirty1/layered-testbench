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
      
      // Drive transaction
      driver.bl_put(trans);
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
      input wb_addr address, 
      input wb_op_t op_type, 
      input wb_data data
   );
      wb_transaction trans = new;
      wb_transaction ret_trans = new;
      trans.address = address;
      trans.op_type = op_type;
      trans.data    = data;
      bl_put(trans);

      // Handle I2CMB Commands
      if (cfg.wait_for_comp) begin
         if (trans.address == CMDR && trans.op_type == WRITE) begin

            // Create a place to hold command response
            ret_trans.address = CMDR;
            ret_trans.op_type = wb_pkg::READ;
            
            // Wait 3000ns for the command to finish
            if (cfg.enable_irq) bus.wait_for_interrupt();
            
            // Verify that IRQ is high if enabled
            if (cfg.enable_irq) assert_irq_predicted: 
               assert (driver.bus.irq_i);
               else begin $display("Error: IRQ Low after Command"); $finish; end
            
            // Verify that the IRQ line is held low if it is disabled
            assert_irq_low_if_disabled:
               assert (cfg.enable_irq || (driver.bus.irq_i == 1'b0))
               else begin $display("Error: IRQ High when Disabled"); $finish; end
            
            // Read CMDR for response
            bl_put(ret_trans);

            // Verify Response
            assert_correct_response: 
               assert (ret_trans.data[7]
                       || (cfg.lose_arbitration && ret_trans.data[5]))
                 else $fatal(1, "WB Command Failed: %b", ret_trans.data);

            assert_valid_response:
              assert (^ret_trans.data[7:4])
                else $fatal(1, "Invalid Response: %b", ret_trans.data);
         end
         #3000;
      end
   endtask
endclass

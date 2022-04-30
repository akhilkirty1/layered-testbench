class wb_monitor extends ncsu_component#(.T(wb_transaction));

   wb_data monitored_read_data;
   wb_configuration    cfg;
   ncsu_component #(T) pred;
   virtual wb_if       bus;
   
   covergroup wb_monitor_cg with function sample(wb_transaction trans);
      reg_x_op:   cross trans.address, trans.op_type;
      reg_x_data: cross trans.address, trans.data iff (trans.op_type == WRITE);
      cmd_ran:    coverpoint trans.data[2:0]
         iff(trans.address == CMDR && trans.op_type == WRITE);
   endgroup
   
   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      wb_monitor_cg = new;
   endfunction
   
   //****************************************************************
   // SET CONFIGURATION
   //****************************************************************
   function void set_configuration(wb_configuration cfg);
      this.cfg = cfg;
   endfunction
   
   //****************************************************************
   // SET PREDICTOR
   //****************************************************************
   function void set_predictor(ncsu_component #(T) pred);
      this.pred = pred;
   endfunction
   
   //****************************************************************
   // MONITOR BUS
   //****************************************************************
   virtual task run();
      
      // Wait for reset
      bus.wait_for_reset();
      forever begin
         
         // Create a new Transaction
         T monitored_trans = new;
         
         // Read Transaction
         bus.monitor(
            monitored_trans.address,
            monitored_trans.op_type,
            monitored_trans.data
         );
         
         // Display Transaction
         if (cfg.log_monitor) begin
            $display(
               "%s wb_monitor::run() Address:0x%x Type:%s Data:0x%x",
               get_full_name(),
               monitored_trans.address, 
               monitored_trans.op_type.name, 
               monitored_trans.data
            );
         end
         
         // Sample Coverage
         wb_monitor_cg.sample(monitored_trans);
         
         // Send Transaction to Predictor
         pred.nb_put(monitored_trans);
         
         // Save data for reg_reset_test
         monitored_read_data = monitored_trans.data;
      end
   endtask
endclass

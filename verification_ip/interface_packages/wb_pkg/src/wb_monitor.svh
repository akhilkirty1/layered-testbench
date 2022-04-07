class wb_monitor extends ncsu_component#(.T(wb_transaction));
   wb_configuration cfg;
   virtual wb_if bus;
   ncsu_component #(T) pred;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(wb_configuration cfg);
      this.cfg = cfg;
   endfunction

   function void set_predictor(ncsu_component #(T) pred);
      this.pred = pred;
   endfunction

   virtual task run;
      // Wait for reset
      bus.wait_for_reset();
      forever begin
         // Create a new Transaction
         T monitored_trans = new;
        
         // Read Transaction
         bus.monitor(monitored_trans.address,
                     monitored_trans.op_type,
                     monitored_trans.data
                     );

         // Display Transaction
         if (cfg.log_monitor) begin
            $display("%s wb_monitor::run() Address:0x%x Type:%s Data:0x%x",
                     get_full_name(),
                     monitored_trans.address, 
                     monitored_trans.op_type.name, 
                     monitored_trans.data
                     );
         end

         // Send Transaction to Scoreboard
         pred.nb_put(monitored_trans);
      end
   endtask
endclass

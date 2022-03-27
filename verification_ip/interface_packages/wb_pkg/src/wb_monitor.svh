class wb_monitor extends ncsu_component#(.T(wb_transaction));
   
   wb_configuration configuration;
   virtual wb_if bus;

   T monitored_trans;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(wb_configuration cfg);
      configuration = cfg;
   endfunction

   virtual task run ();
      // Wait for reset
      bus.wait_for_reset();

      forever begin

         // Read Transaction
         monitored_trans = new("monitored_trans");
         bus.monitor(monitored_trans.address,
                     monitored_trans.op_type,
                     monitored_trans.data
                     );

         // Display Transaction
         $display("%s abc_monitor::run() Address:0x%x Type:%s Data:0x%x",
                  get_full_name(),
                  monitored_trans.address, 
                  monitored_trans.op_type.name, 
                  monitored_trans.data, 
                  );
        parent.nb_put(monitored_trans);
      end
   endtask

endclass

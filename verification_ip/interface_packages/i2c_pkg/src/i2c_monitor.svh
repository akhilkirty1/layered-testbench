class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

   i2c_configuration cfg;
   ncsu_component #(T) scbd;
   virtual i2c_if bus;

   covergroup i2c_monitor_cg with function sample (
      i2c_op_t op_type, 
      i2c_addr addr, 
      i2c_data data
   );
      op_x_addr: cross op_type, addr;
      op_x_data: cross op_type, data;
   endgroup

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      i2c_monitor_cg = new;
   endfunction

   //****************************************************************
   // SET CONFIGURATION
   //****************************************************************
   function void set_configuration(i2c_configuration cfg);
      this.cfg = cfg;
   endfunction

   //****************************************************************
   // SET SCOREBOARD
   //****************************************************************
   function void set_scoreboard(ncsu_component #(T) scbd);
      this.scbd = scbd;
   endfunction

   //****************************************************************
   // START MONITORING
   //****************************************************************
   virtual task run ();
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
            $display(
               "%s i2c_monitor::run() Address:0x%x Type:%s Data: %p",
               get_full_name(),
               monitored_trans.address, 
               monitored_trans.op_type.name, 
               monitored_trans.data
            );
         end
         foreach (monitored_trans.data[i]) begin
            // Sample Covergroup
            i2c_monitor_cg.sample(
               monitored_trans.op_type, 
               monitored_trans.address,
               monitored_trans.data[i]
            );
         end
         
         // Send Transaction to Scoreboard
         scbd.nb_put(monitored_trans);
      end
   endtask
endclass

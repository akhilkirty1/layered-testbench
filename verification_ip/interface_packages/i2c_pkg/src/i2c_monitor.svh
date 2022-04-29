class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

   i2c_configuration cfg;
   ncsu_component #(T) scbd;
   virtual i2c_if bus;

   covergroup i2c_monitor_cg with function sample (i2c_transaction trans);
      op_x_addr: cross trans.op, trans.addr;
      op_x_data: cross trans.op, trans.data;
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
         T trans = new;

         // Read Transaction
         bus.monitor(trans);

         // Display Transaction
         if (cfg.log_monitor)
            $display("%s i2c_monitor::run() Address: 0x%x Type: 0x%x Type: %s",
                     get_full_name(),
                     trans.addr, 
                     trans.data,
                     trans.op.name
                     );
         
         // Sample Covergroup
         i2c_monitor_cg.sample(trans);
         
         // Send Transaction to Scoreboard
         scbd.nb_put(trans);
         
      end
   endtask
endclass

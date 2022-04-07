class i2c_monitor extends ncsu_component#(.T(i2c_transaction));
   i2c_configuration cfg;
   virtual i2c_if bus;
   ncsu_component #(T) scoreboard;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(i2c_configuration cfg);
      this.cfg = cfg;
   endfunction

   function void set_scoreboard(ncsu_component #(T) scbd);
      scoreboard = scbd;
   endfunction

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
            $display("%s i2c_monitor::run() Address:0x%x Type:%s Data: %p",
                     get_full_name(),
                     monitored_trans.address, 
                     monitored_trans.op_type.name, 
                     monitored_trans.data
                     );
         end

         // Send Transaction to Scoreboard
         // scoreboard.bl_put(monitored_trans);
         scoreboard.nb_put(monitored_trans);
      end
   endtask
endclass

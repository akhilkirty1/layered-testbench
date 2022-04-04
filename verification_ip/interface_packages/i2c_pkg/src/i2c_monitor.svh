class i2c_monitor extends ncsu_component#(.T(i2c_transaction));
   i2c_configuration configuration;
   virtual i2c_if bus;
   ncsu_component #(T) scoreboard;
   T monitored_trans;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      monitored_trans = new("monitored_trans");
   endfunction

   function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
   endfunction

   function void set_scoreboard(ncsu_component #(T) scbd);
      scoreboard = scbd;
   endfunction

   virtual task run ();
      forever begin
         monitored_trans.data.delete();

         // Read Transaction
         bus.monitor(monitored_trans.address,
                     monitored_trans.op_type,
                     monitored_trans.data
                     );

         // Display Transaction
         $display("%s i2c_monitor::run() Address:0x%x Type:%s Data: %p",
                  get_full_name(),
                  monitored_trans.address, 
                  monitored_trans.op_type.name, 
                  monitored_trans.data
                  );
         scoreboard.bl_put(monitored_trans);
         monitored_trans.data.delete();
      end
   endtask
endclass

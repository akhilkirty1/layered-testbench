class i2c_monitor extends ncsu_component#(.T(i2c_transaction));
   
   i2c_configuration configuration;
   virtual i2c_if bus;

   T monitored_trans;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
   endfunction

   virtual task run ();
      // Doesn't Exist
      bus.wait_for_reset();

      forever begin

         // Read Transaction
         monitored_trans = new("monitored_trans");
         bus.monitor(monitored_trans.address,
                     monitored_trans.op_type,
                     monitored_trans.data);

         // Display Transaction
         ncsu_info("abc_monitor::run()", 
            $sformatf("%s: Slave Address: 0x%x\nOperation: %x\nData: 0x%x"
                  get_full_name(),
                  monitored_trans.address,
                  monitored_trans.op_type,
                  monitored_trans.data), NCSU_MEDIUM);
         parent.nb_put(monitored_trans);

      end
   endtask

endclass

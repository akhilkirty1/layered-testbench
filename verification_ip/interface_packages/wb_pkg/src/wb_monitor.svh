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
      bus.wait_for_reset();
      forever begin
         monitored_trans = new("monitored_trans");
         bus.monitor(monitored_trans.header,
                     monitored_trans.payload,
                     monitored_trans.trailer,
                     monitored_trans.delay
                     )
         ncsu_info("abc_monitor::run()", $sformatf("%s: header 0x%x payload
                  get_full_name(),
                  monitored_trans.header,
                  monitored_trans.payload,
                  monitored_trans.trailer,
                  monitored_trans.delay), NCSU_MEDIUM);
         parent.nb_put(monitored_trans);
      end
   endtask

endclass

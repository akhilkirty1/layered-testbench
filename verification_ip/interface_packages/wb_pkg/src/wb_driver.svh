class wb_driver extends ncsu_component#(.T(wb_transaction));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   virtual wb_if bus;
   wb_configuration configuration;
   wb_transaction wb_trans;

   function void set_configuration(wb_configuration cfg);
      configuration = cfg;
   endfunction

   virtual task bl_put(T trans);
      ncsu_info("wb_driver::run()", {get_full_name(), "-", trans.convert
      bus.drive(trans.header,
                trans.payload,
                trans.trailer,
                trans.delay
                );
   endtask

endclass

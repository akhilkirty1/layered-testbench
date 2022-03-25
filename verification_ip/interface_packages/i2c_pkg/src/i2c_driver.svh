class i2c_driver extends ncsu_component#(.T(i2c_transaction));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   virtual i2c_if bus;
   i2c_configuration configuration;
   i2c_transaction i2c_trans;

   function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
   endfunction

   virtual task bl_put(T trans);
      ncsu_info("i2c_driver::run()", {get_full_name(), "-", trans.convert2string());
      bus.drive(trans.slave_addr,
                trans.trans_mode,
                trans.trans_data);
   endtask

endclass

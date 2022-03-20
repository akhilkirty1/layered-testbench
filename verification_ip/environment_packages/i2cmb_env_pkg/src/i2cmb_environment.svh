class i2cmb_environment extends ncsu_component#(.T(i2cmb_transaction_base));

   env_configuration configuration;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(env_configuration cfg);
      configuration = cfg;
   endfunction

   virtual function void build();
      
   endfunction
  
   function ncsu_component#(T) get_i2c_agent();
      return p1_agent;
   endfunction

   virtual task run();
      i2c_agent.run();
      wb_agent.run();
   endtask

endclass

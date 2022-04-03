class i2cmb_coverage extends ncsu_component #(wb_transaction);

   i2cmb_env_configuration configuration;

   covergroup coverage_cg;
      option.per_instance = 1;
      option.name = get_full_name();
   endgroup

   function void set_configuration(i2cmb_env_configuration cfg);
      configuration = cfg;
   endfunction

   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
      coverage_cg = new;
   endfunction

   virtual function void nb_put(T trans);
      $display({get_full_name()," ",trans.convert2string()});
      coverage_cg.sample();
   endfunction

endclass

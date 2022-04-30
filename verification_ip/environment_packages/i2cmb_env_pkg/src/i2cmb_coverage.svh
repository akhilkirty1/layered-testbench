class i2cmb_coverage extends ncsu_component #(wb_transaction);
   
   i2cmb_env_configuration cfg;
   function void set_configuration(i2cmb_env_configuration cfg);
      this.cfg = cfg;
   endfunction
   
   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
   endfunction
endclass

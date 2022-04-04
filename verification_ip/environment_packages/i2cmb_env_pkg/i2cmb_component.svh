module i2cmb_component#(T=ncsu_transaction) extends ncsu_component#(.T(T));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction
   
   function void set_configuration(wb_configuration cfg);
      configuration = cfg;
   endfunction

   function void nb_put(wb_agent agent);
      this.agent = agent;
   endfunction
endmodule

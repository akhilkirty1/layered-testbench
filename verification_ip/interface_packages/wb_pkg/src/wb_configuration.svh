class wb_configuration extends ncsu_configuration;
   
   bit log_monitor = 1'b0;
   bit log_driver  = 1'b0;

   covergroup wb_configuration_cg;
   endgroup

   function void sample_coverage();
      wb_configuration_cg.sample();
   endfunction

   function new(string name="");
      super.new(name);
      wb_configuration_cg = new;
   endfunction

   virtual function string convert2string();
      return {super.convert2string};
   endfunction

endclass

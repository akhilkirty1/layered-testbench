class i2c_configuration extends ncsu_configuration;
   
   const bit log_monitor = 1'b0;
   
   bit send_ack         = 1'b1;
   int stretch_time     = 1'b0;
   bit read_with_nack   = 1'b0;
   
   integer time_to_stretch;
   covergroup i2c_env_cg;
      i2c_config : coverpoint time_to_stretch;
   endgroup

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name="");
      super.new(name);
   endfunction

   //****************************************************************
   // CONVERT TO STRING
   //****************************************************************
   virtual function string convert2string();
      return {super.convert2string};
   endfunction

endclass

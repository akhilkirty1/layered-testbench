class i2c_configuration extends ncsu_configuration;
   
   const bit log_monitor = 1'b0;

   bit stretch = 1'b0; // Test the driver to stretch the clock

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

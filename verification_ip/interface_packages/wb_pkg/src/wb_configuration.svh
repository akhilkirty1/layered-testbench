class wb_configuration extends ncsu_configuration;
   
   bit log_monitor = 1'b0;
   bit log_driver  = 1'b0;
   bit enable_irq  = 1'b1;

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

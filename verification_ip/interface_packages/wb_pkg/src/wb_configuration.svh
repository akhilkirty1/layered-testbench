class wb_configuration extends ncsu_configuration;
   
   // Logging Configuration
   const bit log_monitor = 1'b0;
   const bit log_driver  = 1'b0;

   // Other Configuration
   bit enable_irq    = 1'b1;    // Enable the IRQ output of the IICMB
   bit wait_for_comp = 1'b1;    // Wait for command completion
   bit lose_arbitration = 1'b0; // Should we lose arbitration
   
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

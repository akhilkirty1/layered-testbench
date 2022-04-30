class i2cmb_env_configuration extends ncsu_configuration;

   // Logging Configuration
   const bit log_commands   = 1'b0;
   const bit log_registers  = 1'b0;
   const bit log_components = 1'b0;
   const bit log_sub_tests  = 1'b1;
   const bit log_tests      = 1'b1;

   // Other Configuration
   bit dont_stop   = 1'b0;  // Use repeated start command instead of stopping
   bit scbd_enable = 1'b1;  // Enable the scoreboard
   
   // Configurations
   wb_configuration  wb_config;
   i2c_configuration i2c_config;

   //******************************************************
   // CONSTRUCTOR
   //******************************************************
   function new(string name="", ncsu_component parent=null); 
      super.new(name);
      wb_config  = new("wb_config");
      i2c_config = new("i2c_config");
   endfunction

endclass


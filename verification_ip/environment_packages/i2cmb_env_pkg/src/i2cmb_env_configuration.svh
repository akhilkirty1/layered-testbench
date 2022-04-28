class i2cmb_env_configuration extends ncsu_configuration;

   // Logging Configuration
   const bit log_commands   = 1'b0;
   const bit log_registers  = 1'b0;
   const bit log_components = 1'b0;
   const bit log_sub_tests  = 1'b1;
   const bit log_tests      = 1'b1;
   const bit enable_irq     = 1'b1;

   // Configurations
   wb_configuration  p0_agent_config;
   i2c_configuration p1_agent_config;

   //******************************************************
   // CONSTRUCTOR
   //******************************************************
   function new(string name="", ncsu_component parent=null); 
      super.new(name);
      p0_agent_config = new("p0_agent_config");
      p1_agent_config = new("p1_agent_config");
   endfunction

endclass


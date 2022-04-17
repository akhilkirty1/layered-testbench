class i2cmb_env_configuration extends ncsu_configuration;

  // Logging Configuration
  const bit log_commands   = 1'b0;
  const bit log_registers  = 1'b0;
  const bit log_components = 1'b0;
  const bit log_sub_tests  = 1'b1;
  const bit log_tests      = 1'b1;
  const bit enable_irq     = 1'b1;

  function void sample_coverage();
     // i2cmb_env_configuration_cg.sample();
  endfunction
  
  wb_configuration  p0_agent_config;
  i2c_configuration p1_agent_config;

  function new(string name="", ncsu_component parent=null); 
    super.new(name);
    // i2cmb_env_configuration_cg = new;
    p0_agent_config = new("p0_agent_config");
    p1_agent_config = new("p1_agent_config");
    p1_agent_config.collect_coverage=0;
    p0_agent_config.sample_coverage();
    p1_agent_config.sample_coverage();
  endfunction

endclass


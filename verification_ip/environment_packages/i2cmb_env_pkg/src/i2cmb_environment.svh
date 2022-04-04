class i2cmb_environment extends ncsu_component;
  i2cmb_env_configuration configuration;
  wb_agent                p0_agent;
  i2c_agent               p1_agent;
  i2cmb_predictor         pred;
  i2cmb_scoreboard        scbd;
  i2cmb_coverage          coverage;

  function new(string name = "", ncsu_component parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    p0_agent = new("p0_agent");
    p0_agent.set_configuration(configuration.p0_agent_config);
    p0_agent.build();
    p1_agent = new("p1_agent");
    p1_agent.set_configuration(configuration.p1_agent_config);
    p1_agent.build();
    pred  = new("pred");
    pred.set_configuration(configuration);
    pred.build();
    scbd  = new("scbd");
    scbd.build();
    p1_agent.monitor.set_scoreboard(scbd);
    coverage = new("i2cmb_coverage");
    coverage.set_configuration(configuration);
    coverage.build();
    //p0_agent.connect_subscriber(coverage);
    p0_agent.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    p1_agent.connect_subscriber(scbd);
  endfunction

  function wb_agent get_p0_agent();
    return p0_agent;
  endfunction

  function i2c_agent get_p1_agent();
    return p1_agent;
  endfunction

  virtual task run();
     p0_agent.run();
     p1_agent.run();
  endtask
endclass

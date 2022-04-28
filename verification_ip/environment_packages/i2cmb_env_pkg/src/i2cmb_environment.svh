class i2cmb_environment extends ncsu_component;

   i2cmb_env_configuration cfg;
   wb_agent                p0_agent;
   i2c_agent               p1_agent;
   i2cmb_predictor         pred;
   i2cmb_scoreboard        scbd;
   i2cmb_generator         gen;
   i2cmb_coverage          coverage;

   //******************************************************
   // CONSTRUCTOR
   //******************************************************
   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
   endfunction 

   //******************************************************
   // SET CONFIGURATION
   //******************************************************
   function void set_configuration(i2cmb_env_configuration cfg);
      this.cfg = cfg;
   endfunction

   //******************************************************
   // SET GENERATOR
   //******************************************************
   function void set_generator(i2cmb_generator gen);
      this.gen = gen;
   endfunction

   //******************************************************
   // BUILD
   //******************************************************
   virtual function void build();

      // WB agent
      p0_agent = new("p0_agent");
      p0_agent.set_configuration(cfg.p0_agent_config);
      p0_agent.build();

      // I2C agent
      p1_agent = new("p1_agent");
      p1_agent.set_configuration(cfg.p1_agent_config);
      p1_agent.build();

      // Predictor 
      pred  = new("pred");
      pred.set_configuration(cfg);
      pred.build();
      
      // Scoreboard 
      scbd  = new("scbd");
      scbd.build();
      
      // Set Predictor and Scoreboard
      p0_agent.monitor.set_predictor(pred);
      p1_agent.monitor.set_scoreboard(scbd);

      // I2CMB Coverage
      coverage = new("i2cmb_coverage");
      coverage.set_configuration(cfg);
      coverage.build();

      // Connect Subscribers
      p0_agent.connect_subscriber(coverage);
      p0_agent.connect_subscriber(pred);
      pred.set_scoreboard(scbd);
      pred.set_generator(gen);
      p1_agent.connect_subscriber(scbd);
   endfunction

   //******************************************************
   // GET P0 AGENT
   //******************************************************
   function wb_agent get_p0_agent();
      return p0_agent;
   endfunction

   //******************************************************
   // GET P1 AGENT
   //******************************************************
   function i2c_agent get_p1_agent();
      return p1_agent;
   endfunction

   //******************************************************
   // RUN AGENTS
   //******************************************************
   virtual task run();
      p0_agent.run();
      p1_agent.run();
   endtask
endclass

class i2cmb_test extends ncsu_component#(.T(wb_transaction));

   i2cmb_env_configuration    cfg;
   i2cmb_environment          env;
   i2cmb_generator            gen;

   function new(string name = "", ncsu_component #(T) parent = null);
      // Call base class constructor
      super.new(name, parent);

      // Initiates and construct environment configuration
      cfg = new("cfg");
      cfg.sample_coverage();


      // Initiates and construct environment
      env = new("env", this);
      env.set_configuration(cfg);
      env.build();

      // Initiates and construct generator
      gen = new("gen", this);
      gen.set_agent(env.get_p0_agent());
   endfunction

   // Runs environment and generator
   virtual task run();
      env.run();
      gen.run();
   endtask

endclass

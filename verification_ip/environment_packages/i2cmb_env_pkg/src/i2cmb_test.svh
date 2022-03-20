class i2cmb_test extends ncsu_component#(.T(i2cmb_transaction_base));

   env_configuration    cfg;
   environment          env;
   generator            gen;

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
      gen.set_agent(env.get_i2c_agent());
   endfunction

   // Runs environment and generator
   virtual task run();
      env.run();
      gen.run();
   endtask

endclass

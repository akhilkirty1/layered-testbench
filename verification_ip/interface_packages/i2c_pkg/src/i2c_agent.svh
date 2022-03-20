class i2c_agent extends ncsu_component#(.T(i2c_transaction));

   i2c_configuration configuration;
   i2c_driver        driver;
   i2c_monitor       monitor;
   i2c_coverage      coverage;
   ncsu_component #(T) subscribers[$];
   virtual i2c_if    bus;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      if ( !(ncsu_config_cb#(virtual i2c_if)::get(get_full_name(), this.bus)))
         ncsu_fatal("i2c_agent::new()", $sformatf("ncsu_config_db::get() call fo
      end
   endfunction

   virtual function void build();
      driver = new("driver, this);
      driver.set_configuration(configuration);
      driver.build();
      driver.bus = this.bus;
      if ( configuration.collect_coverage) begin
         coverage = new("coverage", this);
         coverage.set_configuration(configuration);
         coverage.build();
         connect_subscriber(coverage);
      end
      monitor = new("monitor", this);
      monitor.set_configuration(configuration);
      monitor.build();
      monitor.bus = this.bus;
   endfunction

   virtual function void nb_put(T trans);
      foreach (subscribers[i]) subscribers[i].nb_put(trans);
   endfunction

   virtual task bl_put(T trans);
      driver.bl_put(trans);
   endtask

   virtual function void connect_subscriber(ncsu_component#(T) subscriber);
      subscribers.push_back(subscriber);
   endfunction

   virtual task run();
      fork monitor.run(); join_none
   endtask

endclass

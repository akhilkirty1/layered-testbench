class wb_agent extends ncsu_component#(.T(wb_transaction));

   wb_configuration configuration;
   wb_driver        driver;
   wb_monitor       monitor;
   wb_coverage      coverage;
   ncsu_component #(T) subscribers[$];
   virtual wb_if    bus;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      if ( !(ncsu_config_cb#(virtual wb_if)::get(get_full_name(), this.bus)))
         ncsu_fatal("wb_agent::new()", $sformatf("ncsu_config_db::get() call fo
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

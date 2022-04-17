class i2c_configuration extends ncsu_configuration;

    typedef enum {STANDARD} i2c_mode_t;

    bit log_monitor = 1'b0;

    bit lose_arbitration;
    bit send_ack;
    int stretch_time;
    bit collect_coverage;
    i2c_mode_t mode;

    covergroup i2c_configuration_cg;
       i2c_config : cross      mode, stretch_time, send_ack;
    endgroup

   integer time_to_stretch;
   covergroup i2c_env_cg;
      i2c_config : coverpoint time_to_stretch;
   endgroup

   bit addr;
   bit data;
   covergroup i2c_agent_cg;
      op_x_addr : cross addr, data;
   endgroup

   // Test Multi-Master Arbitration
   bit irq_with = 1'b0;
   covergroup arbitration_cg;
      i2c_config : cross      mode, stretch_time, send_ack iff (lose_arbitration);
   endgroup

   function void sample_coverage();
      i2c_configuration_cg.sample();
   endfunction

   function new(string name="");
      super.new(name);
      i2c_configuration_cg = new;
   endfunction

   virtual function string convert2string();
      return {super.convert2string};
   endfunction

endclass

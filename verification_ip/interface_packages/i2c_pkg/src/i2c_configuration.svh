class i2c_configuration extends ncsu_configuration;

   typedef enum {STANDARD} i2c_mode_t;

   bit enable;
   i2c_mode_t mode;
   bit send_ack;
   bit stretch_clock;
   bit collect_coverage;

   covergroup i2c_configuration_cg;
      option.per_instance = 1;
      option.name = name;
      i2c_enable          : coverpoint enable;
      i2c_config : cross      mode, stretch_clock, send_ack iff (enable);
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

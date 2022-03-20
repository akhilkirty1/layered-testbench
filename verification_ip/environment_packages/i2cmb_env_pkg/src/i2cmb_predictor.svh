class i2cmb_predictor extends ncsu_component#(.T(i2cmb_transaction_base));
   
   ncsu_component#(T) scoreboard;
   ncsu_transaction_base transport_trans;
   env_configuration configuration;

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(env_configuration cfg);
      configuration = cfg;
   endfunction

   virtual function void set_scoreboard(ncsu_component #(T) scoreboard);
      this.scoreboard = scoreboard;
   endfunction

   virtual function void nb_put(T trans);
      ncsu_info("predictor::nb_put()",
         $sformatf({get_full_name(), " ", trans.convert2string()}),
         NCSU_MEDIUM);
      scoreboard.nb_transport(trans, transport_trans);
   endfunction

endclass

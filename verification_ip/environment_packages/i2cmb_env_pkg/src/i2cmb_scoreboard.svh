class i2cmb_scoreboard extends ncsu_component#(.T(i2cmb_transaction_base));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   T expected_trans;

   virtual function void nb_transport(input T input_trans, output T output_trans
      ncsu_info("scoreboard::nb_transport()", {"expected transaction ",
      this.expected_trans = input_trans;
   endfunction

   virtual function void nb_put(T trans);
      ncsu_info("scoreboard::nb_put()", {"expected transaction ", expect
      ncsu_info("scoreboard::nb_put()", {"actual transaction ", trans.co
      if ( this.expected_trans.compare(trans) }
         ncsu_info("scoreboard::nb_put()", $sformatf({get_full_name(), 
      else
         ncsu_info("scoreboard::nb_put()", $sformatf({get_full_name(), 
   endfunction
endclass

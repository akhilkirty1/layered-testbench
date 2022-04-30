class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));


   T trans_in;
   T trans_out;
   i2cmb_env_configuration cfg;

   //*****************************************************************
   // CONSTRUCTOR
   //*****************************************************************
   function new(string name = "", ncsu_component parent = null);
      super.new(name, parent);
   endfunction

   //*****************************************************************
   // SET CONFIGURATION
   //*****************************************************************
   function set_configuration(i2cmb_env_configuration cfg);
      this.cfg = cfg;
   endfunction
   
   //*****************************************************************
   // NON-BLOCKING TRANSPORT
   //*****************************************************************
   // Used as a second nb_put
   virtual function void nb_transport(input T input_trans, output T output_trans);
      if (cfg.scbd_enable) begin
         // Log predicted transaction
         $display({"Predicted:\t", input_trans.convert2string()});
         
         // Save transaction
         this.trans_in = new input_trans;
         output_trans = trans_out;
      end
   endfunction

   //*****************************************************************
   // NON-BLOCKING PUT
   //*****************************************************************
   virtual function void nb_put(T trans);
      if (cfg.scbd_enable) begin
         // Log found transaction
         $display({"Actual:\t", trans.convert2string()});
  
         // Verify that predicted response matches actual response
         assert_correct_i2c_trans: 
            assert (this.trans_in.compare(trans)) $display("MATCH!");
         else $fatal(1, "MISMATCH!");
      end
   endfunction
endclass

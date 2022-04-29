class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));

   T trans_in;
   T trans_out;

   //*****************************************************************
   // CONSTRUCTOR
   //*****************************************************************
   function new(string name = "", ncsu_component parent = null);
      super.new(name, parent);
   endfunction

   //*****************************************************************
   // NON-BLOCKING TRANSPORT
   //*****************************************************************
   // Used as a second nb_put
   virtual function void nb_transport(input T input_trans, output T output_trans);
      
      // Log predicted transaction
      $display({"Predicted:\t", input_trans.convert2string()});
      
      // Save transaction
      this.trans_in = new input_trans;
      output_trans = trans_out;
   endfunction

   //*****************************************************************
   // NON-BLOCKING PUT
   //*****************************************************************
   virtual function void nb_put(T trans);

      // Log found transaction
      $display({"Actual:\t", trans.convert2string()});
  
      // Verify that predicted response matches actual response
      assert_correct_i2c_trans: 
         assert (this.trans_in.compare(trans)) $display("MATCH!");
         else $error("MISMATCH!"); 
   endfunction
endclass

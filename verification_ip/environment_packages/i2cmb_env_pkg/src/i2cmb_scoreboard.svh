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
      $display({get_full_name(),
                " nb_transport: expected transaction ",
                input_trans.convert2string()});
      this.trans_in = new input_trans;
      output_trans = trans_out;
   endfunction

   //*****************************************************************
   // NON-BLOCKING PUT
   //*****************************************************************
   virtual function void nb_put(T trans);

      // Log found transaction
      $display({get_full_name(),
                " nb_put: actual transaction ",
                trans.convert2string()});
  
      // Verify that predicted response matches actual response
      assert_correct_i2c_trans: 
         assert (this.trans_in.compare(trans))
         else begin // Error if not a correct match
            $display({get_full_name(), " transaction MISMATCH!"}); 
            $finish; 
         end;

        // Tell user that that the transaction was a match
        $display({get_full_name(),   " transaction MATCH!"});
   endfunction
   
   //*****************************************************************
   // BLOCKING PUT
   //*****************************************************************
   virtual task bl_put(T trans);
       $display({get_full_name(),
                 " nb_put: actual transaction ",
                 trans.convert2string()});

       // Check if the predicted transaction was correct
       if (this.trans_in.compare(trans)) 
          $display({get_full_name()," i2c_transaction MATCH!"});
       else begin 
          $display({get_full_name()," i2c_transaction MISMATCH!"}); 
          $finish; 
       end
    endtask
endclass

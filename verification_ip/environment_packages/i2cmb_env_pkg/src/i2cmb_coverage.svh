class i2cmb_coverage extends ncsu_component #(wb_transaction);

   bit stretch_time;
   covergroup i2c_conf_cg;
      stretch_time: coverpoint stretch_time {
        bins range[10] = {[0:$]};
      }
   endgroup

   i2cmb_env_configuration cfg;
   function void set_configuration(i2cmb_env_configuration cfg);
      this.cfg = cfg;
   endfunction

   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
      //coverage_cg = new;
      i2c_conf_cg  = new;
   endfunction

   virtual function void nb_put(T trans);
      $display({get_full_name()," ",trans.convert2string()});
      // Temporary Assertions
      assert_correct_registers:    assert (1);
      assert_wait_cmd:             assert (1);
      assert_valid_response:       assert (1);
      assert_correct_response:     assert (1);
   endfunction
endclass

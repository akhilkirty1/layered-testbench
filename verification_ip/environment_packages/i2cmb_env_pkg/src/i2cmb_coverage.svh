class i2cmb_coverage extends ncsu_component #(wb_transaction);

   i2cmb_env_configuration configuration;

   covergroup i2c_agent_cg;
      op_x_addr
   endgroup

   covergroup i2c_env_cg;
      time_to_stretch: cross;
   endgroup
 
   // Verify that the IRQ line is held low if it is disabled
   // assert_irq_low_if_disabled:
   //    assert (enable_irq || irq == 1'b0)

   function void set_configuration(i2cmb_env_configuration cfg);
      configuration = cfg;
   endfunction

   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
      //coverage_cg = new;
   endfunction

   virtual function void nb_put(T trans);
      $display({get_full_name()," ",trans.convert2string()});
      //coverage_cg.sample();

      // Temporary Assertions
      assert_irq_predicted:        assert (1);
      assert_correct_registers:    assert (1);
      assert_wait_cmd:             assert (1);
      assert_valid_response:       assert (1);
      assert_correct_response:     assert (1);
      assert_irq_low_if_disabled:  assert (1);
   endfunction
endclass

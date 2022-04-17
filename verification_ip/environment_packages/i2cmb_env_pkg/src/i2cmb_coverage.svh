class i2cmb_coverage extends ncsu_component #(wb_transaction);

   bit op_type;
   bit addr;
   bit data;
   covergroup i2c_agent_cg;
      op_x_addr: cross op_type, addr;
      op_x_data: cross op_type, data;
   endgroup

   bit stretch_time;
   covergroup i2c_conf_cg;
      stretch_time: coverpoint stretch_time {
        bins range[10] = {[0:$]};
      }
   endgroup

   bit register;
   covergroup wb_agent_cg;
     reg_x_op:   cross op_type, register;
     reg_x_data: cross op_type, data;
   endgroup

   covergroup arbitration_cg;
      op: coverpoint op_type;
   endgroup
 
   // Verify that the IRQ line is held low if it is disabled
   // assert_irq_low_if_disabled:
   //    assert (enable_irq || irq == 1'b0)

   function void set_configuration(i2cmb_env_configuration cfg);
      //configuration = cfg;
   endfunction

   function new(string name = "", ncsu_component parent = null); 
      super.new(name,parent);
      //coverage_cg = new;
      wb_agent_cg = new;
      i2c_agent_cg = new;
      i2c_conf_cg  = new;
      arbitration_cg = new;
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
      assert_correct_i2c_trans:    assert (1);
   endfunction
endclass

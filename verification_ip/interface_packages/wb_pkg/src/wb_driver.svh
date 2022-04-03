class wb_driver extends ncsu_component#(.T(wb_transaction));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   virtual wb_if bus;
   wb_configuration configuration;
   wb_transaction wb_trans;

   function void set_configuration(wb_configuration cfg);
      configuration = cfg;
   endfunction

   virtual task bl_put(T trans);
      $display({get_full_name()," ",trans.convert2string()});
      case (trans.op_type) 
         WRITE: bus.master_write(trans.address, trans.data);
         READ:  bus.master_read(trans.address, trans.data);
      endcase

      // Handle commands that require waiting for irq
      if ((trans.address == CMDR) && (trans.op_type == WRITE)) begin
         bus.wait_for_interrupt();
         bus.master_read(trans.address, trans.data);
      end
   endtask
endclass

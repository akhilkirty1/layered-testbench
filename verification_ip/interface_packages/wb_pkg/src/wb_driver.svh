class wb_driver extends ncsu_component#(.T(wb_transaction));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   virtual wb_if bus;
   wb_configuration cfg;
   wb_transaction wb_trans;

   function void set_configuration(wb_configuration cfg);
      this.cfg = cfg;
   endfunction

   virtual task bl_put(T trans);
      if (cfg.log_driver) begin
         $display({get_full_name()," ",trans.convert2string()});
      end
      case (trans.op_type) 
         WRITE: bus.master_write(trans.address, trans.data);
         READ:  bus.master_read(trans.address, trans.data);
      endcase
   endtask
endclass

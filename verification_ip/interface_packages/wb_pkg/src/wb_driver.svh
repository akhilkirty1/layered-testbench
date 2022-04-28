class wb_driver extends ncsu_component#(.T(wb_transaction));
   
   wb_configuration cfg;
   wb_transaction wb_trans;
   virtual wb_if bus;

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   //****************************************************************
   // SET CONFIGURATION
   //****************************************************************
   function void set_configuration(wb_configuration cfg);
      this.cfg = cfg;
   endfunction

   //****************************************************************
   // BLOCKING PUT
   //****************************************************************
   virtual task bl_put(T trans);

      // Display driven transaction
      if (cfg.log_driver) $display({get_full_name()," ",trans.convert2string()});
      
      // Drive transaction
      case (trans.op_type) 
         WRITE: bus.master_write(trans.address, trans.data);
         READ:  bus.master_read(trans.address, trans.data);
      endcase
   endtask
endclass

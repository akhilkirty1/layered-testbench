class i2c_driver extends ncsu_component#(.T(i2c_transaction));
   
   i2c_configuration cfg;
   i2c_transaction   i2c_trans;
   virtual i2c_if    bus;

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   //****************************************************************
   // SET CONFIGURATION
   //****************************************************************
   function void set_configuration(i2c_configuration cfg);
      this.cfg = cfg;
   endfunction

   //****************************************************************
   // BLOCKING PUT
   //****************************************************************
   virtual task bl_put(T trans);
      if (trans == null) begin
         trans = new("i2c_driver_transaction");
         bus.capture_transfer(trans.address, trans.op_type, trans.data);
         // $display("Trans Captured %s", trans.convert2string());

         if (trans.op_type == i2c_pkg::READ) begin
            //trans.data = gen.provide_data;
            bus.provide_read_data(trans.data);
         end
      end
   endtask
endclass

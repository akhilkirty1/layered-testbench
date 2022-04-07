class i2c_driver extends ncsu_component#(.T(i2c_transaction));
   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
   endfunction

   i2c_configuration cfg;
   i2c_transaction   i2c_trans;
   virtual i2c_if    bus;

   function void set_configuration(i2c_configuration cfg);
      this.cfg = cfg;
   endfunction

   virtual task bl_put(T trans);
      if (trans == null) begin
         trans = new("i2c_driver_transaction");
         bus.capture_transfer(trans.address, trans.op_type, trans.data);
         // $display("Trans Captured %s", trans.convert2string());

         if (trans.op_type == i2c_pkg::READ) begin
            trans.data = generate_read_data();
            bus.provide_read_data(trans.data);
         end
      end
   endtask

   // ****************************************************************
   // GENERATE READ DATA
   // ****************************************************************
   integer read_iter = -1;
   function i2c_data_array generate_read_data();
     // increment read_iter
     read_iter++;

     // send read data
     if (read_iter < 32) return {100 + read_iter}; // return 100 to 131
     else return {(63 + 32) - read_iter};          // return 63 to 0
   endfunction

endclass

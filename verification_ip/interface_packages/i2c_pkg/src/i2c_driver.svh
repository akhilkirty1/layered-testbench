class i2c_driver extends ncsu_component#(.T(i2c_transaction));
   
   i2c_configuration cfg;
   virtual i2c_if    bus;
   i2c_data provide_data;

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
      // Wait for an I2C Transaction
      bus.capture_transfer(trans);

      // If it was a read, provide read data
      if (trans.op == i2c_pkg::READ) begin
         bus.send_read_data(provide_data);
      end
   endtask
endclass

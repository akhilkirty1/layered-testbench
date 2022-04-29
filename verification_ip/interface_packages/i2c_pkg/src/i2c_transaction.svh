class i2c_transaction extends ncsu_transaction;
   `ncsu_register_object(i2c_transaction)

   i2c_addr addr;
   i2c_data data;
   i2c_op_t op;

   //****************************************************************
   // CONSTRUCTOR
   //****************************************************************
   function new(string name="");
      super.new(name);
   endfunction

   //****************************************************************
   // CONVERT TO STRING
   //****************************************************************
   virtual function string convert2string();
      return $sformatf("Address:0x%x Data:0x%x Type: %s",
                       this.addr,
                       this.data,
                       this.op.name);
   endfunction
   
   //****************************************************************
   // COMPARE
   //****************************************************************
   function bit compare(i2c_transaction rhs);
      return ((this.addr == rhs.addr) &&
              (this.data == rhs.data) &&
              (this.op   == rhs.op  ));
   endfunction
endclass

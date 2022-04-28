class i2c_transaction extends ncsu_transaction;
   `ncsu_register_object(i2c_transaction)

   i2c_addr address;
   i2c_op_t op_type;
   i2c_data_array data;

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
      return {
         super.convert2string(), 
         $sformatf("Address:0x%x Type:%s Data: %p",
                   this.address,
                   this.op_type.name,
                   this.data)};
   endfunction
   
   function bit compare(i2c_transaction rhs);
      return ((this.address == rhs.address) &&
              (this.op_type == rhs.op_type) &&
              (this.data    == rhs.data));
   endfunction
endclass

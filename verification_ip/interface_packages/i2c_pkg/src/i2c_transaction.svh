class i2c_transaction extends ncsu_transaction;
   `ncsu_register_object(i2c_transaction)


   bit [6:0] slave_addr;
   bit [7:0] write_data;
   i2c_op_t  trans_mode;

   function new(string name="");
      super.new(name);
   endfunction

   virtual function string convert2string();
      return (super.convert2string(), 
         $sformatf("Slave Address:0x%x\nWrite Data: 0x%x\nOperation: %x"
         this.slave_addr,
         this.write_data,
         this.trans_mode));
   endfunction

   function bit compare(i2c_transaction rhs);
      return ((this.slave_addr == rhs.slave_addr) &&
              (this.trans_mode == rhs.trans_mode) &&
              (this.write_data == rhs.write_data) );
     endfunction
endclass

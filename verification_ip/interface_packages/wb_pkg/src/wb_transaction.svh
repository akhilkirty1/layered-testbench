class wb_transaction extends ncsu_transaction;
   `ncsu_register_object(wb_transaction)

   wb_addr address;
   wb_op_t op_type;
   wb_data data;

   function new(string name="");
      super.new(name);
   endfunction

   virtual function string convert2string();
      return {super.convert2string(), 
              $sformatf("Address:0x%x Type:%s Data:0x%x",
                        this.address,
                        this.op_type.name,
                        this.data)};
   endfunction
   
   function bit compare(wb_transaction rhs);
      return ((this.address == rhs.address) &&
              (this.op_type == rhs.op_type) &&
              (this.data    == rhs.data));
   endfunction
   
   function bit is_write();
     return (this.op_type == WRITE);
   endfunction 
endclass

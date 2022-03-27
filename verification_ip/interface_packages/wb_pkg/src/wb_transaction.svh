class wb_transaction extends ncsu_transaction;
   `ncsu_register_object(wb_transaction)

   bit [6:0] address;
   wb_op_t   op_type;
   bit [7:0]    data;

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
endclass

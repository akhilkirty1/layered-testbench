class wb_transaction extends ncsu_transaction;
   `ncsu_register_object(wb_transaction)

        bit [63:0] header, payload [8], trailer;
   rand bit [5:0]  delay;

   function new(string name="");
      super.new(name);
   endfunction

   virtual function string convert2string();
      return {super.convert2string(), $sformatf("header:0x%x
   endfunction

   function bit compare(wb_transaction rhs);
      return ((this.header  == rhs.header ) &&
              (this.payload == rhs.payload) &&
              (this.trailer == rhs.trailer) );
     endfunction
endclass

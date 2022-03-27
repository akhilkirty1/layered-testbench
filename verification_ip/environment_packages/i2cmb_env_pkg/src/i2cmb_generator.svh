// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(wb_transaction));
class generator extends ncsu_component#(.T(wb_transaction));

  wb_transaction transaction[10];
  ncsu_component #(T) agent;
  string trans_name;

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
  endfunction

  virtual task run();
    foreach (transaction[i]) begin  
      $cast(transaction[i], ncsu_object_factory::create(trans_name));
      assert (transaction[i].randomize());
      agent.bl_put(transaction[i]);
      $display({get_full_name()," ",transaction[i].convert2string()});
    end
    /*
    static bit [I2C_DATA_WIDTH-1:0] read_data = 0;
     
    // Wait 1000ns
    #1000
    
    iicmb_enable();

    // Wait 1000ns
    #1000

    // Start i2c slave
    fork i2c_slave_start(); join_none

    // Write 32 incrementing values, from 0 to 31, to the i2c_bus
    for (bit [I2C_DATA_WIDTH-1:0] data = 0; data < 32; data++)
      iicmb_write(0, 0, {data});
    
    // Wait 1000ns
    #1000
  
    // Read 32 values from the i2c_bus (return incrementing data from 100 to 131)
    repeat(32) iicmb_read(0, 0, read_data);
  
    // Wait 1000ns
    #1000

    // Alternate writes and reads for 64 transfers 
    for (integer i = 0; i < 64; i++) begin
      // increment write data from 64 to 127
      iicmb_write(0, 0, 64 + i);     // iicmb_write(bus_id, slave_addr, write_data)
      // decrement read data from 63 to 0
      iicmb_read(0, 0, read_data);   // iicmb_write(bus_id, slave_addr, read_data)
    end
    
    $finish;
    */
  endtask

  function void set_agent(ncsu_component #(T) agent);
    this.agent = agent;
  endfunction

endclass


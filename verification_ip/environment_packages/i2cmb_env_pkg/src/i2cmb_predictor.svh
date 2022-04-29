class i2cmb_predictor extends ncsu_component #(.T(wb_transaction));

   i2cmb_scoreboard scbd;
   i2cmb_generator  gen;
   i2cmb_env_configuration cfg;
   i2c_transaction prediction;

   // MOVE THESE TO COVERGROUP FOR PROJECT 4
   bit lose_arbitration = 1'b0;
   bit no_slave = 1'b0;
   bit no_ack = 1'b0;
   integer g_num_bus = 1;
   bit address_sent = 0;

   csr_reg csr;
   dpr_reg dpr;
   cmdr_reg cmdr;
   fsmr_reg fsmr;
   i2cmb_state curr_state = IDLE;
   integer byte_count = 0;
   bit irq = 0;

   //*****************************************************************
   // CONSTRUCTOR
   //*****************************************************************
  function new(string name = "", ncsu_component parent = null); 
     super.new(name, parent);
     prediction = new();
     reset_registers();
  endfunction 

   //*****************************************************************
   // SET CONFIRURATION
   //*****************************************************************
   function void set_configuration(i2cmb_env_configuration cfg);
      this.cfg = cfg;
   endfunction

   //*****************************************************************
   // SET SCOREBOARD
   //*****************************************************************
   virtual function void set_scoreboard(i2cmb_scoreboard scbd);
      this.scbd = scbd;
   endfunction

   //*****************************************************************
   // SET GENERATOR
   //*****************************************************************
   function void set_generator(i2cmb_generator gen);
      this.gen = gen;
   endfunction

   //*****************************************************************
   // NON-BLOCKING PUT
   //*****************************************************************
   virtual function void nb_put(T trans);
      // Display Original Transaction
      // $display({get_full_name()," ",trans.convert2string()});

      // Log Registers
      if (cfg.log_registers) log_registers();

      // Update Registers
      update_registers(trans);
   endfunction

   //*****************************************************************
   // READ PREDICTED REGISTERS
   //*****************************************************************
   // Returns the current value of a register
   function byte read_reg(i2cmb_reg register);
      case (register)
         CSR:  return byte'(csr);
         DPR:  return byte'(dpr);
         CMDR: return byte'(cmdr);
         FSMR: return byte'(fsmr);
      endcase
   endfunction
 
   //*****************************************************************
   // LOG REGISTERS
   //*****************************************************************
   function void log_registers();
      $display("CURRENT STATE: ");
      $display("curr_state = %s", curr_state.name);
      $display("");
      $display("CSR REGISTER");
      $display("csr.en = %b", csr.en);
      $display("csr.ie = %b", csr.ie);
      $display("csr.bb = %b", csr.bb);
      $display("csr.bc = %b", csr.bc);
      $display("csr.bid = %b", csr.bid);
      $display("");
      $display("DPR REGISTER");
      $display("dpr.data = %b", dpr.data);
      $display("");
      $display("CMDR REGISTER");
      $display("cmdr.don = %b", cmdr.don);
      $display("cmdr.nak = %b", cmdr.nak);
      $display("cmdr.al  = %b", cmdr.al);
      $display("cmdr.err = %b", cmdr.err);
      $display("cmdr.r   = %b", cmdr.r);
      $display("cmdr.cmd = %s", cmdr.cmd.name);
      $display("");
      $display("FSMR REGISTER");
      $display("fsmr.byte_fsm = %b", fsmr.byte_fsm);
      $display("fsmr.bit_fsm = %b", fsmr.bit_fsm);
      $display("");
   endfunction

   //*****************************************************************
   // FUNCTIONS TO UPDATE REGISTERS
   //*****************************************************************
   function void update_registers(wb_transaction trans);
      // Handle Writes to Non-CMDR Registers
      if (trans.is_write()) begin
         case (trans.address)
            CSR:   write_csr(trans);
            DPR:   write_dpr(trans);
            CMDR:  write_cmdr(trans);
            FSMR:  write_fsmr(trans);
         endcase
      end else begin
         case (trans.address)
            CMDR: read_csr();
            DPR:  read_dpr();
            CMDR: read_cmdr();
            FSMR: read_fsmr();
         endcase
      end
   endfunction

   //*****************************************************************
   // FUNCTIONS TO WRITE TO REGISTERS
   //*****************************************************************
   function void write_csr(wb_transaction trans);
      csr.en = trans.data[7];
      csr.ie = trans.data[6];
   endfunction

   function void write_dpr(wb_transaction trans);
      dpr.data = trans.data;
   endfunction
   
   function void write_cmdr(wb_transaction trans);
      cmdr.don = trans.data[7];
      cmdr.nak = trans.data[6];
      cmdr.cmd = i2cmb_cmd'(trans.data[2:0]);

      run_byte_level_command();
   endfunction
 
   function void write_fsmr(wb_transaction trans);
   endfunction
   
   //*****************************************************************
   // FUNCTIONS TO READ FROM REGISTERS
   //*****************************************************************
   function void read_csr;
      dpr = dpr_reg'(csr);
   endfunction

   function void read_dpr;
      dpr = dpr_reg'(dpr);
      if (csr.ie) irq = 1'b1;
   endfunction
   
   function void read_cmdr;
      dpr = dpr_reg'(cmdr);
      irq = 1'b0;
   endfunction
   
   function void read_fsmr();
      dpr = dpr_reg'(fsmr);
   endfunction

   //*****************************************************************
   // RUN BYTE LEVEL COMMAND
   //*****************************************************************
   function void run_byte_level_command();
      i2c_transaction tmp_pred;
      
      // break if not enabled
      if (!csr.en) return;
      
      // clear status bits
      cmdr.don = 0;
      cmdr.nak = 0;
      cmdr.al  = 0;
      cmdr.err = 0;

      // set interrupt
      if (csr.ie) irq = 1'b1;

      // run command
      case (curr_state)
         IDLE: begin
            
            csr.bc = 0;
            address_sent = 0;

            // handle commands
            case (cmdr.cmd)
              
               START:  begin
                  // return arbitration lost if needed
                  if (lose_arbitration) begin
                     cmdr.al = 1;
                  end
                  
                  // else return done and capture bus
                  else begin
                     cmdr.don = 1;
                     curr_state = BUS_TAKEN;
                  end
               end

               SET_BUS: 
                  // Return error if bus doesn't exist
                  if (dpr.data > (g_num_bus - 1)) cmdr.err = 1; 
                  
                  // Else return done and update bid
                  else begin
                     csr.bid = dpr.data; 
                     cmdr.don = 1; 
                  end
               
               // Return done
               WAIT: cmdr.don = 1;

               // Return error
               default: begin cmdr.err = 1; end
            endcase
         end

         BUS_TAKEN: begin

            // declare that the bus was captured
            csr.bc = 1;

            // handle commands
            case (cmdr.cmd)
              
               START:  begin
                  if (lose_arbitration) cmdr.al = 1;
                  else cmdr.don = 1;
                  
                  // reset flags
                  address_sent = 0;
               end
               
               STOP: begin
                  curr_state = IDLE;
                  cmdr.don = 1;
               end
                 
               WRITE: begin
                  prediction.op = i2c_pkg::WRITE;
                  if (lose_arbitration) begin
                     cmdr.al = 1;
                     curr_state = IDLE;
                  end else if (address_sent && !no_ack) begin
                     prediction.data = dpr.data;
                     scbd.nb_transport(prediction, tmp_pred);
                     cmdr.don = 1;
                  end else if (!address_sent && !no_slave) begin
                     prediction.addr = dpr.data[I2C_ADDR_WIDTH:1];
                     address_sent = 1;
                     cmdr.don = 1;
                  end else begin 
                     cmdr.err = 1;
                     curr_state = IDLE;
                  end
               end

               READ_WITH_ACK: begin
                  prediction.op = i2c_pkg::READ;
                  if (lose_arbitration) begin
                     cmdr.al = 1;
                     curr_state = IDLE;
                  end else if (address_sent && !no_ack) begin
                     prediction.data = gen.p1_agent.driver.provide_data;
                     scbd.nb_transport(prediction, tmp_pred);
                  end else begin 
                     cmdr.err = 1;
                     curr_state = IDLE;
                  end
               end

               READ_WITH_NAK: begin
                  prediction.op = i2c_pkg::READ;
                  if (lose_arbitration) begin
                     cmdr.al = 1;
                     curr_state = IDLE;
                  end else if (address_sent) begin
                     prediction.data = gen.p1_agent.driver.provide_data;
                     scbd.nb_transport(prediction, tmp_pred);
                  end else begin 
                     cmdr.err = 1;
                     curr_state = IDLE;
                  end
               end

               // Return error
               default: begin cmdr.err = 1; end
            endcase
         end
      endcase
   endfunction

   //*****************************************************************
   // RESTET REGISTERS
   //*****************************************************************
   function void reset_registers;
      // CSR
      csr.en  = 0; 
      csr.ie  = 0; 
      csr.bb  = 0; 
      csr.bc  = 0; 
      csr.bid = 0; 

      // DPR
      dpr.data = 0; 
      
      // CMDR
      cmdr.don = 1; 
      cmdr.nak = 0; 
      cmdr.al  = 0; 
      cmdr.err = 0; 
      cmdr.r   = 0; 
      cmdr.cmd = i2cmb_cmd'(0); 
      
      // FSMR
      fsmr.byte_fsm = 0;
      fsmr.bit_fsm  = 0;
   endfunction
endclass

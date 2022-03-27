class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
  function new(string name = "", ncsu_component #(T) parent = null);
     super.new(name, parent);
  endfunction

  T trans_in;
  T trans_out;

  virtual function void nb_transport(input T in_trans, output T out_trans);
    $display({get_full_name(),
              " nb_transport: expected transaction ",
              in_trans.convert2string()});
    this.trans_in = in_trans;
    out_trans = trans_out;
  endfunction

  virtual function void nb_put(T trans);
    $display({get_full_name(),
              " nb_put: actual transaction ",
              trans.convert2string()});
    if (this.trans_in.compare(trans))
      $display({get_full_name(),   " transaction MATCH!"});
    else $display({get_full_name(), " transaction MISMATCH!"});
  endfunction
endclass

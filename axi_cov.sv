class axi_cov extends uvm_subscriber#(axi_tx);
  `uvm_component_utils(axi_cov)
  axi_tx tx;
  int idx;


  covergroup axi_cg;
    
    wr_wrpcp: 		coverpoint tx.wr_rd ;
    
    addr_cp:  		coverpoint tx.addr {
      			option.auto_bin_max = 8;}
      
    burst_len_cp: 	coverpoint tx.burst_len;

    burst_type_cp: 	coverpoint tx.burst_type {
      bins FIXED = {2'b00};
      bins INCR = {2'b01};
      bins WRAP = {2'b10};
      bins RSVD_B_TYPE = default;}

    burst_size_cp: 	coverpoint tx.burst_size {
      bins SIZE_1B 	= {3'b000};
      bins SIZE_2B 	= {3'b001};
      bins SIZE_4B 	= {3'b010};
      bins SIZE_8B 	= {3'b011};
      bins SIZE_16B = {3'b100};
      bins SIZE_32B = {3'b101};
      bins SIZE_64B = {3'b110};
      bins SIZE_128B= {3'b111};
      //bins IGNORE = default;
    }
    
    id_cp:  coverpoint tx.tx_id;
    
   	lock_cp: 		coverpoint tx.lock {
      bins NORMAL = {2'b00};
      bins EXCL = {2'b01};
      bins LOCKED= {2'b10};
      bins RSVD_LOCK = {2'b11};
    }
    endgroup
  
covergroup resp_cg (ref int idx);

  rd_wr_resp_cp: coverpoint tx.respQ[idx] {
    bins OKAY   = {2'b00};
    bins EXOKAY = {2'b01};
    bins SLVERR = {2'b10};
    bins DECERR = {2'b11};
  }

endgroup

  function new (string name, uvm_component parent);
    super.new(name, parent);
    axi_cg=new();
    resp_cg = new(idx);
  endfunction

  function void write (axi_tx t);
    tx = new t; 
    axi_cg.sample();
    
      if (tx.wr_rd == 1) begin
    idx = 0;
    resp_cg.sample();
  end
  else begin
    foreach (tx.respQ[i]) begin
      idx = i;
      resp_cg.sample();
    end
  end
    
  endfunction
  
  endclass
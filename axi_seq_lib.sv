class axi_base_seq extends uvm_sequence#(axi_tx);
  `uvm_object_utils(axi_base_seq)
  `NEW_OBJ

  uvm_phase phase;
  axi_tx tx;
  axi_tx txQ[$];

  task pre_body();
    phase = get_starting_phase();
    if(phase!=null) begin
      phase.raise_objection(this);
      phase.phase_done.set_drain_time(this,100);
    end
  endtask 

  task post_body();
    if(phase!=null) begin
      phase.drop_objection(this);
    end
  endtask 

endclass

class axi_n_wr_n_rd_seq extends axi_base_seq;

  int count;
  `uvm_object_utils(axi_n_wr_n_rd_seq)
  `NEW_OBJ
  //test class will tell the count of read and write transations to be created

  task body();

    uvm_resource_db#(int)::read_by_name("GLOBAL","COUNT", count, this);

    //write transactions
    repeat(count) begin
      `uvm_do_with(req,{req.wr_rd==1;})
      tx = new req;
      txQ.push_back(tx);
    end

    //read transactions
    repeat(count) begin
      tx = txQ.pop_front();
      `uvm_do_with(req,{req.wr_rd==0;
                        req.addr ==tx.addr;
                        req.burst_len == tx.burst_len;
                        req.burst_size == tx.burst_size;
                        req.burst_type == tx.burst_type;
                        req.lock == tx.lock;
                        req.cache == tx.cache;
                        req.prot == tx.prot;})//read must have the same request phase field data as the write
    end

  endtask
endclass


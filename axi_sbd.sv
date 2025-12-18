`uvm_analysis_imp_decl(_master)
	//uvm_nalysis_imp_m -> User defined TLM class
	//monitor from the master and the slave call call the write method in scoreboard
`uvm_analysis_imp_decl(_slave)

class axi_sbd extends uvm_scoreboard;
  
  axi_tx master_txQ[$];
  axi_tx slave_txQ[$];
  axi_tx m_tx;
  axi_tx s_tx;
  
  uvm_analysis_imp_master#(axi_tx, axi_sbd) imp_master;
  uvm_analysis_imp_slave#(axi_tx, axi_sbd) imp_slave;
  
  `uvm_component_utils(axi_sbd)
  `NEW_COMP
  
  function void build();
    imp_master = new("imp_master",this);
    imp_slave = new("imp_slave",this);
  endfunction 
  
  function void write_master (axi_tx tx);
    master_txQ.push_back(tx);
  endfunction 
  
  function void write_slave(axi_tx tx);
    slave_txQ.push_back(tx);
  endfunction 
  
  task run();
    forever begin 
      //wait for both queue to have atleast one item.
      wait(master_txQ.size()>0);
      wait(slave_txQ.size()>0);
      m_tx=master_txQ.pop_front();
      s_tx=slave_txQ.pop_front();
      
      if (m_tx.compare(s_tx)) begin
        `uvm_info("TX Compare","Compare Passed", UVM_MEDIUM)
        axi_common::num_matches++;
      end
      
      else begin 
        `uvm_info("TX Compare", "Compared Failed", UVM_MEDIUM)
        axi_common::num_mismatches++;
      end
    end
    
  endtask
  
endclass


`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class axi_sbd_byte extends uvm_scoreboard;

  `uvm_component_utils(axi_sbd_byte)
  `NEW_COMP
  
  byte mem[*];

  uvm_analysis_imp_master#(axi_tx, axi_sbd_byte) imp_master;
  uvm_analysis_imp_slave#(axi_tx, axi_sbd_byte) imp_slave;

  function void build();
    imp_master = new("imp_master",this);
    imp_slave = new("imp_slave",this);
  endfunction 

  function void write_master (axi_tx tx);
    axi_tx local_tx = new tx;
    if (local_tx.wr_rd ==1) begin 
      foreach(local_tx.dataQ[i]) begin
        mem[local_tx.addr]=local_tx.dataQ[i][7:0];
        mem[local_tx.addr+1]=local_tx.dataQ[i][15:8];
        mem[local_tx.addr+2]=local_tx.dataQ[i][23:16];
        mem[local_tx.addr+3]=local_tx.dataQ[i][31:24];
        local_tx.addr+=4;
      end

    end
  endfunction

  function void write_slave(axi_tx tx);
   axi_tx local_tx = new tx;
    if (local_tx.wr_rd==0) begin 
      foreach(local_tx.dataQ[i]) begin
        if (mem[local_tx.addr]==local_tx.dataQ[i][7:0] &&
            mem[local_tx.addr+1]==local_tx.dataQ[i][15:8] &&
            mem[local_tx.addr+2]==local_tx.dataQ[i][23:16] &&
            mem[local_tx.addr+3]==local_tx.dataQ[i][31:24]) begin
          
          `uvm_info("BEAT_COMP","Read data from slave match thewrite data",UVM_MEDIUM)
           axi_common::num_matches++;
        end
        else begin
          `uvm_error("TX_COMPARE",
                     $psprintf("Read mismatch at addr %0h. Expected = %02h %02h %02h %02h Actual   = %08h", local_tx.addr,mem[local_tx.addr+3], mem[local_tx.addr+2], mem[local_tx.addr+1], mem[local_tx.addr], local_tx.dataQ[i]))
           axi_common::num_mismatches++;

        end
        local_tx.addr+=4;
      end 
    end 
  endfunction 


endclass
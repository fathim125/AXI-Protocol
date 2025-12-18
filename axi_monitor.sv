class axi_mon extends uvm_monitor;
  `uvm_component_utils(axi_mon)
  `NEW_COMP
  uvm_analysis_port#(axi_tx) analysis_port;
  virtual axi_intr vif;
  axi_tx rd_tx;
  axi_tx wr_tx;


  function void build ();
    analysis_port = new("analysis_port",this);
    if(!uvm_resource_db#(virtual axi_intr)::read_by_name("GLOBAL","AXI_VIF", vif, this)) begin 
      `uvm_error("RSC_DB_MONITOR","Not able to retrieve AXI interface")
    end
  endfunction 

  task run();
    `uvm_info("MONITOR","Inside the run task of monitor",UVM_MEDIUM)
    forever begin 
      @(posedge vif.aclk);
      if(vif.awvalid && vif.awready) begin 
        wr_tx = axi_tx::type_id::create("wr_tx");
        wr_tx.wr_rd = 1'b1;
        wr_tx.addr = vif.awaddr;
        wr_tx.tx_id = vif.awid;
        wr_tx.burst_len = vif.awlen ;
        wr_tx.burst_type = vif.awburst ;
        wr_tx.burst_size = vif.awsize;
        wr_tx.lock = vif.awlock;
        wr_tx.cache = vif.awcache;
       end
      
      if(vif.wvalid && vif.wready) begin 
        wr_tx.dataQ.push_back(vif.wdata);
        wr_tx.strbQ.push_back(vif.wstrb);
      end
      
      if(vif.bvalid && vif.bready) begin 
        wr_tx.respQ.push_back(vif.bresp);
        analysis_port.write(wr_tx);
      end
      
      if(vif.arvalid && vif.arready) begin
        rd_tx = axi_tx::type_id::create("rd_tx");
        rd_tx.wr_rd = 1'b0;
        rd_tx.addr = vif.araddr;
        rd_tx.tx_id = vif.arid;
        rd_tx.burst_len = vif.arlen ;
        rd_tx.burst_type = vif.arburst ;
        rd_tx.burst_size = vif.arsize;
        rd_tx.lock = vif.arlock;
        rd_tx.cache = vif.arcache;
      end
      
      if(vif.rvalid && vif.rready) begin 
        rd_tx.dataQ.push_back(vif.rdata);
        rd_tx.respQ.push_back(vif.rresp);
        if (vif.rlast) 
          analysis_port.write(rd_tx);//there might be a beat required
      end
    end 
  endtask 

endclass

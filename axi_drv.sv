class axi_drv extends  uvm_driver#(axi_tx);

  virtual axi_intr vif;
  //axi_tx tx;

  `uvm_component_utils(axi_drv)
  `NEW_COMP

  function void build ();
   // tx = axi_tx::type_id::create("tx",this);
    if (!uvm_resource_db#(virtual axi_intr)::read_by_name("GLOBAL","AXI_VIF", vif, this)) begin
      `uvm_error("RSC_DB_DRIVER","Not able to retrieve AXI interface")
    end
  endfunction

  task run();
    forever begin 
      seq_item_port.get_next_item(req);//why req and not tx?
      drive_tx(req);
      seq_item_port.item_done();
    end 
  endtask

  task drive_tx(axi_tx req);
    `uvm_info("DRIVER","driving trasactions according to AXI protocol",UVM_MEDIUM)

    if(req.wr_rd==1) begin 
      wr_addr_phase(req);
      wr_data_phase(req);
      wr_resp_phase(req);
    end
    else begin 
      rd_addr_phase(req);
      rd_data_phase(req);
    end
  endtask

  task wr_addr_phase(axi_tx req);
   
      @(posedge vif.aclk)
      //check te inferace for alllthe signals the signals the master need to give the slace in write address phase
      vif.awaddr = req.addr;
      vif.awid = req.tx_id;
      vif.awlen = req.burst_len;
      vif.awburst = req.burst_type;
      vif.awsize = req.burst_size;
      vif.awlock = req.lock;
      vif.awcache = req.cache;
      vif.awvalid = 1'b1;
      wait (vif.awready == 1);
      @(posedge vif.aclk)
      reset_wr_addr_channel();
     
  endtask

  task reset_wr_addr_channel();
    vif.awaddr = 0;
    vif.awid = 0;
    vif.awlen = 0;
    vif.awburst = 0;
    vif.awsize = 0;
    vif.awlock = 0;
    vif.awcache = 0;
    vif.awvalid = 0;
  endtask

  task wr_data_phase(axi_tx req);
    for ( int i=0 ; i <= req.burst_len; i++ ) begin
      @(posedge vif.aclk)
      vif.wid = req.tx_id;
      vif.wdata = req.dataQ.pop_front();
      vif.wstrb = req.strbQ.pop_front();
      vif.wvalid = 1;
      vif.wlast = ( i == req.burst_len ) ?  1 : 0;
      wait ( vif.wready == 1 );
      @(posedge vif.aclk)
      reset_wr_data_channel();
    end
  endtask 

  task reset_wr_data_channel();
    vif.wid=0;
    vif.wdata=0;
    vif.wstrb=0;	
    vif.wlast=0;
    vif.wvalid=0;
  endtask

  task wr_resp_phase(axi_tx req);
    @(posedge vif.aclk) begin
      if(vif.bvalid==1)
        vif.bready=1;
      @(posedge vif.aclk)
      vif.bready=0;
    end
  endtask

  task  rd_addr_phase(axi_tx req);
      @(posedge vif.aclk)
      vif.araddr = req.addr;
      vif.arid = req.tx_id;
      vif.arlen = req.burst_len;
      vif.arburst = req.burst_type;
      vif.arsize = req.burst_size;
      vif.arlock = req.lock;
      vif.arcache = req.cache;
      vif.arvalid = 1'b1;
      wait (vif.arready == 1);
      @(posedge vif.aclk)
      reset_rd_addr_channel();
  endtask

  task reset_rd_addr_channel();
    vif.araddr = 0;
    vif.arid = 0;
    vif.arlen = 0;
    vif.arburst = 0;
    vif.arsize = 0;
    vif.arlock = 0;
    vif.arcache = 0;
    vif.arvalid = 0;
  endtask

  task rd_data_phase(axi_tx req);
    `uvm_info("DRIVER","inside rd_data_phase ",UVM_MEDIUM)
    for(int i=0;i<=req.burst_len;i++) begin
      @(posedge vif.aclk)
      if (vif.rvalid==1) begin
		vif.rready=1;
     @(posedge vif.aclk)
      vif.rready=0; //what happends when we get rvalid for 2 consecutive cycles?

    end
    end
  endtask

endclass


class axi_rsp extends uvm_component;
  `uvm_component_utils(axi_rsp)
  `NEW_COMP	
  virtual axi_intr vif;
  axi_tx rd_tx;
  axi_tx wr_tx;
  
  reg [31:0] mem[*];
  bit [31:0]  fixed_tx[$];
  
  function void build ();
    if(!uvm_resource_db#(virtual axi_intr)::read_by_name("GLOBAL","AXI_VIF", vif, this)) begin 
      `uvm_error("RSC_DB_REPSONDER","Not able to retrieve AXI interface")
    end
  endfunction 

  task run();
    `uvm_info("RESPONDER","Inside the run task of responder",UVM_MEDIUM)
    forever begin 
      @(posedge vif.aclk);
      if (vif.awvalid==1) begin 
        vif.awready=1;
        //store all the addr phase info of the transaction so that we can use them in the data and resp phase.
        wr_tx=new("wr_tx");
        wr_tx.addr=vif.awaddr;
        wr_tx.tx_id=vif.awid;
        wr_tx.burst_len=vif.awlen; 				
        wr_tx.burst_type=vif.awburst; 			 
        wr_tx.burst_size=vif.awsize;
        wr_tx.lock=vif.awlock;	 
        wr_tx.cache=vif.awcache;
        wr_tx.prot=vif.awprot;
        wr_tx.calculate_wrap_range();
        @(posedge vif.aclk);
        vif.awready=0;
      end
      if (vif.wvalid==1) begin
        vif.wready=1; 
        wr_data_phase(wr_tx);
        if (vif.wlast==1) begin 
          wr_resp_phase(vif.wid);
        end

        @(posedge vif.aclk);
        vif.wready=0;
      end
      if (vif.arvalid==1) begin
        vif.arready=1;
        rd_tx=new("rd_tx");
        rd_tx.addr=vif.araddr;
        rd_tx.tx_id=vif.arid;
        rd_tx.burst_len=vif.arlen; 				
        rd_tx.burst_type=vif.arburst; 			 
        rd_tx.burst_size=vif.arsize;
        rd_tx.lock=vif.arlock;	 
        rd_tx.cache=vif.arcache;
        rd_tx.prot=vif.arprot;
        rd_tx.calculate_wrap_range();
        @(posedge vif.aclk);
        vif.arready=0;
        rd_data_phase(rd_tx);

      end
    end
  endtask 

task wr_data_phase(axi_tx tx);
  if (tx.burst_type != FIXED ) begin
    int next_addr;
    mem[tx.addr]=vif.wdata;
    next_addr = tx.addr + 2**tx.burst_size;
    `uvm_info("WRITE",$psprintf("addr = %0h, data = %0h", tx.addr, mem[tx.addr] ), UVM_MEDIUM)
    if(tx.burst_type==WRAP && next_addr > tx.wrap_upper_addr)
      tx.addr = tx.wrap_lower_addr;
    else 
      tx.addr = next_addr; 
  end
  else begin

    fixed_tx.push_back(vif.wdata);
   `uvm_info("WRITE",$psprintf("addr = %0h, data = %0h", tx.addr, vif.wdata ), UVM_MEDIUM)

  end
endtask

  task wr_resp_phase(bit [3:0] id);
    vif.bid=id;
    @(posedge vif.aclk)
    vif.bresp = OKAY;
    vif.bvalid = 1;
    wait( vif.bready == 1 ); 
    @(posedge vif.aclk)
    reset_wr_resp_channel();
  endtask

  task reset_wr_resp_channel();
    vif.bid=0;
    vif.bresp=0; // OKAY,EXOKAY,SLVERR,DECERR
    vif.bvalid=0;
  endtask

  task rd_data_phase(axi_tx rd_tx);
    int next_addr;
    for(int i=0;i<=rd_tx.burst_len;i++) begin
      @(posedge vif.aclk)
      vif.rid=rd_tx.tx_id;
      
      if (rd_tx.burst_type != FIXED ) begin
        vif.rdata=mem[rd_tx.addr];
        next_addr=rd_tx.addr+2**rd_tx.burst_size;
        `uvm_info("READ",$psprintf("addr = %0h, data = %0h", rd_tx.addr, mem[rd_tx.addr]) , UVM_MEDIUM)

        if (rd_tx.burst_type == WRAP && next_addr >= rd_tx.wrap_upper_addr) 
          rd_tx.addr = rd_tx.wrap_lower_addr; 
        else begin
          rd_tx.addr=next_addr;
        end
      end
      else begin 
          vif.rdata = fixed_tx.pop_front();
         `uvm_info("READ",$psprintf("addr = %0h, data = %0h", rd_tx.addr, vif.rdata) , UVM_MEDIUM)

      end 
      
      vif.rlast=(i==rd_tx.burst_len)? 1:0;
      vif.rvalid=1;
      wait(vif.rready==1);
    end
     @(posedge vif.aclk)
      reset_rd_data_channel();
  endtask

  task reset_rd_data_channel();
    vif.rid=0;
    vif.rdata=0;
    vif.rlast=0;
    vif.rvalid=0;
  endtask
  
endclass






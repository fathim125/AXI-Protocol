class axi_slave_agent extends uvm_agent;
  axi_mon mon;
  axi_rsp rsp;
  `uvm_component_utils(axi_slave_agent)
  `NEW_COMP
  
  function void build();
    mon = axi_mon::type_id::create("mon",this);
    rsp = axi_rsp::type_id::create("rsp",this);
  endfunction

endclass
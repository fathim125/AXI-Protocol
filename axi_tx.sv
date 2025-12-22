class axi_tx extends uvm_sequence_item;

  // Selecting read/white
  rand bit wr_rd;

  // Request phase fields
  rand bit [31:0] addr;
  rand bit [3:0] tx_id;
  rand bit [3:0] burst_len;
  rand burst_type_t burst_type; // there are 3 types
  rand bit [2:0] burst_size;
  rand bit [1:0] lock;		 // there are 3 types
  rand bit [3:0] cache;
  rand bit [2:0] prot;

  // Data phase fields
  rand bit [31:0] dataQ[$];	// becasue we want mutiple data transfers, and its a variable.
  rand bit [3:0] strbQ[$];	// we can also use dynamic array, 
  // but this is easier to work with it has more methods
  // Response phase fields
  rand bit [1:0] respQ[$];	// even though write requires only one res per, for read it required mutiple

  `uvm_object_utils_begin(axi_tx)
  `uvm_field_int(wr_rd, UVM_ALL_ON)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(tx_id, UVM_ALL_ON)
  `uvm_field_int(burst_len, UVM_ALL_ON)
  `uvm_field_enum(burst_type_t, burst_type, UVM_ALL_ON)
  `uvm_field_int(burst_size, UVM_ALL_ON)
  `uvm_field_int(lock, UVM_ALL_ON)
  `uvm_field_int(cache, UVM_ALL_ON)
  `uvm_field_int(prot, UVM_ALL_ON)

  `uvm_field_queue_int(dataQ, UVM_ALL_ON)
  `uvm_field_queue_int(strbQ, UVM_ALL_ON)

  `uvm_field_queue_int(respQ, UVM_ALL_ON)
  `uvm_object_utils_end
  `NEW_OBJ

  rand bit [31:0] wrap_upper_addr;
  rand bit [31:0] wrap_lower_addr;
  
  function void post_randomize();
    if(wr_rd==0)
      axi_common::total_beats += burst_len +1;
  endfunction

  // Constraints
  constraint rsvd_c {
    burst_type!=2'b11;
    lock!=2'b11;
  }
  constraint dataQ_c{ // is this gonna be chanched at the end, 
    // cause after each transfer or the transaction the size is gonna change right?
    dataQ.size() == burst_len+1;
    strbQ.size() == burst_len+1;
    foreach (strbQ[i]){
      soft strbQ[i]== 4'hF;}
  }
      constraint soft_c{
       // soft burst_type == INCR;
        soft burst_size == 2; // 4bytes/beat
        soft addr%(2**burst_size) ==0; // aligned transfer
      }  

      constraint wrap_c{
        (burst_type == WRAP) -> ((addr%(2**burst_size) ==0) && (burst_len inside {1,3,7,15}));
      }

    function void calculate_wrap_range();
    	int tx_size;
    
    	tx_size = (2**burst_size) * (burst_len + 1);
    	wrap_lower_addr = addr - (addr%tx_size);
    	wrap_upper_addr = wrap_lower_addr + tx_size - 1;
    
    	$display("addr = %h", addr);
        $display("wrap_lower_addr = %h", wrap_lower_addr);
        $display("wrap_upper_addr = %h", wrap_upper_addr);


    endfunction
    endclass

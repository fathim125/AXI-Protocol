class axi_base_test extends uvm_test;
  uvm_phase phase;//my additoion
  axi_env env;

  `uvm_component_utils(axi_base_test)
  `NEW_COMP

  function void build();
    env = axi_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration();
    uvm_top.print_topology();
    factory.print();
  endfunction

  function void report();
    if(axi_common::num_matches == axi_common::total_beats
       && axi_common::num_mismatches == 0) begin 
      `uvm_info("Status",$psprintf("%s Test Passed, num_beats = %0d, num_matches = %0d , num_mismatches%0d", get_type_name(),axi_common::total_beats, axi_common::num_matches, axi_common::num_mismatches ), UVM_MEDIUM)
    end

    else begin 
      `uvm_error("Status",$psprintf("%s Test Failed, num_beats = %0d, num_matches = %0d , num_mismatches = %0d", get_type_name(), axi_common::total_beats, axi_common::num_matches, axi_common::num_mismatches))
    end
  endfunction
endclass

class axi_wr_rd_test extends axi_base_test;
  `uvm_component_utils(axi_wr_rd_test)
  `NEW_COMP

  function void build();
    super.build();
    uvm_resource_db#(int)::set("GLOBAL","COUNT", axi_common::total_transaction, this);
  endfunction

  task run_phase(uvm_phase phase);

    axi_n_wr_n_rd_seq wr_rd_seq;
    wr_rd_seq = axi_n_wr_n_rd_seq::type_id::create("wr_rd_seq");

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 100);
    wr_rd_seq.start(env.m_agent.sqr);
    phase.drop_objection(this);

  endtask
endclass 
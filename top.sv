//`include "uvm_pkg.sv"
import uvm_pkg::*;

`include "axi_common.sv"
`include "axi_tx.sv"
`include "axi_intr.sv"
`include "axi_cov.sv"
`include "axi_drv.sv"
`include "axi_monitor.sv"
`include "axi_sqr.sv"
`include "axi_responder.sv"
`include "axi_master_agent.sv"
`include "axi_slave_agent.sv"
`include "axi_sbd_byte.sv"
`include "axi_env.sv"
`include "axi_seq_lib.sv"
`include "test_library.sv"

module top;

  bit clk;
  bit rst;

  axi_intr intr(clk,rst);

  initial begin
    uvm_resource_db#(virtual axi_intr)::set("GLOBAL","AXI_VIF", intr, null);
  end 

  initial begin 
    clk=0;
    forever #5 clk = ~clk;
  end

  initial begin 
    rst=1;
    repeat(2) @(posedge clk);
    rst=0;
  end 

  initial begin
    run_test("axi_wr_rd_test");  
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  //assertion module instatiation needed
endmodule 




`define NEW_COMP \
function new(string name = "", uvm_component parent = null); \
  super.new(name,parent); \
endfunction

`define NEW_OBJ \
function new(string name=""); \
  super.new(name); \
endfunction

uvm_factory factory = uvm_factory::get();

typedef enum bit [1:0] {
  FIXED,
  INCR,
  WRAP,
  RSVD_TYPE
} burst_type_t;

typedef enum bit [1:0] {
  NORMAL,
  EXCL,
  LOCKED,
  RSVD_LOCK
} lock_t;

typedef enum bit [1:0] {
  OKAY,
  EXOKAY,
  SLVERR,
  DECERR
} resp_t;

class axi_common;
  static int num_matches;
  static int num_mismatches;
  static int total_transaction=3;
  static int total_beats;
endclass
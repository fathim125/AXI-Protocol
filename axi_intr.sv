interface axi_intr(input bit aclk, arst);

  //write 
  //request phase fields
  bit [31:0]awaddr;
  bit [3:0] awid;
  bit [3:0] awlen;
 // bit [1:0] awburst; 			//FIXED,INCR,WRAP,Reserved
  burst_type_t awburst;
  bit [2:0] awsize;
  bit [1:0] awlock;			//Normal,Exclusive,Locked,Reserved
  bit [3:0] awcache;
  bit [2:0] awprot;
  bit 		awvalid;
  bit 		awready;

  //data phase fields
  bit [3:0] 	wid;
  bit [31:0] 	wdata;
  bit [3:0] 	wstrb;	
  bit 			wlast;
  bit 			wvalid;
  bit 			wready;	
  //response phase fields
  bit [3:0] 	bid; 
  bit [1:0]		bresp; //OKAY,EXOKAY,SLVERR,DECERR
  bit 			bvalid;
  bit 			bready;  

  //read 
  //request phase fields
  bit [31:0]araddr;
  bit [3:0] arid;				// 
  bit [3:0] arlen; 				// arlen+1=16 transfer allows at a time
  
 //bit [1:0] arburst; 			// FIXED,INCR,WRAP,Reserved
 burst_type_t arburst;
  bit [2:0] arsize;
  bit [1:0] arlock;				// Normal, Exclusive, Locked, Reserved
  bit [3:0] arcache;
  bit [2:0] arprot;
  bit 		arvalid;
  bit 		arready;

  //data phase fields
  bit [3:0] 	rid;
  bit [31:0] 	rdata;
  bit [3:0] 	rstrb;	
  bit 			rlast;
  bit 			rvalid;
  bit 			rready;	
  bit [1:0]		rresp;//OKAY,EXOKAY,SLVERR,DECERR

  //clocking block
endinterface
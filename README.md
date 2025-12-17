# AXI Protocol - Universal Verification Component 

This project implements a complete **AXI Universal Verification Component (UVC)** and UVM testbench to verify AXI master–slave protocol behavior. It includes full development of transactions, interface, driver, responder, sequencer, monitor, scoreboard, functional coverage, and integration into an SoC-level testbench.

---

## Project Overview
The goal of this project is to build a reusable AXI UVC capable of driving, monitoring, and checking AXI protocol activity across all five AXI channels.  
The UVC supports multiple burst types, narrow transfers, overlapping/out-of-order/interleaved transactions, and protocol correctness checks using functional coverage and scoreboard-based comparison.

---

## Key Features
- Complete **AXI UVC architecture** following UVM 1.2 methodology  
- AXI Master and AXI Slave agents  
- Supports **INCR, FIXED, WRAP** bursts  
- Supports **narrow transfers** and byte-level strobes  
- Verification of **overlapping, out-of-order, and interleaved** transactions  
- Directed and constrained-random sequences  
- Functional coverage for burst type, size, length, address alignment, and response codes  
- Scoreboard for transaction-level checking  
- Integration into **SoC-level testbench**  
- Designed for **VCS + Verdi**

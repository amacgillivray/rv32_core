//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (win64) Build 2729669 Thu Dec  5 04:49:17 MST 2019
//Date        : Sun Oct 30 10:48:08 2022
//Host        : ENGR-G8DMVD3 running 64-bit major release  (build 9200)
//Command     : generate_target jump_target_addr.bd
//Design      : jump_target_addr
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "jump_target_addr,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=jump_target_addr,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "jump_target_addr.hwdef" *) 
module jump_target_addr
   (Immediate_0,
    Immediate_1,
    IsJalr_0,
    PC_0,
    Rd1_0,
    jump_target_0);
  input [31:0]Immediate_0;
  input [31:0]Immediate_1;
  input IsJalr_0;
  input [31:0]PC_0;
  input [31:0]Rd1_0;
  output [31:0]jump_target_0;

  wire [31:0]Immediate_0_1;
  wire [31:0]Immediate_1_1;
  wire IsJalr_0_1;
  wire [31:0]PC_0_1;
  wire [31:0]Rd1_0_1;
  wire [31:0]branch_addr_0_branch_address;
  wire [31:0]id_mux_0_jump_target;
  wire [31:0]jalr_0_jalr;

  assign Immediate_0_1 = Immediate_0[31:0];
  assign Immediate_1_1 = Immediate_1[31:0];
  assign IsJalr_0_1 = IsJalr_0;
  assign PC_0_1 = PC_0[31:0];
  assign Rd1_0_1 = Rd1_0[31:0];
  assign jump_target_0[31:0] = id_mux_0_jump_target;
  jump_target_addr_branch_addr_0_0 branch_addr_0
       (.Immediate(Immediate_1_1),
        .PC(PC_0_1),
        .branch_address(branch_addr_0_branch_address));
  jump_target_addr_id_mux_0_0 id_mux_0
       (.IsJalr(IsJalr_0_1),
        .branch_address(branch_addr_0_branch_address),
        .jalr_address(jalr_0_jalr),
        .jump_target(id_mux_0_jump_target));
  jump_target_addr_jalr_0_0 jalr_0
       (.Immediate(Immediate_0_1),
        .Rd1(Rd1_0_1),
        .jalr(jalr_0_jalr));
endmodule

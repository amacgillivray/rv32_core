//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (win64) Build 2729669 Thu Dec  5 04:49:17 MST 2019
//Date        : Sun Oct 30 10:48:08 2022
//Host        : ENGR-G8DMVD3 running 64-bit major release  (build 9200)
//Command     : generate_target jump_target_addr_wrapper.bd
//Design      : jump_target_addr_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module jump_target_addr_wrapper
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

  wire [31:0]Immediate_0;
  wire [31:0]Immediate_1;
  wire IsJalr_0;
  wire [31:0]PC_0;
  wire [31:0]Rd1_0;
  wire [31:0]jump_target_0;

  jump_target_addr jump_target_addr_i
       (.Immediate_0(Immediate_0),
        .Immediate_1(Immediate_1),
        .IsJalr_0(IsJalr_0),
        .PC_0(PC_0),
        .Rd1_0(Rd1_0),
        .jump_target_0(jump_target_0));
endmodule

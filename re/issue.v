//-----------------------------------------------------------------
//                         RISC-V Core
//                            V1.0.1
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
//
//                   admin@ultra-embedded.com
//
//                       License: BSD
//-----------------------------------------------------------------
//
// Copyright (c) 2014-2019, Ultra-Embedded.com
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions 
// are met:
//   - Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   - Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer 
//     in the documentation and/or other materials provided with the 
//     distribution.
//   - Neither the name of the author nor the names of its contributors 
//     may be used to endorse or promote products derived from this 
//     software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
// SUCH DAMAGE.
//--------------------------------------------------------------

// Rewritten by Andrew MacGillivray with heavy reference to the original code
// TODO: tried to organize i/o but made it really messy instead. need to improve.
module issue 
#(
     parameter SUPPORT_MULDIV         = 1
    ,parameter SUPPORT_DUAL_ISSUE     = 1
    ,parameter SUPPORT_LOAD_BYPASS    = 1
    ,parameter SUPPORT_MUL_BYPASS     = 1
    ,parameter SUPPORT_REGFILE_XILINX = 0
)
(
    // HOLDS / INTERRUPTS
    input  take_interrupt,
    output hold_exec, 
    output hold_mul,
    output interrupt_inhibit,

    // OPCODES
    output [31:0] oc_oc, // opcode value 
    output [31:0] oc_pc, // opcode pgm counter
    output        oc_invalid,
    output [ 4:0] oc_rd_idx,
    output [ 4:0] oc_ra_idx,
    output [ 4:0] oc_rb_idx,
    output [31:0] oc_ra_operand,
    output [31:0] oc_rb_operand,

    // FETCH
    input        f_valid,
    input [31:0] f_instr,
    input [31:0] f_pc,
    input        f_fault,
    input        f_fault_page,
    output       f_accept, 

    // TODO: FETCH_INSTR ?? 
    input f_i_exec,      // where from?
    input f_i_lsu,       // ??
    input f_i_branch,
    input f_i_mul,       // MULTIPLICATION
    input f_i_div,       // DIVISION 
    input f_i_csr,       // control and status register
    input f_i_rd_valid,
    input f_i_invalid,

    // BRANCH (be_ = EXEC, bde = D EXEC, bcsr = CSR)
    input         be_request,
    input         be_is_taken,
    input         be_is_not_taken, 
    input  [31:0] be_source,
    input         be_is_call,
    input         be_is_return,
    input         be_is_jump,
    input  [31:0] be_pc,
    input         bde_request,
    input  [31:0] bde_pc,
    input  [ 1:0] bde_priv,
    input         bcsr_request,
    input  [31:0] bcsr_pc,
    input  [ 1:0] bcsr_priv,
    output        b_request,
    output        b_priv,

    // EXEC
    output exec_opcode_valid,

    // LOAD-STORE UNIT
    input         lsu_stall,
    output        lsu_opcode_valid,
    output [31:0] lsu_oc_oc, 
    output [31:0] lsu_oc_pc, 
    output        lsu_oc_invalid,
    output [ 4:0] lsu_oc_rd_idx,
    output [ 4:0] lsu_oc_ra_idx,
    output [ 4:0] lsu_oc_rb_idx,
    output [31:0] lsu_oc_ra_operand,
    output [31:0] lsu_oc_rb_operand,
    
    // "M" EXTENSION MISC
    output        mul_opcode_valid, 
    output        div_opcode_valid,
    output [31:0] mul_oc_oc, 
    output [31:0] mul_oc_pc, 
    output        mul_oc_invalid,
    output [ 4:0] mul_oc_rd_idx,
    output [ 4:0] mul_oc_ra_idx,
    output [ 4:0] mul_oc_rb_idx,
    output [31:0] mul_oc_ra_operand,
    output [31:0] mul_oc_rb_operand,
    
    // "V" EXTENSION MISC
    // output vec_opcode_valid,
    // output [31:0] vec_oc_oc, 
    // output [31:0] vec_oc_pc, 
    // output        vec_oc_invalid,
    // output [ 4:0] vec_oc_rd_idx,
    // output [ 4:0] vec_oc_ra_idx,
    // output [ 4:0] vec_oc_rb_idx,
    // output [31:0] vec_oc_ra_operand,
    // output [31:0] vec_oc_rb_operand,
    
    // WRITEBACK
    input [31:0] wb_exec_value,
    input        wb_mem_valid,
    input [31:0] wb_mem_value,
    input [ 5:0] wb_mem_exception,
    input [31:0] wb_mul_value, // TODO: note mul has a valid flag, div does not?
    input        wb_div_valid,
    input [31:0] wb_div_value,
    
    // CONTROL / STATUS REGISTER (re1 = "result_e1")
    input  [31:0] csr_re1_value,
    input         csr_re1_write,
    input  [31:0] csr_re1_wdata,
    input  [ 5:0] csr_re1_exception,
    output        csr_opcode_valid,
    output [31:0] csr_oc_oc, 
    output [31:0] csr_oc_pc, 
    output        csr_oc_invalid,
    output [ 4:0] csr_oc_rd_idx,
    output [ 4:0] csr_oc_ra_idx,
    output [ 4:0] csr_oc_rb_idx,
    output [31:0] csr_oc_ra_operand,
    output [31:0] csr_oc_rb_operand,
    output        csr_wb_write,
    output [11:0] csr_wb_waddr,
    output [31:0] csr_wb_wdata,
    output [ 5:0] csr_wb_exception,
    output [31:0] csr_wb_exception_pc,
    output [31:0] csr_wb_exception_addr,

    // CLOCK / RESET
    input clk,
    input rst
);

`include "defs.v"

// RISC-V ISA EXTENSION TOGGLES
wire enable_m_ext    = SUPPORT_MULDIV;
wire enable_m_bypass = SUPPORT_MUL_BYPASS;
wire enable_v_ext    = 0;

// Control Hazard Wires
// https://cseweb.ucsd.edu/classes/sp12/cse141/pdf/04/06_PipelinedProcessor.key.pdf
wire stall;
wire squash; 

// Set Privilege
reg [1:0] priv_x_q; 
always @(posedge clk or posedge rst)
if (rst)
    // When reset, revert to machine-level privilege
    priv_x_q <= `PRIV_MACHINE; // TODO: Add to defs
else if (bcsr_request)
    // otherwise, use the privilege set in bcsr_priv
    priv_x_q <= bcsr_priv;

// Issue Select
// Use bcsr and bde values to set b_request, choose program counter and priv
wire opcode_valid = f_valid & ~squash & ~bcsr_request;
assign b_request = bcsr_request | bde_request;
assign b_pc      = bcsr_request ? bcsr_pc   : bde_pc;
assign b_priv    = bcsr_request ? bcsr_priv : priv_x_q; // priv_x_q is bcsr_priv unless reset

// Instruction Decoder
wire [4:0] issue_ra_idx   = f_instr[19:25];
wire [4:0] issue_rb_idx   = f_instr[24:20];
wire [4:0] issue_rd_idx   = f_instr[ 11:7];
wire       issue_sb_alloc = f_i_rd_valid;
wire       issue_exec     = f_i_exec;
wire       issue_lsu      = f_i_lsu;
wire       issue_branch   = f_i_branch;
wire       issue_mul      = f_i_mul;
wire       issue_div      = f_i_div;
wire       issue_csr      = f_i_csr;
wire       issue_invalid  = f_i_invalid;

// Pipeline Status Tracking
wire pipe_squash_e1_e2;



endmodule
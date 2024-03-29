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

module issue 
#(
     parameter SUPPORT_MULDIV         = 1
    ,parameter SUPPORT_DUAL_ISSUE     = 1
    ,parameter SUPPORT_LOAD_BYPASS    = 1
    ,parameter SUPPORT_MUL_BYPASS     = 1
    ,parameter SUPPORT_REGFILE_XILINX = 0
)
(   
    ///////////////////
    // INPUTS 
    ///////////////////

    // CLOCK / RESET
    input        clk,
    input        rst,

    // FETCH
    input        f_valid,
    input [31:0] f_instr,
    input [31:0] f_pc,
    input        f_fault,
    input        f_fault_page,
    
    // FETCH_INSTR
    input        f_i_exec,      // where from?
    input        f_i_lsu,       // ??
    input        f_i_branch,
    input        f_i_mul,       // MULTIPLICATION
    input        f_i_div,       // DIVISION 
    input        f_i_csr,       // control and status register
    input        f_i_rd_valid,
    input        f_i_invalid,

    // BRANCH (be_ = EXEC, bde = D EXEC, bcsr = CSR)
    input        be_request,
    input        be_is_taken,
    input        be_is_not_taken, 
    input [31:0] be_source,
    input        be_is_call,
    input        be_is_return,
    input        be_is_jump,
    input [31:0] be_pc,
    input        bde_request,
    input [31:0] bde_pc,
    input [ 1:0] bde_priv,
    input        bcsr_request,
    input [31:0] bcsr_pc,
    input [ 1:0] bcsr_priv,

    // WRITEBACK
    input [31:0] wb_exec_value,
    input        wb_mem_valid,
    input [31:0] wb_mem_value,
    input [ 5:0] wb_mem_exception,
    input [31:0] wb_mul_value, // TODO: note mul has a valid flag, div does not?
    input        wb_div_valid,
    input [31:0] wb_div_value,

    // CONTROL / STATUS REGISTER (re1 = "result_e1")
    input [31:0] csr_re1_value,
    input        csr_re1_write,
    input [31:0] csr_re1_wdata,
    input [ 5:0] csr_re1_exception,

    // LOAD-STORE UNIT
    input        lsu_stall,

    // HOLDS / INTERRUPTS
    input  take_interrupt,

    ///////////////////
    // OUTPUTS  
    ///////////////////

    // FETCH
    output        f_accept, 

    // BRANCH
    output        b_request,
    output [31:0] b_pc,
    output [ 1:0] b_priv,

    // OPCODE-VALID (exec, lsu, csr, mul, div)
    output        exec_opcode_valid,
    output        lsu_opcode_valid,
    output        csr_opcode_valid,
    output        mul_opcode_valid, 
    output        div_opcode_valid,

    // BASE OPCODES
    output [31:0] oc_oc, // opcode value 
    output [31:0] oc_pc, // opcode pgm counter
    output        oc_invalid,
    output [ 4:0] oc_rd_idx,
    output [ 4:0] oc_ra_idx,
    output [ 4:0] oc_rb_idx,
    output [31:0] oc_ra_operand,
    output [31:0] oc_rb_operand,

    // LSU OPCODE COPY (LOAD-STORE UNIT)
    output [31:0] lsu_oc_oc, 
    output [31:0] lsu_oc_pc, 
    output        lsu_oc_invalid,
    output [ 4:0] lsu_oc_rd_idx,
    output [ 4:0] lsu_oc_ra_idx,
    output [ 4:0] lsu_oc_rb_idx,
    output [31:0] lsu_oc_ra_operand,
    output [31:0] lsu_oc_rb_operand,

    // M OPCODE COPY (MULTIPLICATION / DIVISION EXTENSION)
    output [31:0] mul_oc_oc, 
    output [31:0] mul_oc_pc, 
    output        mul_oc_invalid,
    output [ 4:0] mul_oc_rd_idx,
    output [ 4:0] mul_oc_ra_idx,
    output [ 4:0] mul_oc_rb_idx,
    output [31:0] mul_oc_ra_operand,
    output [31:0] mul_oc_rb_operand,

    // V OPCODE COPY (VECTOR EXTENSION)
    // output vec_opcode_valid,
    // output [31:0] vec_oc_oc, 
    // output [31:0] vec_oc_pc, 
    // output        vec_oc_invalid,
    // output [ 4:0] vec_oc_rd_idx,
    // output [ 4:0] vec_oc_ra_idx,
    // output [ 4:0] vec_oc_rb_idx,
    // output [31:0] vec_oc_ra_operand,
    // output [31:0] vec_oc_rb_operand,

    // CSR OPCODE COPY (CONTROL / STATUS REGISTER)
    output [31:0] csr_oc_oc, 
    output [31:0] csr_oc_pc, 
    output        csr_oc_invalid,
    output [ 4:0] csr_oc_rd_idx,
    output [ 4:0] csr_oc_ra_idx,
    output [ 4:0] csr_oc_rb_idx,
    output [31:0] csr_oc_ra_operand,
    output [31:0] csr_oc_rb_operand,

    // CSR WRITEBACK
    output        csr_wb_write,
    output [11:0] csr_wb_waddr,
    output [31:0] csr_wb_wdata,
    output [ 5:0] csr_wb_exception,
    output [31:0] csr_wb_exception_pc,
    output [31:0] csr_wb_exception_addr,

    // HOLDS / INTERRUPTS
    output hold_exec, 
    output hold_mul,
    output interrupt_inhibit
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
    priv_x_q <= `PRIV_MACHINE;
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
wire [4:0] issue_ra_idx   = f_instr[19:15];
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
reg  oc_issue; // opcode issue
reg  oc_accept; // opcode accept
wire p_squash_e1_e2;
wire p_stall_raw;

wire        p_load_e1;
wire        p_store_e1;
wire        p_mul_e1;
wire        p_branch_e1;
wire [ 4:0] p_rd_e1;
wire [31:0] p_pc_e1;
wire [31:0] p_oc_e1;
wire [31:0] p_opr_ra_e1;
wire [31:0] p_opr_rb_e1;

wire p_load_e2;
wire p_mul_e2;
wire [ 4:0] p_rd_e2;
wire [31:0] p_result_e2;

wire p_valid_wb;
wire p_csr_wb;
wire [4:0] p_rd_wb;
wire [31:0] p_result_wb; 
wire [31:0] p_pc_wb; 
wire [31:0] p_opc_wb;
wire [31:0] p_ra_val_wb;
wire [31:0] p_rb_val_wb;

wire [`EXCEPTION_W-1:0] p_except_wb;
wire [`EXCEPTION_W-1:0] issue_fault = 
    f_fault ? `EXCEPTION_FAULT_FETCH : f_fault_page ? `EXCEPTION_PAGE_FAULT_INST : `EXCEPTION_W'b0;

pipe_ctrl
#(
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
)
u_pipe_ctrl(
    // clock, reset
     .clk(clk)
    ,.rst(rst)
    
    // issue
    ,.issue_valid_i(oc_issue)
    ,.issue_accept_i(oc_accept)
    ,.issue_stall_i(stall)
    ,.issue_lsu_i(issue_lsu)
    ,.issue_csr_i(issue_csr)
    ,.issue_div_i(issue_div)
    ,.issue_mul_i(issue_mul)
    ,.issue_branch_i(issue_branch)
    ,.issue_rd_valid_i(issue_sb_alloc)
    ,.issue_rd_i(issue_rd_idx)
    ,.issue_exception_i(issue_fault)
    ,.take_interrupt_i(take_interrupt)
    ,.issue_branch_taken_i(bde_request)
    ,.issue_branch_target_i(bde_pc)
    ,.issue_pc_i(oc_pc)
    ,.issue_opcode_i(oc_oc)
    ,.issue_operand_ra_i(oc_ra_operand)
    ,.issue_operand_rb_i(oc_rb_operand)

    // alu
    ,.alu_result_e1_i(wb_exec_value)
    ,.csr_result_value_e1_i(csr_re1_value)
    ,.csr_result_write_e1_i(csr_re1_write)
    ,.csr_result_wdata_e1_i(csr_re1_wdata)
    ,.csr_result_exception_e1_i(csr_re1_exception)

    // exec stage 1
    ,.load_e1_o(p_load_e1)
    ,.store_e1_o(p_store_e1)
    ,.mul_e1_o(p_mul_e1)
    ,.branch_e1_o(p_branch_e1)
    ,.rd_e1_o(p_rd_e1)
    ,.pc_e1_o(p_pc_e1)
    ,.opcode_e1_o(p_oc_e1)
    ,.operand_ra_e1_o(p_opr_ra_e1)
    ,.operand_rb_e1_o(p_opr_rb_e1)

    // exec stage 2
    ,.mem_complete_i(wb_mem_valid)
    ,.mem_result_e2_i(wb_mem_value)
    ,.mem_exception_e2_i(wb_mem_exception)
    ,.mul_result_e2_i(wb_mul_value)
    ,.load_e2_o(p_load_e2)
    ,.mul_e2_o(p_mul_e2)
    ,.rd_e2_o(p_rd_e2)
    ,.result_e2_o(p_result_e2)

    // div result
    ,.div_complete_i(wb_div_valid)
    ,.div_result_i(wb_div_value)

    // commit
    ,.valid_wb_o(p_valid_wb)
    ,.csr_wb_o(p_csr_wb)
    ,.rd_wb_o(p_rd_wb)
    ,.result_wb_o(p_result_wb)
    ,.pc_wb_o(p_pc_wb)
    ,.opcode_wb_o(p_opc_wb)
    ,.operand_ra_wb_o(p_ra_val_wb)
    ,.operand_rb_wb_o(p_rb_val_wb)
    ,.exception_wb_o(p_except_wb)
    ,.csr_write_wb_o(csr_wb_write)
    ,.csr_waddr_wb_o(csr_wb_waddr)
    ,.csr_wdata_wb_o(csr_wb_wdata)
    
    // Stall, squash
    ,.stall_o(p_stall_raw)
    ,.squash_e1_e2_o(p_squash_e1_e2)
    ,.squash_e1_e2_i(1'b0)
    ,.squash_wb_i(1'b0)
);

assign exec_hold = stall; 
assign mul_hold = stall;

// Pipe 1 - Status Tracking
assign csr_wb_except = p_except_wb;
assign csr_wb_except_pc = p_pc_wb;
assign csr_wb_except_addr = p_result_wb; 

// Blocking Events 
//  - CSR Unit Access
//  - Division 
// TODO: vector operations?
reg csr_pending;
reg div_pending;

// for division operations:
//  2 - 34 cycles, stall pipeline until complete
always @ (posedge clk or posedge rst)
if (rst)
    div_pending <= 1'b0;
else if (p_squash_e1_e2)
    div_pending <= 1'b0;
else if (div_opcode_valid && issue_div)
    div_pending <= 1'b1;
else if (wb_div_valid)
    div_pending <= 1'b0;

// for csr operations:
//  2 - 3 cycles... 
// per @ultraembedded's comments: "CSR operations are infrequent - avoid any complications of pipelining them."
//                 "These only take a 2-3 cycles anyway and may result in a pipe flush (e.g. ecall, ebreak..)."
always @ (posedge clk or posedge rst)
if (rst)
    csr_pending <= 1'b0;
else if (p_squash_e1_e2)
    csr_pending <= 1'b0;
else if (csr_opcode_valid && issue_csr)
    csr_pending <= 1'b1;
else if (p_csr_wb)
    csr_pending <= 1'b0;
assign squash = p_squash_e1_e2;

// Scheduling
reg [31:0] scoreboard;
always @ * 
begin
    oc_issue = 1'b0;
    oc_accept = 1'b0;
    scoreboard = 32'b0;

    // >= 2 cycle latency... 
    // TODO: vector?
    if (SUPPORT_LOAD_BYPASS == 0)
    begin 
        if (p_load_e2)
            scoreboard[p_rd_e2] = 1'b1;
    end
    if (SUPPORT_MUL_BYPASS == 0)
    begin 
        if (p_mul_e2)
            scoreboard[p_rd_e2] = 1'b1;
    end

    // >= 1 cycle latency...
    if (p_load_e1 || p_mul_e1)
        scoreboard[p_rd_e1] = 1'b1;

    // per UE/riscv: "Do not start multiply, division or CSR operation in the cycle after a load (leaving only ALU operations and branches)"
    if ((p_load_e1 || p_store_e1) && (issue_mul || issue_div || issue_csr))
        scoreboard = 32'hffffffff;
    
    // stall
    if (
        lsu_stall   || 
        stall       || 
        div_pending || 
        csr_pending
    )
        ;
    else if (
        opcode_valid && 
        !(scoreboard[issue_ra_idx] || 
          scoreboard[issue_rb_idx] || 
          scoreboard[issue_rd_idx])
    )
    begin
        oc_issue = 1'b1;
        oc_accept = 1'b1;

        if (oc_accept && issue_sb_alloc && (|issue_rd_idx))
            scoreboard[issue_rd_idx] = 1'b1;
    end
end

assign lsu_opcode_valid = oc_issue & ~take_interrupt;
assign exec_opcode_valid= oc_issue;
assign mul_opcode_valid = enable_m_ext & oc_issue;
assign div_opcode_valid = enable_m_ext & oc_issue;
assign interrupt_inhibit= csr_pending || issue_csr;
assign f_accept = opcode_valid ? (oc_accept & ~take_interrupt) : 1'b1;
assign stall = p_stall_raw;

// Regfile
wire [31:0] issue_ra_value;
wire [31:0] issue_rb_value;
wire [31:0] issue_b_ra_value;
wire [31:0] issue_b_rb_value;
regfile
u_regfile
(
     .clk(clk)
    ,.rst(rst)
    ,.rd0_i(p_rd_wb)
    ,.rd0_value_i(p_result_wb)
    ,.ra0_i(issue_ra_idx)
    ,.rb0_i(issue_rb_idx)
    ,.ra0_value_o(issue_ra_value)
    ,.rb0_value_o(issue_rb_value)
);

// Set opcode values
assign oc_oc = f_instr;
assign oc_pc = f_pc;
assign oc_rd_idx = issue_rd_idx;
assign oc_ra_idx = issue_ra_idx;
assign oc_rb_idx = issue_rb_idx;
assign oc_invalid= 1'b0;
reg [31:0] ira_value_reg;
reg [31:0] irb_value_reg;
always @ *
begin
    ira_value_reg = issue_ra_value;
    irb_value_reg = issue_rb_value;
    // wb bypass
    if (p_rd_wb == issue_ra_idx)
        ira_value_reg = p_result_wb;
    if (p_rd_wb == issue_rb_idx)
        irb_value_reg = p_result_wb;
    // e2 bypass
    if (p_rd_e2 == issue_ra_idx)
        ira_value_reg = p_result_e2;
    if (p_rd_e2 == issue_rb_idx)
        irb_value_reg = p_result_e2;
    // e1 bypass
    if (p_rd_e1 == issue_ra_idx)
        ira_value_reg = wb_exec_value;
    if (p_rd_e1 == issue_rb_idx)
        irb_value_reg = wb_exec_value;
    // 0 source
    if (issue_ra_idx == 5'b0)
        ira_value_reg = 32'b0;
    if (issue_rb_idx == 5'b0)
        irb_value_reg = 32'b0;
end 
assign oc_ra_operand = ira_value_reg;
assign oc_rb_operand = irb_value_reg;

// Copy oc values for load-store unit
assign lsu_oc_oc = oc_oc;
assign lsu_oc_pc = oc_pc;
assign lsu_oc_rd_idx = oc_rd_idx;
assign lsu_oc_ra_idx = oc_ra_idx;
assign lsu_oc_rb_idx = oc_rb_idx;
assign lsu_oc_ra_operand = oc_ra_operand;
assign lsu_oc_rb_operand = oc_rb_operand;
assign lsu_oc_invalid = 1'b0;

// Copy oc values for multiplier
assign mul_oc_oc = oc_oc;
assign mul_oc_pc = oc_pc;
assign mul_oc_rd_idx = oc_rd_idx;
assign mul_oc_ra_idx = oc_ra_idx;
assign mul_oc_rb_idx = oc_rb_idx;
assign mul_oc_ra_operand = oc_ra_operand;
assign mul_oc_rb_operand = oc_rb_operand;
assign mul_oc_invalid = 1'b0;

// Copy oc values for control/status register
assign csr_oc_oc = oc_issue & ~take_interrupt;
assign csr_oc_pc = oc_pc;
assign csr_oc_rd_idx = oc_rd_idx;
assign csr_oc_ra_idx = oc_ra_idx;
assign csr_oc_rb_idx = oc_rb_idx;
assign csr_oc_ra_operand = oc_ra_operand;
assign csr_oc_rb_operand = oc_rb_operand;
assign csr_oc_invalid = oc_issue && issue_invalid;

endmodule

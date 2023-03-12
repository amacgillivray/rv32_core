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
//-----------------------------------------------------------------

// Rewritten by Andrew MacGillivray with heavy reference to the original code

module core 
#(
    // new params for our project - not yet used 
    parameter SUPPORT_ATOMICS = 0,
    parameter SUPPORT_VECTOR = 0,
    // params from original code
    parameter SUPPORT_MULDIV = 1,
    parameter SUPPORT_SUPER = 0, 
    parameter SUPPORT_MMU = 0,
    parameter SUPPORT_LOAD_BYPASS = 1,
    parameter SUPPORT_MUL_BYPASS = 1,
    parameter SUPPORT_REGFILE_XILINX = 0,
    parameter EXTRA_DECODE_STAGE = 0,
    parameter MEM_CACHE_ADDR_MIN = 32'h80000000
    parameter MEM_CACHE_ADDR_MAX = 32'h8FFFFFFF
)
(
    ///////////////////
    // INPUTS 
    ///////////////////
    // clock / reset
    input clk,
    input rst,

    // mem
    input [31:0] mem_d_data_rd,
    input mem_d_accept,
    input mem_d_ack,
    input mem_d_err,
    input [10:0] mem_d_resp_tag,
    input mem_i_accept,
    input mem_i_valid,
    input mem_i_error,
    input [31:0] mem_i_inst,

    // misc
    input intr,
    input [31:0] reset_vector,
    input [31:0] cpu_id,

    ///////////////////
    // OUTPUTS
    ///////////////////
    output [31:0] mem_d_addr,
    output [31:0] mem_d_data_wr,
    output mem_d_rd,
    output [3:0] mem_d_wr,
    output mem_d_cacheable, 
    output [10:0] mem_d_req_tag,
    output mem_d_invalidate, 
    output mem_d_writeback, 
    output mem_d_flush, 
    output mem_i_rd,
    output mem_i_flush,
    output mem_i_invalidate,
    output [31:0] mem_i_pc
);


// branch
wire branch_request;
wire [1:0] branch_priv;
wire [31:0] branch_pc;
wire branch_csr_request;
wire [1:0] branch_csr_priv;
wire [31:0] branch_csr_pc;
wire branch_d_exec_request;
wire [1:0] branch_d_exec_priv;
wire [31:0] branch_d_exec_pc;
wire branch_exec_is_taken;
wire branch_exec_is_not_taken;
wire branch_exec_request;
wire branch_exec_is_ret;
wire branch_exec_is_jmp;
wire branch_exec_is_call;
wire [31:0] branch_exec_source; 
wire [31:0] branch_exec_pc;


// Control / Status Register
wire csr_opcode_valid;
wire csr_opcode_invalid;
wire [31:0] csr_opcode_opcode;
wire [31:0] csr_opcode_pc;
wire [4:0] csr_opcode_rd_idx;
wire [31:0] csr_opcode_ra_operand;
wire [4:0] csr_opcode_ra_idx;
wire [31:0] csr_opcode_rb_operand;
wire [4:0] csr_opcode_rb_idx;
wire csr_wb_write;
wire [11:0] csr_wb_waddr;
wire [31:0] csr_wb_wdata;
wire [5:0] csr_wb_except;
wire [31:0] csr_wb_except_addr;
wire [31:0] csr_wb_except_pc;
wire csr_re1_write;
wire [31:0] csr_re1_wdata;
wire [31:0] csr_re1_value;
wire [5:0] csr_re1_exception;


// Exec
wire exec_hold;
wire exec_opcode_valid;


// Fetch
wire fetch_accept;
wire fetch_valid;
wire [1:0] fetch_in_priv;
wire [31:0] fetch_pc;
wire fetch_instr_invalid;
wire fetch_instr_rd_valid;
wire fetch_instr_branch;
wire fetch_instr_exec;
wire fetch_instr_div;
wire fetch_instr_mul;
wire fetch_instr_lsu;
wire fetch_instr_csr;
wire [31:0] fetch_instr;
wire fetch_dec_accept;
wire fetch_dec_valid;
wire fetch_dec_fault_fetch;
wire fetch_dec_fault_page;
wire [31:0] fetch_dec_pc;
wire [31:0] fetch_dec_instr;
wire fetch_in_fault;
wire fetch_fault_page;
wire fetch_fault_fetch;


// Load-Store Unit
wire lsu_stall;
wire lsu_opcode_valid;
wire lsu_opcode_invalid;
wire [31:0] lsu_opcode_opcode;
wire [31:0] lsu_opcode_pc;
wire [31:0] lsu_opcode_rd_idx;
wire [4:0] lsu_opcode_ra_idx;
wire [31:0] lsu_opcode_ra_operand;
wire [4:0] lsu_opcode_rb_idx;
wire [31:0] lsu_opcode_rb_operand;


// Memory Management Unit
wire mmu_flush;
wire mmu_mxr;
wire mmu_sum;
wire mmu_store_fault;
wire mmu_load_fault;
wire [1:0] mmu_priv_d;
wire [31:0] mmu_satp;
wire mmu_lsu_accept;
wire mmu_lsu_ack;
wire mmu_lsu_cacheable;
wire mmu_lsu_error;
wire mmu_lsu_invalidate;
wire mmu_lsu_flush;
wire mmu_lsu_wb; 
wire mmu_lsu_rd;
wire [3:0] mmu_lsu_wr;
wire [31:0] mmu_lsu_data_rd;
wire [31:0] mmu_lsu_data_wr;
wire [10:0] mmu_lsu_resp_tag;
wire [10:0] mmu_lsu_req_tag;
wire [31:0] mmu_lsu_addr;
wire mmu_ifetch_valid;
wire mmu_ifetch_accept;
wire mmu_ifetch_error;
wire mmu_ifetch_invalidate;
wire mmu_ifetch_flush;
wire mmu_ifetch_rd;
wire [31:0] mmu_ifetch_inst;
wire [31:0] mmu_ifetch_pc;


// Opcode 
wire [31:0] oc_pc;
wire [4:0] oc_rb_idx;
wire [31:0] oc_ra_operand;
wire [31:0] oc_oc;
wire [4:0] oc_ra_idx;
wire oc_invalid;
wire [31:0] oc_rb_operand;
wire [4:0] oc_rd_idx;


// Writeback
wire wb_mem_valid;
wire wb_div_valid;
wire [5:0] wb_mem_exception;
wire [31:0] wb_mem_value;
wire [31:0] wb_exec_value;
wire [31:0] wb_mul_value;
wire [31:0] wb_div_value;

// Misc
wire take_interrupt;
wire interrupt_inhibit;
wire ifence;
wire squash_decode;

// "M" Extension ("mul_" = Multiplication, "div_" = Division)
wire mul_opcode_valid;
wire mul_opcode_invalid
wire [31:0] mul_opcode_opcode;
wire [31:0] mul_opcode_pc;
wire [4:0] mul_opcode_rd_idx;
wire [31:0] mul_opcode_ra_operand;
wire [4:0] mul_opcode_ra_idx;
wire [31:0] mul_opcode_rb_operand;
wire [4:0] mul_opcode_rb_idx;
wire mul_hold;
wire div_opcode_valid;

exec
u_exec (
     .InClk(clk)
    ,.InRst(rst)
    
    ,.InOpcodeValid(exec_opcode_valid)
    ,.InOpcodeOpcode(oc_oc)
    ,.InOpcodePc(oc_pc)
    ,.InOpcodeInvalid(oc_invalid)
    ,.InOpcodeRdIdx(oc_rd_idx)
    ,.InOpcodeRaIdx(oc_ra_idx)
    ,.InOpcodeRbIdx(oc_rb_idx)
    ,.InOpcodeRaOperand(oc_ra_operand)
    ,.InOpcodeRbOperand(oc_rb_operand)
    ,.InHold(exec_hold)

    ,.OutBranchRequest(branch_exec_request)
    ,.OutBranchIsTaken(branch_exec_is_taken)
    ,.OutBranchIsNotTaken(branch_exec_is_not_taken)
    ,.OutBranchSource(branch_exec_source)
    ,.OutBranchIsCall(branch_exec_is_call)
    ,.OutBranchIsRet(branch_exec_is_ret)
    ,.OutBranchIsJmp(branch_exec_is_jmp)
    ,.OutBranchPc(branch_exec_pc)
    ,.OutBranchDRequest(branch_d_exec_request)
    ,.OutBranchDPc(branch_d_exec_pc)
    ,.OutBranchDPriv(branch_d_exec_priv)
    ,.OutWritebackValue(wb_exec_value)
);

decode
#(
    .EXTRA_DECODE_STAGE(EXTRA_DECODE_STAGE),
    .SUPPORT_MULDIV(SUPPORT_MULDIV)
) u_decode (
    .clk(clk),
    .rst(rst),
    
    .InFetchInValid(fetch_dec_valid),
    .InFetchInInstr(fetch_dec_instr),
    .InFetchInPC(fetch_dec_pc),
    .InFetchInFaultFetch(fetch_dec_fault_fetch),
    .InFetchInFaultPage(fetch_dec_fault_page),
    .InFetchOutAccept(fetch_accept),
    .InSquashDecode(squash_decode),
    
    .OutFetchInAccept(fetch_dec_accept),
    .OutFetchOutValid(fetch_valid),
    .OutFetchOutInstr(fetch_instr),
    .OutFetchOutPc(fetch_pc),
    .OutFetchOutFaultFetch(fetch_fault_fetch),
    .OutFetchOutFaultPage(fetch_fault_page),
    .OutFetchOutInstrExec(fetch_instr_exec),
    .OutFetchOutInstrLsu(fetch_instr_lsu),
    .OutFetchOutInstrBranch(fetch_instr_branch),
    .OutFetchOutInstrMul(fetch_instr_mul),
    .OutFetchOutInstrDiv(fetch_instr_div),
    .OutFetchOutInstrCsr(fetch_instr_csr),
    .OutFetchOutInstrRdValid(fetch_instr_rd_valid),
    .OutFetchOutInstrInvalid(fetch_instr_invalid)
);

mmu
#(
    .MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX),
    .SUPPORT_MMU(SUPPORT_MMU),
    .MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
) u_mmu (
    .InClk(clk),
    .InRst(rst),

    .InPrivI(mmu_priv_d),
    .InSum(mmu_sum),
    .InMxr(mmu_mxr),
    .InFlush(mmu_flush),
    .InSatp(mmu_satp),
    .InFetchInRd(mmu_ifetch_rd),
    .FetchInInFlush(mmu_ifetch_flush),
    .InFetchInInvalidate(mmu_ifetch_invalidate),
    .InFetchInPC(mmu_ifetch_pc),
    .InFetchInPriv(fetch_in_priv),
    .InFetchOutAccept(mem_i_accept),
    .InFetchOutValid(mem_i_valid),
    .InFetchOutError(mem_i_error),
    .InFetchOutInst(mem_i_inst),
    .InLsuInAddr(mmu_lsu_addr),
    .InLsuInDataWr(mmu_lsu_data_wr),
    .InLsuInRd(mmu_lsu_rd),
    .InLsuInWr(mmu_lsu_wr),
    .InLsuInCacheable(mmu_lsu_cacheable),
    .InLsuInReqTag(mmu_lsu_req_tag),
    .InLsuInInvalidate(mmu_lsu_invalidate),
    .InLsuInWriteback(mmu_lsu_wb),
    .InLsuInFlush(mmu_lsu_flush),
    .InLsuOutDataRd(mem_d_data_rd),
    .InLsuOutAccept(mem_d_accept),
    .InLsuOutAck(mem_d_ack),
    .InLsuOutError(mem_d_err),
    .InLsuOutRespTag(mem_d_resp_tag)

    ,.OutFetchInAccept(mmu_ifetch_accept)
    ,.OutFetchInValid(mmu_ifetch_valid)
    ,.OutFetchInError(mmu_ifetch_error)
    ,.OutFetchInInst(mmu_ifetch_inst)
    ,.OutFetchOutRd(mem_i_rd)
    ,.OutFetchOutFlush(mem_i_flush)
    ,.OutFetchOutInvalidate(mem_i_invalidate)
    ,.OutFetchOutPc(mem_i_pc)
    ,.OutFetchInFault(fetch_in_fault)
    ,.OutLsuInDataRd(mmu_lsu_data_rd)
    ,.OutLsuInAccept(mmu_lsu_accept)
    ,.OutLsuInAck(mmu_lsu_ack)
    ,.OutLsuInError(mmu_lsu_error)
    ,.OutLsuInRespTag(mmu_lsu_resp_tag)
    ,.OutLsuOutAddr(mem_d_addr)
    ,.OutLsuOutDataWr(mem_d_data_wr)
    ,.OutLsuOutRd(mem_d_rd)
    ,.OutLsuOutWr(mem_d_wr)
    ,.OutLsuOutCacheable(mem_d_cacheable)
    ,.OutLsuOutReqTag(mem_d_req_tag)
    ,.OutLsuOutInvalidate(mem_d_invalidate)
    ,.OutLsuOutWriteback(mem_d_writeback)
    ,.OutLsuOutFlush(mem_d_flush)
    ,.OutLsuInLoadFault(mmu_load_fault)
    ,.OutLsuInStoreFault(mmu_store_fault)
);

lsu
#( 
    .MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX),
    .MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
) u_lsu (
     .clk(clk)
    ,.rst(rst)

    ,.opcode_valid_i(lsu_opcode_valid)
    ,.opcode_opcode_i(lsu_opcode_opcode)
    ,.opcode_pc_i(lsu_opcode_pc)
    ,.opcode_invalid_i(lsu_opcode_invalid)
    ,.opcode_rd_idx_i(lsu_oc_rd_idx)
    ,.opcode_ra_idx_i(lsu_oc_ra_idx)
    ,.opcode_rb_idx_i(lsu_oc_rb_idx)
    ,.opcode_ra_operand_i(lsu_oc_ra_operand)
    ,.opcode_rb_operand_i(lsu_oc_rb_operand)
    ,.mem_data_rd_i(mmu_lsu_data_rd)
    ,.mem_accept_i(mmu_lsu_accept)
    ,.mem_ack_i(mmu_lsu_ack)
    ,.mem_error_i(mmu_lsu_error)
    ,.mem_resp_tag_i(mmu_lsu_resp_tag)
    ,.mem_load_fault_i(mmu_load_fault)
    ,.mem_store_fault_i(mmu_store_fault)

    ,.mem_addr_o(mmu_lsu_addr)
    ,.mem_data_wr_o(mmu_lsu_data_wr)
    ,.mem_rd_o(mmu_lsu_rd)
    ,.mem_wr_o(mmu_lsu_wr)
    ,.mem_cacheable_o(mmu_lsu_cacheable)
    ,.mem_req_tag_o(mmu_lsu_req_tag)
    ,.mem_invalidate_o(mmu_lsu_invalidate)
    ,.mem_writeback_o(mmu_lsu_wb)
    ,.mem_flush_o(mmu_lsu_flush)
    ,.writeback_valid_o(wb_mem_valid)
    ,.writeback_value_o(wb_mem_value)
    ,.writeback_exception_o(wb_mem_exception)
    ,.stall_o(lsu_stall)
);

multiplier
u_mul
(
    .clk(clk),
    .rst(rst),
    
    .Valid(mul_opcode_valid),
    .opcode(mul_opcode_opcode),
    .pc(mul_opcode_pc),
    .invalid(mul_opcode_invalid),
    .rd_idx(mul_opcode_rd_idx),
    .ra_idx(mul_oc_ra_idx),
    .rb_idx(mul_oc_rb_idx),
    .ra_operand(mul_oc_ra_operand),
    .rb_operand(mul_oc_rb_operand),
    .hold(mul_hold),

    .wb_value(wb_mul_value)
);

divider
u_div
(
    .clk(clk),
    .rst(rst), 
    
    .oc_valid(div_opcode_valid),
    .oc_oc(oc_oc),
    .oc_pc(oc_pc),
    .oc_invalid(oc_invalid),
    .oc_rd_idx(oc_rd_idx),
    .oc_ra_idx(oc_ra_idx),
    .oc_rb_idx(oc_rb_idx),
    .oc_ra_operand(oc_ra_operand),
    .oc_rb_operand(oc_rb_operand),

    .wb_valid(wb_div_valid),
    .wb_value(wb_div_value)
);

issue
#(
    .SUPPORT_REGFILE_XILINX(SUPPORT_REGFILE_XILINX),
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MULDIV(SUPPORT_MULDIV),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS),
    .SUPPORT_DUAL_ISSUE(1)
) u_issue (
    .clk(clk),
    .rst(rst),

    .f_valid(fetch_valid),
    .f_instr(fetch_instr),
    .f_pc(fetch_pc),
    .f_fault(fetch_fault_fetch),
    .f_fault_page(fetch_fault_page),

    .f_i_exec(fetch_instr_exec),
    .f_i_lsu(fetch_instr_lsu),
    .f_i_branch(fetch_instr_branch),
    .f_i_mul(fetch_instr_mul),  
    .f_i_div(fetch_instr_div),     
    .f_i_csr(fetch_instr_csr),     
    .f_i_rd_valid(fetch_instr_rd_valid),
    .f_i_invalid(fetch_instr_invalid),    

    .be_request(branch_exec_request),
    .be_is_taken(branch_exec_is_taken),
    .be_is_not_taken(branch_exec_is_not_taken), 
    .be_source(branch_exec_source),
    .be_is_call(branch_exec_is_call),
    .be_is_return(branch_exec_is_ret),
    .be_is_jump(branch_exec_is_jmp),
    .be_pc(branch_exec_pc),
    .bde_request(branch_d_exec_request),
    .bde_pc(branch_d_exec_pc),
    .bde_priv(branch_d_exec_priv),
    .bcsr_request(branch_csr_request),
    .bcsr_pc(branch_csr_pc),
    .bcsr_priv(branch_csr_priv),

    .wb_exec_value(wb_exec_value),
    .wb_mem_valid(wb_mem_valid),
    .wb_mem_value(wb_mem_value),
    .wb_mem_exception(wb_mem_exception),
    .wb_mul_value(wb_mul_value),
    .wb_div_valid(wb_div_valid),
    .wb_div_value(wb_div_value),

    .csr_re1_value(csr_re1_value),
    .csr_re1_write(csr_re1_write),
    .csr_re1_wdata(csr_re1_wdata),
    .csr_re1_exception(csr_re1_exception),

    .lsu_stall(lsu_stall),
    .take_interrupt(take_interrupt),

    .f_accept(fetch_accept),

    .b_request(branch_request),
    .b_pc(branch_pc),
    .b_priv(branch_priv),
    
    .exec_opcode_valid(exec_opcode_valid),
    .lsu_opcode_valid(lsu_opcode_valid),
    .csr_opcode_valid(csr_opcode_valid),
    .mul_opcode_valid(mul_opcode_valid),
    .div_opcode_valid(div_opcode_valid),

    .oc_oc(oc_oc),
    .oc_pc(oc_pc),
    .oc_invalid(oc_invalid),
    .oc_rd_idx(oc_rd_idx),
    .oc_ra_idx(oc_ra_idx),
    .oc_rb_idx(oc_rb_idx),
    .oc_ra_operand(oc_ra_operand),
    .oc_rb_operand(oc_rb_operand),

    .mul_oc_oc(mul_opcode_opcode),
    .mul_oc_pc(mul_opcode_pc),
    .mul_oc_invalid(mul_opcode_invalid),
    .mul_oc_rd_idx(mul_opcode_rd_idx),
    .mul_oc_ra_idx(mul_opcode_ra_idx),
    .mul_oc_rb_idx(mul_opcode_rb_idx),
    .mul_oc_ra_operand(mul_opcode_ra_operand),
    .mul_oc_rb_operand(mul_opcode_rb_operand),

    .csr_oc_oc(csr_opcode_opcode),
    .csr_oc_pc(csr_opcode_pc),
    .csr_oc_invalid(csr_opcode_invalid),
    .csr_oc_rd_idx(csr_opcode_rd_idx),
    .csr_oc_ra_idx(csr_opcode_ra_idx),
    .csr_oc_rb_idx(csr_opcode_rb_idx),
    .csr_oc_ra_operand(csr_opcode_ra_operand),
    .csr_oc_rb_operand(csr_opcode_rb_operand),

    .csr_wb_write(csr_wb_write),
    .csr_wb_waddr(csr_wb_waddr),
    .csr_wb_wdata(csr_wb_wdata),
    .csr_wb_exception(csr_wb_except),
    .csr_wb_exception_pc(csr_wb_except_pc),
    .csr_wb_exception_addr(csr_wb_except_addr),

    .hold_exec(exec_hold)
    .hold_mul(mul_hold)
    .interrupt_inhibit(interrupt_inhibit)
);

fetch
#(
    .SUPPORT_MMU(SUPPORT_MMU)
) u_fetch (
     .clk(clk)
    ,.rst(rst)
    
    ,.f_accept_i(fetch_accept)
    ,.ic_accept_i(mmu_ifetch_accept)
    ,.ic_valid_i(mmu_ifetch_valid)
    ,.ic_error_i(mmu_ifetch_error)
    ,.ic_inst_i(mmu_ifetch_inst)
    ,.ic_page_fault_i(fetch_in_fault)
    ,.f_invalidate_i(ifence)
    ,.br_request_i(branch_request)
    ,.br_pc_i(branch_pc)
    ,.br_priv_i(branch_priv)
    
    ,.f_valid_o(fetch_dec_valid)
    ,.f_instr_o(fetch_dec_instr)
    ,.f_pc_o(fetch_dec_pc)
    ,.f_fault_o(fetch_dec_fault_fetch)
    ,.f_fault_page_o(fetch_dec_fault_page)
    ,.ic_rd_o(mmu_ifetch_rd)
    ,.ic_flush_o(mmu_ifetch_flush)
    ,.ic_invalidate_o(mmu_ifetch_invalidate)
    ,.ic_pc_o(mmu_ifetch_pc)
    ,.ic_priv_o(fetch_in_priv)
    ,.squash_decode_o(squash_decode)
);

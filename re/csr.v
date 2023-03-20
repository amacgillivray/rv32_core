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

module csr 
#( 
    parameter SUPPORT_MULDIV = 1,
    parameter SUPPORT_SUPER  = 1
)
(
    ///////////////////
    // INPUTS 
    ///////////////////

    // CLOCK / RESET
     input clk
    ,input rst
    
    // INTR
    ,input intr
    
    // OPCODE
    ,input oc_valid
    ,input [31:0] oc_oc
    ,input [31:0] oc_pc
    ,input oc_invalid
    ,input [4:0] oc_rd_idx
    ,input [4:0] oc_ra_idx
    ,input [4:0] oc_rb_idx
    ,input [31:0] oc_ra_operand
    ,input [31:0] oc_rb_operand
    
    // CSR
    ,input csr_wb_write
    ,input [11:0] csr_wb_waddr
    ,input [31:0] csr_wb_wdata
    ,input [5:0] csr_wb_except
    ,input [31:0] csr_wb_except_pc
    ,input [31:0] csr_wb_except_addr
    
    // MISC
    ,input [31:0] cpu_id
    ,input [31:0] reset_vector
    ,input interrupt_inhibit

    ///////////////////
    // OUTPUTS
    ///////////////////

    // CONTROL / STATUS REGISTER
    ,output [31:0] csr_re1_value
    ,output csr_re1_write
    ,output [31:0] csr_re1_wdata
    ,output [5:0] csr_re1_exception

    // BRANCH CSR
    ,output bcsr_request
    ,output [31:0] bcsr_pc
    ,output [1:0] bcsr_priv
    
    // MISC
    ,output take_interrupt
    ,output ifence
    
    // MEMORY MANAGEMENT UNIT
    ,output [1:0] mmu_priv_d
    ,output mmu_sum
    ,output mmu_mxr
    ,output mmu_flush
    ,output [31:0] mmu_satp
);

`include "defs.v"

wire ecall = oc_valid && ((oc_oc & `M_ECALL) == `I_ECALL);
wire ebreak = oc_valid && ((oc_oc & `M_EBREAK) == `I_EBREAK);
wire eret = oc_valid && ((oc_oc & `M_ERET) == `I_ERET);
wire [1:0] eret_priv = oc_oc[29:28];
wire csrrw = oc_valid && ((oc_oc & `M_CSRRW) == `I_CSRRW);
wire csrrs = oc_valid && ((oc_oc & `M_CSRRS) == `I_CSRRS);
wire csrrc = oc_valid && ((oc_oc & `M_CSRRC) == `I_CSRRC);
wire csrrwi = oc_valid && ((oc_oc & `M_CSRRWI) == `I_CSRRWI);
wire csrrsi = oc_valid && ((oc_oc & `M_CSRRSI) == `I_CSRRSI);
wire csrrci = oc_valid && ((oc_oc & `M_CSRRCI) == `I_CSRRCI);
wire wfi = oc_valid && ((oc_oc & `M_WFI) == `I_WFI);
wire fence = oc_valid && ((oc_oc & `M_FENCE) == `I_FENCE);
wire sfence = oc_valid && ((oc_oc & `M_SFENCE) == `I_SFENCE);
wire ifence_w = oc_valid && ((oc_oc & `M_IFENCE) == `I_IFENCE);

// CSR
reg set;
reg clr;
wire [1:0] current_priv;
reg [1:0] csr_priv;
reg csr_readonly;
reg csr_write;
reg csr_fault;
reg [31:0] data;
always @ *
begin 
    set = csrrw | csrrs | csrrwi | csrrsi;
    clr = csrrw | csrrc | csrrwi | csrrci;

    csr_priv     = oc_oc[29:28];
    csr_readonly = (oc_oc[31:0] == 2'd3);
    csr_write    = (oc_ra_idx != 5'b0) | csrrw | csrrwi;
    
    data = (csrrwi | csrrsi | csrrci) ? {27'b0, oc_ra_idx} : oc_ra_operand;

    csr_fault = SUPPORT_SUPER
        ? ( oc_valid && 
          (set | clr) && // TODO: double check bitwise or
          ((csr_write && csr_readonly) || current_priv < csr_priv)) 
        : 1'b0;
end
wire satp_update =  (oc_valid && 
                    (set || clr) && 
                     csr_write && 
                    (oc_oc[31:20] == `CSR_SATP));
                
// CSR REGFILE
wire timer_irq = 1'b0;
wire [31:0] misa = SUPPORT_MULDIV ? (`MISA_RV32 | `MISA_RVI | `MISA_RVM) : (`MISA_RV32 | `MISA_RVI);
wire [31:0] csr_rdata;
wire csr_branch;
wire [31:0] csr_target;
wire [31:0] interrupt;
wire [31:0] status_reg;
wire [31:0] satp_reg;

csr_regfile
#(
    .SUPPORT_MTIMECMP(1),
    .SUPPORT_SUPER(SUPPORT_SUPER)
) u_csr_regfile (
    .clk(clk),
    .rst(rst),
    
    .ext_intr_i(intr),
    .timer_intr_i(timer_irq),
    .cpu_id_i(cpu_id),
    .misa_i(misa),
    
    .exception_i(csr_wb_except),
    .exception_pc_i(csr_wb_except_pc),
    .exception_addr_i(csr_wb_except_addr),
    
    .csr_ren_i(oc_valid),
    .csr_raddr_i(oc_oc[31:20]),
    .csr_rdata_o(csr_rdata),
    .csr_waddr_i(csr_wb_write ? csr_wb_waddr : 12'b0),
    .csr_wdata_i(csr_wb_wdata),
    .csr_branch_o(csr_branch),
    .csr_target_o(csr_target),
    
    .priv_o(current_priv),
    .status_o(status_reg),
    .satp_o(satp_reg),

    .interrupt_o(interrupt)
);

reg rd_valid_e1;
reg [31:0] rd_result_e1;
reg [31:0] csr_wdata_e1;
reg [`EXCEPTION_W-1:0] exception_e1;

wire eret_fault = eret && (current_priv < eret_priv);

always @ (posedge clk or posedge rst)
if (rst)
begin
    rd_valid_e1 <= 1'b0;
    rd_result_e1 <= 32'b0;
    csr_wdata_e1 <= 32'b0;
    exception_e1 <= `EXCEPTION_W'b0;
end 
else if (oc_valid)
begin 
    rd_valid_e1 <= (set || clr) && ~csr_fault;
    
    // if there's a fault, record the opcode 
    if (oc_invalid || csr_fault || eret_fault)
        rd_result_e1 <= oc_oc;
    else
        rd_result_e1 <= csr_rdata;

    // TODO: define all `DEFINITION refs
    if ((oc_oc & `M_ECALL) == `I_ECALL)
        exception_e1 <= `EXCEPTION_ECALL + {4'b0, current_priv};

    else if (eret_fault)
        exception_e1 <= `EXCEPTION_ILLEGAL_INSTRUCTION;

    else if ((oc_oc & `M_ERET) == `I_ERET)
        exception_e1 <= `EXCEPTION_ERET_U + {4'b0, eret_priv};

    else if ((oc_oc & `M_EBREAK) == `I_EBREAK)
        exception_e1 <= `EXCEPTION_BREAKPOINT;
    
    else if (oc_invalid || csr_fault)
        exception_e1 <= `EXCEPTION_ILLEGAL_INSTRUCTION;
    
    else if (satp_update || ifence_w || sfence)
        exception_e1 <= `EXCEPTION_FENCE;

    else
        exception_e1 <= `EXCEPTION_W'b0;

    // get wdata 
    if (set && clr)
        csr_wdata_e1 <= data;
    else if (set)
        csr_wdata_e1 <= csr_rdata | data;
    else if (clr)
        csr_wdata_e1 <= csr_rdata & ~data;
end
else
begin
    rd_valid_e1  <= 1'b0;
    rd_result_e1 <= 32'b0;
    csr_wdata_e1 <= 32'b0;
    exception_e1 <= `EXCEPTION_W'b0;
end 
assign csr_re1_exception = rd_result_e1;
assign csr_re1_write = rd_valid_e1;
assign csr_re1_wdata = csr_wdata_e1;
assign csr_re1_exception = exception_e1; 

// Interrupt
reg take_interrupt_q; 
always @ (posedge clk or posedge rst)
if (rst)
    take_interrupt_q <= 1'b0;
else 
    take_interrupt_q <= (|interrupt) & ~interrupt_inhibit;
assign take_interrupt = take_interrupt_q;

// TLB Flush
reg tlb_flush;
always @ (posedge clk or posedge rst)
if (rst)
    tlb_flush <= 1'b0;
else
    tlb_flush <= satp_update || sfence;

// ifence
reg ifence_q;
always @ (posedge clk or posedge rst)
if (rst)
    ifence_q <= 1'b0;
else 
    ifence_q <= ifence_w;
assign ifence = ifence_q;

// Execute - Branch Operations
reg [31:0] branch_target;
reg branch;
reg reset_q;
always @ (posedge clk or posedge rst)
if (rst)
begin
    branch_target <= 32'b0;
    branch <= 1'b0;
    reset_q <= 1'b1;
end
else if (reset_q)
begin
    branch_target <= reset_vector;
    branch <= 1'b1;
    reset_q <= 1'b0;
end
else
begin
    branch_target <= csr_target;
    branch <= csr_branch;
end
assign branch_csr_request = branch;
assign branch_csr_pc = branch_target;
assign branch_csr_priv = satp_reg[`SATP_MODE_R] ? current_priv : `PRIV_MACHINE;

assign mmu_priv_d = status_reg[`SR_MPRV_R] ? status_reg[`SR_MPP_R] : current_priv;
assign mmu_satp = satp_reg;
assign mmu_flush = tlb_flush;
assign mmu_sum = status_reg[`SR_SUM_R];
assign mmu_mxr = status_reg[`SR_MXR_R];

endmodule

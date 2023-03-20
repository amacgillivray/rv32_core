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

// Rewritten by Aditi Darade with heavy reference to the original code

// Includes the following file
`include "defs.v"

module decoder
(
    // Inputs
     input          InValid
    ,input          InFetchFault
    ,input          InEnableMuldiv
    ,input  [31:0]  InOpcode
    
    // Outputs
    ,output         OutInvalid
    ,output         OutExec
    ,output         OutLsu
    ,output         OutBranch
    ,output         OutMul
    ,output         OutDiv
    ,output         OutCsr
    ,output         OutRdValid
);

// Instruction invalid
wire WInvalid = InValid && 
                ~(((InOpcode & `M_ANDI) == `I_ANDI) ||
                ((InOpcode & `M_ADDI) == `I_ADDI)  ||
                ((InOpcode & `M_SLTI) == `I_SLTI)  ||
                ((InOpcode & `M_SLTIU) == `I_SLTIU) ||
                ((InOpcode & `M_ORI) == `I_ORI) ||
                ((InOpcode & `M_XORI) == `I_XORI) ||
                ((InOpcode & `M_SLLI) == `I_SLLI) ||
                ((InOpcode & `M_SRLI) == `I_SRLI) ||
                ((InOpcode & `M_SRAI) == `I_SRAI) ||
                ((InOpcode & `M_LUI) == `I_LUI) ||
                ((InOpcode & `M_AUIPC) == `I_AUIPC) ||
                ((InOpcode & `M_ADD) == `I_ADD) ||
                ((InOpcode & `M_SUB) == `I_SUB) ||
                ((InOpcode & `M_SLT) == `I_SLT) ||
                ((InOpcode & `M_SLTU) == `I_SLTU) ||
                ((InOpcode & `M_XOR) == `I_XOR) ||
                ((InOpcode & `M_OR) == `I_OR) ||
                ((InOpcode & `M_AND) == `I_AND) ||
                ((InOpcode & `M_SLL) == `I_SLL) ||
                ((InOpcode & `M_SRL) == `I_SRL) ||
                ((InOpcode & `M_SRA) == `I_SRA) ||
                ((InOpcode & `M_JAL) == `I_JAL) ||
                ((InOpcode & `M_JALR) == `I_JALR) ||
                ((InOpcode & `M_BEQ) == `I_BEQ) ||
                ((InOpcode & `M_BNE) == `I_BNE) ||
                ((InOpcode & `M_BLT) == `I_BLT) ||
                ((InOpcode & `M_BGE) == `I_BGE) ||
                ((InOpcode & `M_BLTU) == `I_BLTU) ||
                ((InOpcode & `M_BGEU) == `I_BGEU) ||
                ((InOpcode & `M_LB) == `I_LB) ||
                ((InOpcode & `M_LH) == `I_LH) ||
                ((InOpcode & `M_LW) == `I_LW) ||
                ((InOpcode & `M_LBU) == `I_LBU) ||
                ((InOpcode & `M_LHU) == `I_LHU) ||
                ((InOpcode & `M_LWU) == `I_LWU) ||
                ((InOpcode & `M_SB) == `I_SB) ||
                ((InOpcode & `M_SH) == `I_SH) ||
                ((InOpcode & `M_SW) == `I_SW) ||
                ((InOpcode & `M_ECALL) == `I_ECALL) ||
                ((InOpcode & `M_EBREAK) == `I_EBREAK) ||
                ((InOpcode & `M_ERET) == `I_ERET) ||
                ((InOpcode & `M_CSRRW) == `I_CSRRW) ||
                ((InOpcode & `M_CSRRS) == `I_CSRRS) ||
                ((InOpcode & `M_CSRRC) == `I_CSRRC) ||
                ((InOpcode & `M_CSRRWI) == `I_CSRRWI) ||
                ((InOpcode & `M_CSRRSI) == `I_CSRRSI) ||
                ((InOpcode & `M_CSRRCI) == `I_CSRRCI) ||
                ((InOpcode & `M_WFI) == `I_WFI) ||
                ((InOpcode & `M_FENCE) == `I_FENCE) ||
                ((InOpcode & `M_IFENCE) == `I_IFENCE) ||
                ((InOpcode & `M_SFENCE) == `I_SFENCE) ||
                (InEnableMuldiv && (InOpcode & `M_MUL) == `I_MUL) ||
                (InEnableMuldiv && (InOpcode & `M_MULH) == `I_MULH) ||
                (InEnableMuldiv && (InOpcode & `M_MULHSU) == `I_MULHSU) ||
                (InEnableMuldiv && (InOpcode & `M_MULHU) == `I_MULHU) ||
                (InEnableMuldiv && (InOpcode & `M_DIV) == `I_DIV) ||
                (InEnableMuldiv && (InOpcode & `M_DIVU) == `I_DIVU) ||
                (InEnableMuldiv && (InOpcode & `M_REM) == `I_REM) ||
                (InEnableMuldiv && (InOpcode & `M_REMU) == `I_REMU));


assign OutInvalid = WInvalid;
assign OutRdValid = ((InOpcode & `M_JALR) == `I_JALR) ||
                    ((InOpcode & `M_JAL) == `I_JAL) ||
                    ((InOpcode & `M_LUI) == `I_LUI) ||
                    ((InOpcode & `M_AUIPC) == `I_AUIPC) ||
                    ((InOpcode & `M_ADDI) == `I_ADDI) ||
                    ((InOpcode & `M_SLLI) == `I_SLLI) ||
                    ((InOpcode & `M_SLTI) == `I_SLTI) ||
                    ((InOpcode & `M_SLTIU) == `I_SLTIU) ||
                    ((InOpcode & `M_XORI) == `I_XORI) ||
                    ((InOpcode & `M_SRLI) == `I_SRLI) ||
                    ((InOpcode & `M_SRAI) == `I_SRAI) ||
                    ((InOpcode & `M_ORI) == `I_ORI) ||
                    ((InOpcode & `M_ANDI) == `I_ANDI) ||
                    ((InOpcode & `M_ADD) == `I_ADD) ||
                    ((InOpcode & `M_SUB) == `I_SUB) ||
                    ((InOpcode & `M_SLL) == `I_SLL) ||
                    ((InOpcode & `M_SLT) == `I_SLT) ||
                    ((InOpcode & `M_SLTU) == `I_SLTU) ||
                    ((InOpcode & `M_XOR) == `I_XOR) ||
                    ((InOpcode & `M_SRL) == `I_SRL) ||
                    ((InOpcode & `M_SRA) == `I_SRA) ||
                    ((InOpcode & `M_OR) == `I_OR) ||
                    ((InOpcode & `M_AND) == `I_AND) ||
                    ((InOpcode & `M_LB) == `I_LB) ||
                    ((InOpcode & `M_LH) == `I_LH) ||
                    ((InOpcode & `M_LW) == `I_LW) ||
                    ((InOpcode & `M_LBU) == `I_LBU) ||
                    ((InOpcode & `M_LHU) == `I_LHU) ||
                    ((InOpcode & `M_LWU) == `I_LWU) ||
                    ((InOpcode & `M_MUL) == `I_MUL) ||
                    ((InOpcode & `M_MULH) == `I_MULH) ||
                    ((InOpcode & `M_MULHSU) == `I_MULHSU) ||
                    ((InOpcode & `M_MULHU) == `I_MULHU) ||
                    ((InOpcode & `M_DIV) == `I_DIV) ||
                    ((InOpcode & `M_DIVU) == `I_DIVU) ||
                    ((InOpcode & `M_REM) == `I_REM) ||
                    ((InOpcode & `M_REMU) == `I_REMU) ||
                    ((InOpcode & `M_CSRRW) == `I_CSRRW) ||
                    ((InOpcode & `M_CSRRS) == `I_CSRRS) ||
                    ((InOpcode & `M_CSRRC) == `I_CSRRC) ||
                    ((InOpcode & `M_CSRRWI) == `I_CSRRWI) ||
                    ((InOpcode & `M_CSRRSI) == `I_CSRRSI) ||
                    ((InOpcode & `M_CSRRCI) == `I_CSRRCI);

// Exec
assign OutExec = ((InOpcode & `M_ANDI) == `I_ANDI) ||
                ((InOpcode & `M_ADDI) == `I_ADDI) ||
                ((InOpcode & `M_SLTI) == `I_SLTI) ||
                ((InOpcode & `M_SLTIU) == `I_SLTIU)||
                ((InOpcode & `M_ORI) == `I_ORI) ||
                ((InOpcode & `M_XORI) == `I_XORI) ||
                ((InOpcode & `M_SLLI) == `I_SLLI) ||
                ((InOpcode & `M_SRLI) == `I_SRLI) ||
                ((InOpcode & `M_SRAI) == `I_SRAI) ||
                ((InOpcode & `M_LUI) == `I_LUI) ||
                ((InOpcode & `M_AUIPC) == `I_AUIPC)||
                ((InOpcode & `M_ADD) == `I_ADD) ||
                ((InOpcode & `M_SUB) == `I_SUB)||
                ((InOpcode & `M_SLT) == `I_SLT) ||
                ((InOpcode & `M_SLTU) == `I_SLTU) ||
                ((InOpcode & `M_XOR) == `I_XOR) ||
                ((InOpcode & `M_OR) == `I_OR) ||
                ((InOpcode & `M_AND) == `I_AND) ||
                ((InOpcode & `M_SLL) == `I_SLL) ||
                ((InOpcode & `M_SRL) == `I_SRL) ||
                ((InOpcode & `M_SRA) == `I_SRA);

// Lsu
assign OutLsu = ((InOpcode & `M_LB) == `I_LB) ||
                ((InOpcode & `M_LH) == `I_LH) ||
                ((InOpcode & `M_LW) == `I_LW) ||
                ((InOpcode & `M_LBU) == `I_LBU) ||
                ((InOpcode & `M_LHU) == `I_LHU) ||
                ((InOpcode & `M_LWU) == `I_LWU) ||
                ((InOpcode & `M_SB) == `I_SB) ||
                ((InOpcode & `M_SH) == `I_SH) ||
                ((InOpcode & `M_SW) == `I_SW);

// Branch
assign OutBranch = ((InOpcode & `M_JAL) == `I_JAL)   ||
                ((InOpcode & `M_JALR) == `I_JALR) ||
                ((InOpcode & `M_BEQ) == `I_BEQ) ||
                ((InOpcode & `M_BNE) == `I_BNE) ||
                ((InOpcode & `M_BLT) == `I_BLT) ||
                ((InOpcode & `M_BGE) == `I_BGE) ||
                ((InOpcode & `M_BLTU) == `I_BLTU) ||
                ((InOpcode & `M_BGEU) == `I_BGEU);

// Mul
assign OutMul = InEnableMuldiv &&
                (((InOpcode & `M_MUL) == `I_MUL) ||
                ((InOpcode & `M_MULH) == `I_MULH) ||
                ((InOpcode & `M_MULHSU) == `I_MULHSU) ||
                ((InOpcode & `M_MULHU) == `I_MULHU));

// Div
assign OutDiv = InEnableMuldiv &&
                (((InOpcode & `M_DIV) == `I_DIV) ||
                ((InOpcode & `M_DIVU) == `I_DIVU) ||
                ((InOpcode & `M_REM) == `I_REM) ||
                ((InOpcode & `M_REMU) == `I_REMU));

// Csr
assign OutCsr = ((InOpcode & `M_ECALL) == `I_ECALL) ||
                ((InOpcode & `M_EBREAK) == `I_EBREAK) ||
                ((InOpcode & `M_ERET) == `I_ERET) ||
                ((InOpcode & `M_CSRRW) == `I_CSRRW) ||
                ((InOpcode & `M_CSRRS) == `I_CSRRS) ||
                ((InOpcode & `M_CSRRC) == `I_CSRRC) ||
                ((InOpcode & `M_CSRRWI) == `I_CSRRWI) ||
                ((InOpcode & `M_CSRRSI) == `I_CSRRSI) ||
                ((InOpcode & `M_CSRRCI) == `I_CSRRCI) ||
                ((InOpcode & `M_WFI) == `I_WFI) ||
                ((InOpcode & `M_FENCE) == `I_FENCE) ||
                ((InOpcode & `M_IFENCE) == `I_IFENCE) ||
                ((InOpcode & `M_SFENCE) == `I_SFENCE) ||
                WInvalid || InFetchFault;
endmodule

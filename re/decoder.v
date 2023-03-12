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
                ~(((InOpcode & `INST_ANDI_MASK) == `INST_ANDI) ||
                ((InOpcode & `INST_ADDI_MASK) == `INST_ADDI)  ||
                ((InOpcode & `INST_SLTI_MASK) == `INST_SLTI)  ||
                ((InOpcode & `INST_SLTIU_MASK) == `INST_SLTIU) ||
                ((InOpcode & `INST_ORI_MASK) == `INST_ORI) ||
                ((InOpcode & `INST_XORI_MASK) == `INST_XORI) ||
                ((InOpcode & `INST_SLLI_MASK) == `INST_SLLI) ||
                ((InOpcode & `INST_SRLI_MASK) == `INST_SRLI) ||
                ((InOpcode & `INST_SRAI_MASK) == `INST_SRAI) ||
                ((InOpcode & `INST_LUI_MASK) == `INST_LUI) ||
                ((InOpcode & `INST_AUIPC_MASK) == `INST_AUIPC) ||
                ((InOpcode & `INST_ADD_MASK) == `INST_ADD) ||
                ((InOpcode & `INST_SUB_MASK) == `INST_SUB) ||
                ((InOpcode & `INST_SLT_MASK) == `INST_SLT) ||
                ((InOpcode & `INST_SLTU_MASK) == `INST_SLTU) ||
                ((InOpcode & `INST_XOR_MASK) == `INST_XOR) ||
                ((InOpcode & `INST_OR_MASK) == `INST_OR) ||
                ((InOpcode & `INST_AND_MASK) == `INST_AND) ||
                ((InOpcode & `INST_SLL_MASK) == `INST_SLL) ||
                ((InOpcode & `INST_SRL_MASK) == `INST_SRL) ||
                ((InOpcode & `INST_SRA_MASK) == `INST_SRA) ||
                ((InOpcode & `INST_JAL_MASK) == `INST_JAL) ||
                ((InOpcode & `INST_JALR_MASK) == `INST_JALR) ||
                ((InOpcode & `INST_BEQ_MASK) == `INST_BEQ) ||
                ((InOpcode & `INST_BNE_MASK) == `INST_BNE) ||
                ((InOpcode & `INST_BLT_MASK) == `INST_BLT) ||
                ((InOpcode & `INST_BGE_MASK) == `INST_BGE) ||
                ((InOpcode & `INST_BLTU_MASK) == `INST_BLTU) ||
                ((InOpcode & `INST_BGEU_MASK) == `INST_BGEU) ||
                ((InOpcode & `INST_LB_MASK) == `INST_LB) ||
                ((InOpcode & `INST_LH_MASK) == `INST_LH) ||
                ((InOpcode & `INST_LW_MASK) == `INST_LW) ||
                ((InOpcode & `INST_LBU_MASK) == `INST_LBU) ||
                ((InOpcode & `INST_LHU_MASK) == `INST_LHU) ||
                ((InOpcode & `INST_LWU_MASK) == `INST_LWU) ||
                ((InOpcode & `INST_SB_MASK) == `INST_SB) ||
                ((InOpcode & `INST_SH_MASK) == `INST_SH) ||
                ((InOpcode & `INST_SW_MASK) == `INST_SW) ||
                ((InOpcode & `INST_ECALL_MASK) == `INST_ECALL) ||
                ((InOpcode & `INST_EBREAK_MASK) == `INST_EBREAK) ||
                ((InOpcode & `INST_ERET_MASK) == `INST_ERET) ||
                ((InOpcode & `INST_CSRRW_MASK) == `INST_CSRRW) ||
                ((InOpcode & `INST_CSRRS_MASK) == `INST_CSRRS) ||
                ((InOpcode & `INST_CSRRC_MASK) == `INST_CSRRC) ||
                ((InOpcode & `INST_CSRRWI_MASK) == `INST_CSRRWI) ||
                ((InOpcode & `INST_CSRRSI_MASK) == `INST_CSRRSI) ||
                ((InOpcode & `INST_CSRRCI_MASK) == `INST_CSRRCI) ||
                ((InOpcode & `INST_WFI_MASK) == `INST_WFI) ||
                ((InOpcode & `INST_FENCE_MASK) == `INST_FENCE) ||
                ((InOpcode & `INST_IFENCE_MASK) == `INST_IFENCE) ||
                ((InOpcode & `INST_SFENCE_MASK) == `INST_SFENCE) ||
                (InEnableMuldiv && (InOpcode & `INST_MUL_MASK) == `INST_MUL) ||
                (InEnableMuldiv && (InOpcode & `INST_MULH_MASK) == `INST_MULH) ||
                (InEnableMuldiv && (InOpcode & `INST_MULHSU_MASK) == `INST_MULHSU) ||
                (InEnableMuldiv && (InOpcode & `INST_MULHU_MASK) == `INST_MULHU) ||
                (InEnableMuldiv && (InOpcode & `INST_DIV_MASK) == `INST_DIV) ||
                (InEnableMuldiv && (InOpcode & `INST_DIVU_MASK) == `INST_DIVU) ||
                (InEnableMuldiv && (InOpcode & `INST_REM_MASK) == `INST_REM) ||
                (InEnableMuldiv && (InOpcode & `INST_REMU_MASK) == `INST_REMU));


assign OutInvalid = WInvalid;
assign OutRdValid = ((InOpcode & `INST_JALR_MASK) == `INST_JALR) ||
                    ((InOpcode & `INST_JAL_MASK) == `INST_JAL) ||
                    ((InOpcode & `INST_LUI_MASK) == `INST_LUI) ||
                    ((InOpcode & `INST_AUIPC_MASK) == `INST_AUIPC) ||
                    ((InOpcode & `INST_ADDI_MASK) == `INST_ADDI) ||
                    ((InOpcode & `INST_SLLI_MASK) == `INST_SLLI) ||
                    ((InOpcode & `INST_SLTI_MASK) == `INST_SLTI) ||
                    ((InOpcode & `INST_SLTIU_MASK) == `INST_SLTIU) ||
                    ((InOpcode & `INST_XORI_MASK) == `INST_XORI) ||
                    ((InOpcode & `INST_SRLI_MASK) == `INST_SRLI) ||
                    ((InOpcode & `INST_SRAI_MASK) == `INST_SRAI) ||
                    ((InOpcode & `INST_ORI_MASK) == `INST_ORI) ||
                    ((InOpcode & `INST_ANDI_MASK) == `INST_ANDI) ||
                    ((InOpcode & `INST_ADD_MASK) == `INST_ADD) ||
                    ((InOpcode & `INST_SUB_MASK) == `INST_SUB) ||
                    ((InOpcode & `INST_SLL_MASK) == `INST_SLL) ||
                    ((InOpcode & `INST_SLT_MASK) == `INST_SLT) ||
                    ((InOpcode & `INST_SLTU_MASK) == `INST_SLTU) ||
                    ((InOpcode & `INST_XOR_MASK) == `INST_XOR) ||
                    ((InOpcode & `INST_SRL_MASK) == `INST_SRL) ||
                    ((InOpcode & `INST_SRA_MASK) == `INST_SRA) ||
                    ((InOpcode & `INST_OR_MASK) == `INST_OR) ||
                    ((InOpcode & `INST_AND_MASK) == `INST_AND) ||
                    ((InOpcode & `INST_LB_MASK) == `INST_LB) ||
                    ((InOpcode & `INST_LH_MASK) == `INST_LH) ||
                    ((InOpcode & `INST_LW_MASK) == `INST_LW) ||
                    ((InOpcode & `INST_LBU_MASK) == `INST_LBU) ||
                    ((InOpcode & `INST_LHU_MASK) == `INST_LHU) ||
                    ((InOpcode & `INST_LWU_MASK) == `INST_LWU) ||
                    ((InOpcode & `INST_MUL_MASK) == `INST_MUL) ||
                    ((InOpcode & `INST_MULH_MASK) == `INST_MULH) ||
                    ((InOpcode & `INST_MULHSU_MASK) == `INST_MULHSU) ||
                    ((InOpcode & `INST_MULHU_MASK) == `INST_MULHU) ||
                    ((InOpcode & `INST_DIV_MASK) == `INST_DIV) ||
                    ((InOpcode & `INST_DIVU_MASK) == `INST_DIVU) ||
                    ((InOpcode & `INST_REM_MASK) == `INST_REM) ||
                    ((InOpcode & `INST_REMU_MASK) == `INST_REMU) ||
                    ((InOpcode & `INST_CSRRW_MASK) == `INST_CSRRW) ||
                    ((InOpcode & `INST_CSRRS_MASK) == `INST_CSRRS) ||
                    ((InOpcode & `INST_CSRRC_MASK) == `INST_CSRRC) ||
                    ((InOpcode & `INST_CSRRWI_MASK) == `INST_CSRRWI) ||
                    ((InOpcode & `INST_CSRRSI_MASK) == `INST_CSRRSI) ||
                    ((InOpcode & `INST_CSRRCI_MASK) == `INST_CSRRCI);

// Exec
assign OutExec = ((InOpcode & `INST_ANDI_MASK) == `INST_ANDI) ||
                ((InOpcode & `INST_ADDI_MASK) == `INST_ADDI) ||
                ((InOpcode & `INST_SLTI_MASK) == `INST_SLTI) ||
                ((InOpcode & `INST_SLTIU_MASK) == `INST_SLTIU)||
                ((InOpcode & `INST_ORI_MASK) == `INST_ORI) ||
                ((InOpcode & `INST_XORI_MASK) == `INST_XORI) ||
                ((InOpcode & `INST_SLLI_MASK) == `INST_SLLI) ||
                ((InOpcode & `INST_SRLI_MASK) == `INST_SRLI) ||
                ((InOpcode & `INST_SRAI_MASK) == `INST_SRAI) ||
                ((InOpcode & `INST_LUI_MASK) == `INST_LUI) ||
                ((InOpcode & `INST_AUIPC_MASK) == `INST_AUIPC)||
                ((InOpcode & `INST_ADD_MASK) == `INST_ADD) ||
                ((InOpcode & `INST_SUB_MASK) == `INST_SUB)||
                ((InOpcode & `INST_SLT_MASK) == `INST_SLT) ||
                ((InOpcode & `INST_SLTU_MASK) == `INST_SLTU) ||
                ((InOpcode & `INST_XOR_MASK) == `INST_XOR) ||
                ((InOpcode & `INST_OR_MASK) == `INST_OR) ||
                ((InOpcode & `INST_AND_MASK) == `INST_AND) ||
                ((InOpcode & `INST_SLL_MASK) == `INST_SLL) ||
                ((InOpcode & `INST_SRL_MASK) == `INST_SRL) ||
                ((InOpcode & `INST_SRA_MASK) == `INST_SRA);

// Lsu
assign OutLsu = ((InOpcode & `INST_LB_MASK) == `INST_LB) ||
                ((InOpcode & `INST_LH_MASK) == `INST_LH) ||
                ((InOpcode & `INST_LW_MASK) == `INST_LW) ||
                ((InOpcode & `INST_LBU_MASK) == `INST_LBU) ||
                ((InOpcode & `INST_LHU_MASK) == `INST_LHU) ||
                ((InOpcode & `INST_LWU_MASK) == `INST_LWU) ||
                ((InOpcode & `INST_SB_MASK) == `INST_SB) ||
                ((InOpcode & `INST_SH_MASK) == `INST_SH) ||
                ((InOpcode & `INST_SW_MASK) == `INST_SW);

// Branch
assign OutBranch = ((InOpcode & `INST_JAL_MASK) == `INST_JAL)   ||
                ((InOpcode & `INST_JALR_MASK) == `INST_JALR) ||
                ((InOpcode & `INST_BEQ_MASK) == `INST_BEQ) ||
                ((InOpcode & `INST_BNE_MASK) == `INST_BNE) ||
                ((InOpcode & `INST_BLT_MASK) == `INST_BLT) ||
                ((InOpcode & `INST_BGE_MASK) == `INST_BGE) ||
                ((InOpcode & `INST_BLTU_MASK) == `INST_BLTU) ||
                ((InOpcode & `INST_BGEU_MASK) == `INST_BGEU);

// Mul
assign OutMul = InEnableMuldiv &&
                (((InOpcode & `INST_MUL_MASK) == `INST_MUL) ||
                ((InOpcode & `INST_MULH_MASK) == `INST_MULH) ||
                ((InOpcode & `INST_MULHSU_MASK) == `INST_MULHSU) ||
                ((InOpcode & `INST_MULHU_MASK) == `INST_MULHU));

// Div
assign OutDiv = InEnableMuldiv &&
                (((InOpcode & `INST_DIV_MASK) == `INST_DIV) ||
                ((InOpcode & `INST_DIVU_MASK) == `INST_DIVU) ||
                ((InOpcode & `INST_REM_MASK) == `INST_REM) ||
                ((InOpcode & `INST_REMU_MASK) == `INST_REMU));

// Csr
assign OutCsr = ((InOpcode & `INST_ECALL_MASK) == `INST_ECALL) ||
                ((InOpcode & `INST_EBREAK_MASK) == `INST_EBREAK) ||
                ((InOpcode & `INST_ERET_MASK) == `INST_ERET) ||
                ((InOpcode & `INST_CSRRW_MASK) == `INST_CSRRW) ||
                ((InOpcode & `INST_CSRRS_MASK) == `INST_CSRRS) ||
                ((InOpcode & `INST_CSRRC_MASK) == `INST_CSRRC) ||
                ((InOpcode & `INST_CSRRWI_MASK) == `INST_CSRRWI) ||
                ((InOpcode & `INST_CSRRSI_MASK) == `INST_CSRRSI) ||
                ((InOpcode & `INST_CSRRCI_MASK) == `INST_CSRRCI) ||
                ((InOpcode & `INST_WFI_MASK) == `INST_WFI) ||
                ((InOpcode & `INST_FENCE_MASK) == `INST_FENCE) ||
                ((InOpcode & `INST_IFENCE_MASK) == `INST_IFENCE) ||
                ((InOpcode & `INST_SFENCE_MASK) == `INST_SFENCE) ||
                WInvalid || InFetchFault;
endmodule
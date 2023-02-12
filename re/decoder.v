//-----------------------------------------------------------------
// Company: EECS 581 Team 11
// Engineer: Aditi Darade
// 
// Create Date: 01/29/2023 2:18 PM
// Project Name: Linear Algebra Accelerator
// Additional Comments:
// Experimental
//-----------------------------------------------------------------
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

`include "defs.v"

module decoder
(
     input                        InValid
    ,input                        InFetchFault
    ,input                        InEnableMuldiv
    ,input                        InEnableAtomic /* todo */
    ,input                        InEnableVector /* todo */
    ,input  [31:0]                InOpcode
    ,output                       OutInvalid
    ,output                       OutExec
    ,output                       OutLsu
    ,output                       OutBranch
    ,output                       OutMul
    ,output                       OutDiv
    ,output                       OutCsr
    ,output                       OutRdValid
);

/* Invalid instruction */
wire WInvalid =    InValid && 
                  ~(((InOpcode & `I_ANDI_MASK)   == `I_ANDI)            ||
                    ((InOpcode & `I_ADDI_MASK)   == `I_ADDI)            ||
                    ((InOpcode & `I_SLTI_MASK)   == `I_SLTI)            ||
                    ((InOpcode & `I_SLTIU_MASK)  == `I_SLTIU)           ||
                    ((InOpcode & `I_ORI_MASK)    == `I_ORI)             ||
                    ((InOpcode & `I_XORI_MASK)   == `I_XORI)            ||
                    ((InOpcode & `I_SLLI_MASK)   == `I_SLLI)            ||
                    ((InOpcode & `I_SRLI_MASK)   == `I_SRLI)            ||
                    ((InOpcode & `I_SRAI_MASK)   == `I_SRAI)            ||
                    ((InOpcode & `I_LUI_MASK)    == `I_LUI)             ||
                    ((InOpcode & `I_AUIPC_MASK)  == `I_AUIPC)           ||
                    ((InOpcode & `I_ADD_MASK)    == `I_ADD)             ||
                    ((InOpcode & `I_SUB_MASK)    == `I_SUB)             ||
                    ((InOpcode & `I_SLT_MASK)    == `I_SLT)             ||
                    ((InOpcode & `I_SLTU_MASK) == `I_SLTU)              ||
                    ((InOpcode & `I_XOR_MASK) == `I_XOR)                ||
                    ((InOpcode & `I_OR_MASK) == `I_OR)                  ||
                    ((InOpcode & `I_AND_MASK) == `I_AND)                ||
                    ((InOpcode & `I_SLL_MASK) == `I_SLL)                ||
                    ((InOpcode & `I_SRL_MASK) == `I_SRL)                ||
                    ((InOpcode & `I_SRA_MASK) == `I_SRA)                ||
                    ((InOpcode & `I_JAL_MASK) == `I_JAL)                ||
                    ((InOpcode & `I_JALR_MASK) == `I_JALR)              ||
                    ((InOpcode & `I_BEQ_MASK) == `I_BEQ)                ||
                    ((InOpcode & `I_BNE_MASK) == `I_BNE)                ||
                    ((InOpcode & `I_BLT_MASK) == `I_BLT)                ||
                    ((InOpcode & `I_BGE_MASK) == `I_BGE)                ||
                    ((InOpcode & `I_BLTU_MASK) == `I_BLTU)              ||
                    ((InOpcode & `I_BGEU_MASK) == `I_BGEU)              ||
                    ((InOpcode & `I_LB_MASK) == `I_LB)                  ||
                    ((InOpcode & `I_LH_MASK) == `I_LH)                  ||
                    ((InOpcode & `I_LW_MASK) == `I_LW)                  ||
                    ((InOpcode & `I_LBU_MASK) == `I_LBU)                ||
                    ((InOpcode & `I_LHU_MASK) == `I_LHU)                ||
                    ((InOpcode & `I_LWU_MASK) == `I_LWU)                ||
                    ((InOpcode & `I_SB_MASK) == `I_SB)                  ||
                    ((InOpcode & `I_SH_MASK) == `I_SH)                  ||
                    ((InOpcode & `I_SW_MASK) == `I_SW)                  ||
                    ((InOpcode & `I_ECALL_MASK) == `I_ECALL)            ||
                    ((InOpcode & `I_EBREAK_MASK) == `I_EBREAK)          ||
                    ((InOpcode & `I_ERET_MASK) == `I_ERET)              ||
                    ((InOpcode & `I_CSRRW_MASK) == `I_CSRRW)            ||
                    ((InOpcode & `I_CSRRS_MASK) == `I_CSRRS)            ||
                    ((InOpcode & `I_CSRRC_MASK) == `I_CSRRC)            ||
                    ((InOpcode & `I_CSRRWI_MASK) == `I_CSRRWI)          ||
                    ((InOpcode & `I_CSRRSI_MASK) == `I_CSRRSI)          ||
                    ((InOpcode & `I_CSRRCI_MASK) == `I_CSRRCI)          ||
                    ((InOpcode & `I_WFI_MASK) == `I_WFI)                ||
                    ((InOpcode & `I_FENCE_MASK) == `I_FENCE)            ||
                    ((InOpcode & `I_IFENCE_MASK) == `I_IFENCE)          ||
                    ((InOpcode & `I_SFENCE_MASK) == `I_SFENCE)          ||
                    (InEnableMuldiv && (InOpcode & `I_MUL_MASK) == `I_MUL)       ||
                    (InEnableMuldiv && (InOpcode & `I_MULH_MASK) == `I_MULH)     ||
                    (InEnableMuldiv && (InOpcode & `I_MULHSU_MASK) == `I_MULHSU) ||
                    (InEnableMuldiv && (InOpcode & `I_MULHU_MASK) == `I_MULHU)   ||
                    (InEnableMuldiv && (InOpcode & `I_DIV_MASK) == `I_DIV)       ||
                    (InEnableMuldiv && (InOpcode & `I_DIVU_MASK) == `I_DIVU)     ||
                    (InEnableMuldiv && (InOpcode & `I_REM_MASK) == `I_REM)       ||
                    (InEnableMuldiv && (InOpcode & `I_REMU_MASK) == `I_REMU));

assign OutInvalid = WInvalid;

assign OutRdValid = ((InOpcode & `I_JALR_MASK) == `I_JALR)     ||
                    ((InOpcode & `I_JAL_MASK) == `I_JAL)       ||
                    ((InOpcode & `I_LUI_MASK) == `I_LUI)       ||
                    ((InOpcode & `I_AUIPC_MASK) == `I_AUIPC)   ||
                    ((InOpcode & `I_ADDI_MASK) == `I_ADDI)     ||
                    ((InOpcode & `I_SLLI_MASK) == `I_SLLI)     ||
                    ((InOpcode & `I_SLTI_MASK) == `I_SLTI)     ||
                    ((InOpcode & `I_SLTIU_MASK) == `I_SLTIU)   ||
                    ((InOpcode & `I_XORI_MASK) == `I_XORI)     ||
                    ((InOpcode & `I_SRLI_MASK) == `I_SRLI)     ||
                    ((InOpcode & `I_SRAI_MASK) == `I_SRAI)     ||
                    ((InOpcode & `I_ORI_MASK) == `I_ORI)       ||
                    ((InOpcode & `I_ANDI_MASK) == `I_ANDI)     ||
                    ((InOpcode & `I_ADD_MASK) == `I_ADD)       ||
                    ((InOpcode & `I_SUB_MASK) == `I_SUB)       ||
                    ((InOpcode & `I_SLL_MASK) == `I_SLL)       ||
                    ((InOpcode & `I_SLT_MASK) == `I_SLT)       ||
                    ((InOpcode & `I_SLTU_MASK) == `I_SLTU)     ||
                    ((InOpcode & `I_XOR_MASK) == `I_XOR)       ||
                    ((InOpcode & `I_SRL_MASK) == `I_SRL)       ||
                    ((InOpcode & `I_SRA_MASK) == `I_SRA)       ||
                    ((InOpcode & `I_OR_MASK) == `I_OR)         ||
                    ((InOpcode & `I_AND_MASK) == `I_AND)       ||
                    ((InOpcode & `I_LB_MASK) == `I_LB)         ||
                    ((InOpcode & `I_LH_MASK) == `I_LH)         ||
                    ((InOpcode & `I_LW_MASK) == `I_LW)         ||
                    ((InOpcode & `I_LBU_MASK) == `I_LBU)       ||
                    ((InOpcode & `I_LHU_MASK) == `I_LHU)       ||
                    ((InOpcode & `I_LWU_MASK) == `I_LWU)       ||
                    ((InOpcode & `I_MUL_MASK) == `I_MUL)       ||
                    ((InOpcode & `I_MULH_MASK) == `I_MULH)     ||
                    ((InOpcode & `I_MULHSU_MASK) == `I_MULHSU) ||
                    ((InOpcode & `I_MULHU_MASK) == `I_MULHU)   ||
                    ((InOpcode & `I_DIV_MASK) == `I_DIV)       ||
                    ((InOpcode & `I_DIVU_MASK) == `I_DIVU)     ||
                    ((InOpcode & `I_REM_MASK) == `I_REM)       ||
                    ((InOpcode & `I_REMU_MASK) == `I_REMU)     ||
                    ((InOpcode & `I_CSRRW_MASK) == `I_CSRRW)   ||
                    ((InOpcode & `I_CSRRS_MASK) == `I_CSRRS)   ||
                    ((InOpcode & `I_CSRRC_MASK) == `I_CSRRC)   ||
                    ((InOpcode & `I_CSRRWI_MASK) == `I_CSRRWI) ||
                    ((InOpcode & `I_CSRRSI_MASK) == `I_CSRRSI) ||
                    ((InOpcode & `I_CSRRCI_MASK) == `I_CSRRCI);

assign OutExec =     ((InOpcode & `I_ANDI_MASK) == `I_ANDI)  ||
                    ((InOpcode & `I_ADDI_MASK) == `I_ADDI)  ||
                    ((InOpcode & `I_SLTI_MASK) == `I_SLTI)  ||
                    ((InOpcode & `I_SLTIU_MASK) == `I_SLTIU)||
                    ((InOpcode & `I_ORI_MASK) == `I_ORI)    ||
                    ((InOpcode & `I_XORI_MASK) == `I_XORI)  ||
                    ((InOpcode & `I_SLLI_MASK) == `I_SLLI)  ||
                    ((InOpcode & `I_SRLI_MASK) == `I_SRLI)  ||
                    ((InOpcode & `I_SRAI_MASK) == `I_SRAI)  ||
                    ((InOpcode & `I_LUI_MASK) == `I_LUI)    ||
                    ((InOpcode & `I_AUIPC_MASK) == `I_AUIPC)||
                    ((InOpcode & `I_ADD_MASK) == `I_ADD)    ||
                    ((InOpcode & `I_SUB_MASK) == `I_SUB)    ||
                    ((InOpcode & `I_SLT_MASK) == `I_SLT)    ||
                    ((InOpcode & `I_SLTU_MASK) == `I_SLTU)  ||
                    ((InOpcode & `I_XOR_MASK) == `I_XOR)    ||
                    ((InOpcode & `I_OR_MASK) == `I_OR)      ||
                    ((InOpcode & `I_AND_MASK) == `I_AND)    ||
                    ((InOpcode & `I_SLL_MASK) == `I_SLL)    ||
                    ((InOpcode & `I_SRL_MASK) == `I_SRL)    ||
                    ((InOpcode & `I_SRA_MASK) == `I_SRA);

assign OutLsu =      ((InOpcode & `I_LB_MASK) == `I_LB)   ||
                    ((InOpcode & `I_LH_MASK) == `I_LH)   ||
                    ((InOpcode & `I_LW_MASK) == `I_LW)   ||
                    ((InOpcode & `I_LBU_MASK) == `I_LBU) ||
                    ((InOpcode & `I_LHU_MASK) == `I_LHU) ||
                    ((InOpcode & `I_LWU_MASK) == `I_LWU) ||
                    ((InOpcode & `I_SB_MASK) == `I_SB)   ||
                    ((InOpcode & `I_SH_MASK) == `I_SH)   ||
                    ((InOpcode & `I_SW_MASK) == `I_SW);

assign OutBranch =   ((InOpcode & `I_JAL_MASK) == `I_JAL)   ||
                    ((InOpcode & `I_JALR_MASK) == `I_JALR) ||
                    ((InOpcode & `I_BEQ_MASK) == `I_BEQ)   ||
                    ((InOpcode & `I_BNE_MASK) == `I_BNE)   ||
                    ((InOpcode & `I_BLT_MASK) == `I_BLT)   ||
                    ((InOpcode & `I_BGE_MASK) == `I_BGE)   ||
                    ((InOpcode & `I_BLTU_MASK) == `I_BLTU) ||
                    ((InOpcode & `I_BGEU_MASK) == `I_BGEU);

assign OutMul =      InEnableMuldiv &&
                    (((InOpcode & `I_MUL_MASK) == `I_MUL)    ||
                    ((InOpcode & `I_MULH_MASK) == `I_MULH)   ||
                    ((InOpcode & `I_MULHSU_MASK) == `I_MULHSU) ||
                    ((InOpcode & `I_MULHU_MASK) == `I_MULHU));

assign OutDiv =      InEnableMuldiv &&
                    (((InOpcode & `I_DIV_MASK) == `I_DIV) ||
                    ((InOpcode & `I_DIVU_MASK) == `I_DIVU) ||
                    ((InOpcode & `I_REM_MASK) == `I_REM) ||
                    ((InOpcode & `I_REMU_MASK) == `I_REMU));

assign OutCsr =      ((InOpcode & `I_ECALL_MASK) == `I_ECALL)            ||
                    ((InOpcode & `I_EBREAK_MASK) == `I_EBREAK)          ||
                    ((InOpcode & `I_ERET_MASK) == `I_ERET)              ||
                    ((InOpcode & `I_CSRRW_MASK) == `I_CSRRW)            ||
                    ((InOpcode & `I_CSRRS_MASK) == `I_CSRRS)            ||
                    ((InOpcode & `I_CSRRC_MASK) == `I_CSRRC)            ||
                    ((InOpcode & `I_CSRRWI_MASK) == `I_CSRRWI)          ||
                    ((InOpcode & `I_CSRRSI_MASK) == `I_CSRRSI)          ||
                    ((InOpcode & `I_CSRRCI_MASK) == `I_CSRRCI)          ||
                    ((InOpcode & `I_WFI_MASK) == `I_WFI)                ||
                    ((InOpcode & `I_FENCE_MASK) == `I_FENCE)            ||
                    ((InOpcode & `I_IFENCE_MASK) == `I_IFENCE)          ||
                    ((InOpcode & `I_SFENCE_MASK) == `I_SFENCE)          ||
                    WInvalid || InFetchFault;

endmodule

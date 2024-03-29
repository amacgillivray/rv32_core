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


/* PRIVILEGE LEVELS */
`define PRIV_MACHINE 2'd3
`define PRIV_SUPER 2'd1
`define PRIV_USER 2'd0

/* ALU Operations -- defined in order they appear in alu.v */
`define ALU_ADD                     4'b0100
`define ALU_SUBTRACT                4'b0110
`define ALU_LESS_THAN               4'b1010
`define ALU_SIGNED_LESS_THAN        4'b1011 
`define ALU_AND                     4'b0111
`define ALU_OR                      4'b1000
`define ALU_XOR                     4'b1001
`define ALU_SHIFT_LEFT              4'b0001 
`define ALU_SHIFT_RIGHT             4'b0010
`define ALU_SHIFT_RIGHT_ARITHMETIC  4'b0011
`define ALU_NOOP                    4'b0000 /* not used */

/* Instruction Masks
   - 
   Masks are defined for specific instruction types, 
   and can be and-ed with an instruction to compare 
   the fields that identify what operation should be
   carried out.
 */
// Mask all but Funct7, Funct3, and Opcode fields
`define M_RTYPE 32'hfe00707f

// Mask all but Funct3 and Opcode fields
`define M_ITYPE 32'h707f


/* Instructions
   -
   For list, see https://mark.theis.site/riscv/
   https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
   https://people.eecs.berkeley.edu/~krste/papers/riscv-privileged-v1.9.pdf
   https://danielmangum.com/posts/risc-v-bytes-intro-instruction-formats/
   https://inst.eecs.berkeley.edu/~cs61c/resources/su18_lec/Lecture7.pdf
   - 
   Naming convention: 
    "I_x" is the instruction x
    "M_x" is the mask for instruction x
 */
// LUI rd,imm          | Load Upper Immediate
`define I_LUI 32'h37
`define M_LUI 32'h7f

// AUIPC rd,offset     | Add Upper Immediate to PC
`define I_AUIPC 32'h17
`define M_AUIPC 32'h7f

// JAL rd,offset       | Jump and Link 
`define I_JAL 32'h6f
`define M_JAL 32'h7f

// JALR rd,rs1,offset  | Jump and Link Register 
`define I_JALR 32'h67
`define M_JALR `M_ITYPE

// BEQ rs1,rs2,offset  | Branch Equal 
`define I_BEQ 32'h63
`define M_BEQ `M_ITYPE

// BNE rs1,rs2,offset  | Branch Not Equal
`define I_BNE 32'h1063 
`define M_BNE `M_ITYPE

// BLT rs1,rs2,offset  | Branch Less Than
`define I_BLT 32'h4063
`define M_BLT `M_ITYPE

// BGE rs1,rs2,offset  | Branch Greater Than Equal
`define I_BGE 32'h5063
`define M_BGE `M_ITYPE

// BLTU rs1,rs2,offset | Branch Less Than Unsigned 
`define I_BLTU 32'h6063
`define M_BLTU `M_ITYPE

// BGEU rs1,rs2,offset | Branch Greater Than Equal Unsigned 
`define I_BGEU 32'h7063
`define M_BGEU `M_ITYPE

// LB rd,offset(rs1)   | Load Byte -
`define I_LB 32'h3
`define M_LB `M_ITYPE

// LH rd,offset(rs1)   | Load Half
`define I_LH 32'h1003
`define M_LH `M_ITYPE

// LW rd,offset(rs1)   | Load Word
`define I_LW 32'h2003
`define M_LW `M_ITYPE

// LBU rd,offset(rs1)  | Load Byte Unsigned 
`define I_LBU 32'h4003
`define M_LBU `M_ITYPE

// LHU rd,offset(rs1)  | Load Half Unsigned
`define I_LHU 32'h5003
`define M_LHU `M_ITYPE

// LWU
`define I_LWU 32'h6003
`define M_LWU `M_ITYPE

// SB rs2,offset(rs1)  | Store Byte
`define I_SB 32'h23
`define M_SB `M_ITYPE

// SH rs2,offset(rs1)  | Store Half 
`define I_SH 32'h1023
`define M_SH `M_ITYPE

// SW rs2,offset(rs1)  | Store Word
`define I_SW 32'h2023
`define M_SW `M_ITYPE

// ADDI rd,rs1,imm     | Add Immediate
`define I_ADDI 32'h7013
`define M_ADDI `M_ITYPE

// SLTI rd,rs1,imm     | Set Less Than Immediate
`define I_SLTI 32'h2013
`define M_SLTI `M_ITYPE 

// SLTIU rd,rs1,imm    | Set Less Than Immediate Unsigned
`define I_SLTIU 32'h3013
`define M_SLTIU `M_ITYPE

// XORI rd,rs1,imm     | XOR immediate
`define I_XORI 32'h4013
`define M_XORI `M_ITYPE

// ORI rd,rs1,imm      | OR immediate
`define I_ORI 32'h6013
`define M_ORI `M_ITYPE

// ANDI rd,rs1,imm     | AND immediate
`define I_ANDI 32'h7013
`define M_ANDI `M_ITYPE

// SLLI rd,rs1,imm     | Shift Left Logical Immediate 
`define I_SLLI 32'h1013
`define M_SLLI 32'hfc00707f

// SRLI rd,rs1,imm     | Shift Right Logical Immediate
`define I_SRLI 32'h5013
`define M_SRLI 32'hfc00707f

// SRAI rd,rs1,imm     | Shift Right Logical Immediate
`define I_SRAI 32'h40005013
`define M_SRAI 32'hfc00707f

// ADD rd,rs1,rs2      | Add
`define I_ADD 32'h33
`define M_ADD `M_RTYPE

// SUB rd,rs1,rs2      | Sub
`define I_SUB 32'h40000033
`define M_SUB `M_RTYPE

// SLL rd,rs1,rs2      | Shift Left Logical
`define I_SLL 32'h1033
`define M_SLL `M_RTYPE

// SLT
`define I_SLT 32'h2033
`define M_SLT `M_RTYPE

// SLTU
`define I_SLTU 32'h3033
`define M_SLTU `M_RTYPE

// SRL  --- ?? todo 
`define I_SRL 32'h5033
`define M_SRL `M_RTYPE

// SRA rd,rs1,rs2      | Shift Right Arithmetic
`define I_SRA 32'h40005033
`define M_SRA `M_RTYPE

// XOR                 | Exclusive Or
`define I_XOR 32'h4033
`define M_XOR `M_RTYPE

// OR rd,rs1,rs2       | OR 
`define I_OR 32'h6033
`define M_OR `M_RTYPE

// AND rd,rs1,rs2      | AND 
`define I_AND 32'h7033
`define M_AND `M_RTYPE

// ECALL
`define I_ECALL 32'h73
`define M_ECALL 32'hffffffff

// EBREAK
`define I_EBREAK 32'h100073
`define M_EBREAK 32'hffffffff

// ERET
`define I_ERET 32'h200073
`define M_ERET 32'hcfffffff

// CSRRW
`define I_CSRRW 32'h1073
`define M_CSRRW `M_ITYPE

// CSRRS
`define I_CSRRS 32'h2073
`define M_CSRRS `M_ITYPE

// CSRRC
`define I_CSRRC 32'h3073
`define M_CSRRC `M_ITYPE

// CSRRWI
`define I_CSRRWI 32'h5073
`define M_CSRRWI `M_ITYPE

// CSRRSI
`define I_CSRRSI 32'h6073
`define M_CSRRSI `M_ITYPE

// CSRRCI
`define I_CSRRCI 32'h7073
`define M_CSRRCI `M_ITYPE

// WFI
`define I_WFI 32'h10500073
`define M_WFI 32'hffff8fff

// FENCE pred,succ     | Fence 
`define I_FENCE 32'hf
`define M_FENCE `M_ITYPE

// SFENCE 
`define I_SFENCE 32'h12000073
`define M_SFENCE 32'hfe007fff

// FENCE.I             | Fence Instruction
`define I_IFENCE 32'h100f
`define M_IFENCE `M_ITYPE

/* TODO - Atomics */
/* RISCV M EXTENSION INSTRUCTIONS -- Multiplication / Division */
// MUL
`define I_MUL 32'h2000033
`define M_MUL `M_RTYPE

// MULH
`define I_MULH 32'h2001033
`define M_MULH `M_RTYPE

// MULHSU
`define I_MULHSU 32'h2002033
`define M_MULHSU `M_RTYPE

// MULHU
`define I_MULHU 32'h2003033
`define M_MULHU `M_RTYPE

// DIV
`define I_DIV 32'h2004033
`define M_DIV `M_RTYPE

// DIVU
`define I_DIVU 32'h2005033
`define M_DIVU `M_RTYPE

// REM
`define I_REM 32'h2006033
`define M_REM `M_RTYPE

// REMU 
`define I_REMU 32'h2007033
`define M_REMU `M_RTYPE
/* TODO - Vector Extension Instructions */


//--------------------------------------------------------------------
// IRQ Numbers
//--------------------------------------------------------------------
// Taken direct from other repo
`define IRQ_S_SOFT   1
`define IRQ_M_SOFT   3
`define IRQ_S_TIMER  5
`define IRQ_M_TIMER  7
`define IRQ_S_EXT    9
`define IRQ_M_EXT    11
`define IRQ_MIN      (`IRQ_S_SOFT)
`define IRQ_MAX      (`IRQ_M_EXT + 1)
`define IRQ_MASK     ((1 << `IRQ_M_EXT) | (1 << `IRQ_S_EXT) | (1 << `IRQ_M_TIMER) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_M_SOFT) | (1 << `IRQ_S_SOFT))
`define SR_IP_MSIP_R `IRQ_M_SOFT
`define SR_IP_MTIP_R `IRQ_M_TIMER
`define SR_IP_MEIP_R `IRQ_M_EXT
`define SR_IP_SSIP_R `IRQ_S_SOFT
`define SR_IP_STIP_R `IRQ_S_TIMER
`define SR_IP_SEIP_R `IRQ_S_EXT


//--------------------------------------------------------------------
// CSR Registers
//--------------------------------------------------------------------
// taken directly from the other repository
`define CSR_MSTATUS       12'h300
`define CSR_MSTATUS_MASK  32'hFFFFFFFF
`define CSR_MISA          12'h301
`define CSR_MISA_MASK     32'hFFFFFFFF
    `define MISA_RV32     32'h40000000
    `define MISA_RVI      32'h00000100
    `define MISA_RVE      32'h00000010
    `define MISA_RVM      32'h00001000
    `define MISA_RVA      32'h00000001
    `define MISA_RVF      32'h00000020
    `define MISA_RVD      32'h00000008
    `define MISA_RVC      32'h00000004
    `define MISA_RVS      32'h00040000
    `define MISA_RVU      32'h00100000
`define CSR_MEDELEG       12'h302
`define CSR_MEDELEG_MASK  32'h0000FFFF
`define CSR_MIDELEG       12'h303
`define CSR_MIDELEG_MASK  32'h0000FFFF
`define CSR_MIE           12'h304
`define CSR_MIE_MASK      `IRQ_MASK
`define CSR_MTVEC         12'h305
`define CSR_MTVEC_MASK    32'hFFFFFFFF
`define CSR_MSCRATCH      12'h340
`define CSR_MSCRATCH_MASK 32'hFFFFFFFF
`define CSR_MEPC          12'h341
`define CSR_MEPC_MASK     32'hFFFFFFFF
`define CSR_MCAUSE        12'h342
`define CSR_MCAUSE_MASK   32'h8000000F
`define CSR_MTVAL         12'h343
`define CSR_MTVAL_MASK    32'hFFFFFFFF
`define CSR_MIP           12'h344
`define CSR_MIP_MASK      `IRQ_MASK
`define CSR_MCYCLE        12'hc00
`define CSR_MCYCLE_MASK   32'hFFFFFFFF
`define CSR_MTIME         12'hc01
`define CSR_MTIME_MASK    32'hFFFFFFFF
`define CSR_MTIMEH        12'hc81
`define CSR_MTIMEH_MASK   32'hFFFFFFFF
`define CSR_MHARTID       12'hF14
`define CSR_MHARTID_MASK  32'hFFFFFFFF
// Non-std
`define CSR_MTIMECMP        12'h7c0
`define CSR_MTIMECMP_MASK   32'hFFFFFFFF


//-----------------------------------------------------------------
// CSR Registers - Supervisor
//-----------------------------------------------------------------
// Taken directly from the other repository
`define CSR_SSTATUS       12'h100
`define CSR_SSTATUS_MASK  `SR_SMODE_MASK
`define CSR_SIE           12'h104
`define CSR_SIE_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_STVEC         12'h105
`define CSR_STVEC_MASK    32'hFFFFFFFF
`define CSR_SSCRATCH      12'h140
`define CSR_SSCRATCH_MASK 32'hFFFFFFFF
`define CSR_SEPC          12'h141
`define CSR_SEPC_MASK     32'hFFFFFFFF
`define CSR_SCAUSE        12'h142
`define CSR_SCAUSE_MASK   32'h8000000F
`define CSR_STVAL         12'h143
`define CSR_STVAL_MASK    32'hFFFFFFFF
`define CSR_SIP           12'h144
`define CSR_SIP_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_SATP          12'h180
`define CSR_SATP_MASK     32'hFFFFFFFF

//--------------------------------------------------------------------
// CSR Registers - DCACHE control
//--------------------------------------------------------------------
// DIRECT
`define CSR_DFLUSH            12'h3a0 // pmpcfg0
`define CSR_DFLUSH_MASK       32'hFFFFFFFF
`define CSR_DWRITEBACK        12'h3a1 // pmpcfg1
`define CSR_DWRITEBACK_MASK   32'hFFFFFFFF
`define CSR_DINVALIDATE       12'h3a2 // pmpcfg2
`define CSR_DINVALIDATE_MASK  32'hFFFFFFFF


/* STATUS REGISTER */
`define SR_UIE_R  0
`define SR_UIE    (1 << `SR_UIE_R)
`define SR_SIE_R  1
`define SR_SIE    (1 << `SR_SIE_R)
`define SR_MIE_R  3
`define SR_MIE    (1 << `SR_MIE_R)
`define SR_UPIE_R 4
`define SR_UPIE   (1 << `SR_UPIE_R)
`define SR_SPIE_R 5
`define SR_SPIE   (1 << `SR_SPIE_R)
`define SR_MPIE_R 7
`define SR_MPIE   (1 << `SR_MPIE_R)
`define SR_SPP_R  8
`define SR_SPP    (1 << `SR_SPP_R)
`define SR_MPP_SHIFT 11
`define SR_MPP_MASK  2'h3
`define SR_MPP_R     12:11
`define SR_MPP_U     `PRIV_USER
`define SR_MPP_S     `PRIV_SUPER
`define SR_MPP_M     `PRIV_MACHINE
`define SR_SUM_R   18
`define SR_SUM     (1 << `SR_SUM_R)
`define SR_MPRV_R  17
`define SR_MPRV    (1 << `SR_MPRV_R)
`define SR_MXR_R   19
`define SR_MXR     (1 << `SR_MXR_R)
`define SR_SMODE_MASK (`SR_UIE | `SR_SIE | `SR_UPIE | `SR_SPIE | `SR_SPP | `SR_SUM)

//--------------------------------------------------------------------
// SATP definitions
//--------------------------------------------------------------------
// Taken directly from other repository
`define SATP_PPN_R        19:0 // TODO: Should be 21?? (UE comment)
`define SATP_ASID_R       30:22
`define SATP_MODE_R       31

//--------------------------------------------------------------------
// MMU Defs (SV32)
//--------------------------------------------------------------------
// Direct
`define MMU_LEVELS        2
`define MMU_PTIDXBITS     10
`define MMU_PTESIZE       4
`define MMU_PGSHIFT       (`MMU_PTIDXBITS + 2)
`define MMU_PGSIZE        (1 << `MMU_PGSHIFT)
`define MMU_VPN_BITS      (`MMU_PTIDXBITS * `MMU_LEVELS)
`define MMU_PPN_BITS      (32 - `MMU_PGSHIFT)
`define MMU_VA_BITS       (`MMU_VPN_BITS + `MMU_PGSHIFT)
`define PAGE_PRESENT      0
`define PAGE_READ         1
`define PAGE_WRITE        2
`define PAGE_EXEC         3
`define PAGE_USER         4
`define PAGE_GLOBAL       5
`define PAGE_ACCESSED     6
`define PAGE_DIRTY        7
`define PAGE_SOFT         9:8
`define PAGE_FLAGS        10'h3FF
`define PAGE_PFN_SHIFT    10
`define PAGE_SIZE         4096

/* Exception Constants */
// Direct from other repo
`define EXCEPTION_W                        6
`define EXCEPTION_MISALIGNED_FETCH         6'h10
`define EXCEPTION_FAULT_FETCH              6'h11
`define EXCEPTION_ILLEGAL_INSTRUCTION      6'h12
`define EXCEPTION_BREAKPOINT               6'h13
`define EXCEPTION_MISALIGNED_LOAD          6'h14
`define EXCEPTION_FAULT_LOAD               6'h15
`define EXCEPTION_MISALIGNED_STORE         6'h16
`define EXCEPTION_FAULT_STORE              6'h17
`define EXCEPTION_ECALL                    6'h18
`define EXCEPTION_ECALL_U                  6'h18
`define EXCEPTION_ECALL_S                  6'h19
`define EXCEPTION_ECALL_H                  6'h1a
`define EXCEPTION_ECALL_M                  6'h1b
`define EXCEPTION_PAGE_FAULT_INST          6'h1c
`define EXCEPTION_PAGE_FAULT_LOAD          6'h1d
`define EXCEPTION_PAGE_FAULT_STORE         6'h1f
`define EXCEPTION_EXCEPTION                6'h10
`define EXCEPTION_INTERRUPT                6'h20
`define EXCEPTION_ERET_U                   6'h30
`define EXCEPTION_ERET_S                   6'h31
`define EXCEPTION_ERET_H                   6'h32
`define EXCEPTION_ERET_M                   6'h33
`define EXCEPTION_FENCE                    6'h34
`define EXCEPTION_TYPE_MASK                6'h30
`define EXCEPTION_SUBTYPE_R                3:0
`define MCAUSE_INT                      31
`define MCAUSE_MISALIGNED_FETCH         ((0 << `MCAUSE_INT) | 0)
`define MCAUSE_FAULT_FETCH              ((0 << `MCAUSE_INT) | 1)
`define MCAUSE_ILLEGAL_INSTRUCTION      ((0 << `MCAUSE_INT) | 2)
`define MCAUSE_BREAKPOINT               ((0 << `MCAUSE_INT) | 3)
`define MCAUSE_MISALIGNED_LOAD          ((0 << `MCAUSE_INT) | 4)
`define MCAUSE_FAULT_LOAD               ((0 << `MCAUSE_INT) | 5)
`define MCAUSE_MISALIGNED_STORE         ((0 << `MCAUSE_INT) | 6)
`define MCAUSE_FAULT_STORE              ((0 << `MCAUSE_INT) | 7)
`define MCAUSE_ECALL_U                  ((0 << `MCAUSE_INT) | 8)
`define MCAUSE_ECALL_S                  ((0 << `MCAUSE_INT) | 9)
`define MCAUSE_ECALL_H                  ((0 << `MCAUSE_INT) | 10)
`define MCAUSE_ECALL_M                  ((0 << `MCAUSE_INT) | 11)
`define MCAUSE_PAGE_FAULT_INST          ((0 << `MCAUSE_INT) | 12)
`define MCAUSE_PAGE_FAULT_LOAD          ((0 << `MCAUSE_INT) | 13)
`define MCAUSE_PAGE_FAULT_STORE         ((0 << `MCAUSE_INT) | 15)
`define MCAUSE_INTERRUPT                (1 << `MCAUSE_INT)


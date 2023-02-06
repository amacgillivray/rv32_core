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
`define MASK_RTYPE = 32'hfe00707f

// Mask all but Funct3 and Opcode fields
`define MASK_ITYPE = 32'h707f


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
 */
// LUI rd,imm          | Load Upper Immediate
`define I_LUI 32'h37

// AUIPC rd,offset     | Add Upper Immediate to PC
`define I_AUPC 32'h17

// JAL rd,offset       | Jump and Link 
`define I_JAL 32'h6f

// JALR rd,rs1,offset  | Jump and Link Register 
`define I_JALR 32'h67

// BEQ rs1,rs2,offset  | Branch Equal 
`define I_BEQ 32'h63

// BNE rs1,rs2,offset  | Branch Not Equal
`define I_BNE 32'h1063 

// BLT rs1,rs2,offset  | Branch Less Than
`define I_BLT 32'h4063

// BGE rs1,rs2,offset  | Branch Greater Than Equal
`define I_BGE 32'h5063

// BLTU rs1,rs2,offset | Branch Less Than Unsigned 
`define I_BLTU 32'h6063

// BGEU rs1,rs2,offset | Branch Greater Than Equal Unsigned 
`define I_BGEU 32'h7063

// LB rd,offset(rs1)   | Load Byte -
`define I_LB 32'h3

// LH rd,offset(rs1)   | Load Half
`define I_LH 32'h1003

// LW rd,offset(rs1)   | Load Word
`define I_LW 32'h2003

// LBU rd,offset(rs1)  | Load Byte Unsigned 
`define I_LBU 32'h4003

// LHU rd,offset(rs1)  | Load Half Unsigned
`define I_LHU 32'h5003

// SB rs2,offset(rs1)  | Store Byte
`define I_SB 32'h23

// SH rs2,offset(rs1)  | Store Half 
`define I_SH 32'1023

// SW rs2,offset(rs1)  | Store Word
`define I_SW 32'h2023

// ADDI rd,rs1,imm     | Add Immediate
`define I_ADDI 32'h7013

// SLTI rd,rs1,imm     | Set Less Than Immediate
`define I_SLTI 32'h2013

// SLTIU rd,rs1,imm    | Set Less Than Immediate Unsigned
`define I_SLTIU 32'h3013

// XORI rd,rs1,imm     | XOR immediate
`define I_XORI 32'h4013

// ORI rd,rs1,imm      | OR immediate
`define I_ORI 32'h6013

// ANDI rd,rs1,imm     | AND immediate
`define I_ANDI 32'h7013

// SLLI rd,rs1,imm     | Shift Left Logical Immediate 
`define I_SLLI 32'h1013

// SRLI rd,rs1,imm     | Shift Right Logical Immediate
`define I_SRLI 32'h5013

// SRAI rd,rs1,imm     | Shift Right Logical Immediate
`define I_SRAI 32'h40005013

// ADD rd,rs1,rs2      | Add
`define I_ADD 32'h33

// SUB rd,rs1,rs2      | Sub
`define I_SUB 32'h40000033

// SLL rd,rs1,rs2      | Shift Left Logical
`define I_SLL 32'h1033

// SRL  --- ?? todo 
`define I_SRL 32'h5033

// SRA rd,rs1,rs2      | Shift Right Arithmetic
`define I_SRA 32'h40005033

// OR rd,rs1,rs2       | OR 
`define I_OR 32'h6033

// AND rd,rs1,rs2      | AND 
`define I_AND 32'h7033

// FENCE pred,succ     | Fence 
`define I_FENCE 32'hf

// FENCE.I             | Fence Instruction
`define I_IFENCE 32'h100f

/* TODO - Atomics */
/* TODO - 
/* TODO - Vector Extension Instructions */

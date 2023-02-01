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

/* Instructions / Instruction masks 
   -
   For list, see https://mark.theis.site/riscv/
   https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
   https://people.eecs.berkeley.edu/~krste/papers/riscv-privileged-v1.9.pdf
   - 
   Naming convention: 
    "I__x" is the instruction x
    "IM_x" is the mask for instruction x
 */ 
// LUI rd,imm          | Load Upper Immediate

// AUIPC rd,offset     | Add Upper Immediate to PC

// JAL rd,offset       | Jump and Link 

// JALR rd,rs1,offset  | Jump and Link Register 

// BEQ rs1,rs2,offset  | Branch Equal 

// BNE rs1,rs2,offset  | Branch Not Equal 

// BLT rs1,rs2,offset  | Branch Less Than

// BGE rs1,rs2,offset  | Branch Greater Than Equal

// BLTU rs1,rs2,offset | Branch Less Than Unsigned 

// BGEU rs1,rs2,offset | Branch Greater Than Equal Unsigned 

// LB rd,offset(rs1)   | Load Byte -

// LH rd,offset(rs1)   | Load Half

// LW rd,offset(rs1)   | Load Word

// LBU rd,offset(rs1)  | Load Byte Unsigned 

// LHU rd,offset(rs1)  | Load Half Unsigned

// SB rs2,offset(rs1)  | Store Byte

// SH rs2,offset(rs1)  | Store Half 

// SW rs2,offset(rs1)  | Store Word

// ADDI rd,rs1,imm     | Add Immediate

// SLTI rd,rs1,imm     | Set Less Than Immediate

// SLTIU rd,rs1,imm    | Set Less Than Immediate Unsigned

// XORI rd,rs1,imm     | XOR immediate

// ORI rd,rs1,imm      | OR immediate

// ANDI rd,rs1,imm     | AND immediate

// SLLI rd,rs1,imm     | Shift Left Logical Immediate 

// SRLI rd,rs1,imm     | Shift Right Logical Immediate

// SRAI rd,rs1,imm     | Shift Right Logical Immediate

// ADD rd,rs1,rs2      | Add

// SUB rd,rs1,rs2      | Sub

// SLL rd,rs1,rs2      | Shift Left Logical

// SRA rd,rs1,rs2      | Shift Right Arithmetic

// OR rd,rs1,rs2       | OR 

// AND rd,rs1,rs2      | AND 

// FENCE pred,succ     | Fence 

// FENCE.I             | Fence Instruction

/* TODO - Atomics */
/* TODO - 
/* TODO - Vector Extension Instructions */

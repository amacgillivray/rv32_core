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

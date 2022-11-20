`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 11/20/2022 03:37:49 PM
// Design Name: Immediate Generator
// Module Name: imm_gen
// Project Name: Linear Algebra Accelerator
// Target Devices: 
// Description: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module imm_gen(
    input [31:0] instruction,
    output [31:0] generated_immediate
);
    reg[31:0] result;
    assign generated_immediate = result;
    // todo
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray 
// 
// Create Date: 10/29/2022 04:36:55 PM
// Design Name: 
// Module Name: latch_ifid
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Latch to separate Instruction Fetch and Instruction Decode 
// stages of the RISC-V 5-stage pipeline.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module latch_ifid(
    input clock,
    input [31:0] ReadInstruction,
    input [31:0] PC,
    output [31:0] Latched_ReadInstruction,
    output [31:0] Latched_PC
    );
    reg [31:0] ri_tmp; // read instruction
    reg [31:0] pc_tmp; // program counter
    assign Latched_ReadInstruction = ri_tmp; 
    assign Latched_PC = pc_tmp;
    always @(negedge clock) begin
        ri_tmp = ReadInstruction;
        pc_tmp = PC;
    end
endmodule

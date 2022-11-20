`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/29/2022 05:53:02 PM
// Design Name: 
// Module Name: latch_idex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module latch_idex(
    input clock,
    input [1:0] WB,
    input [4:0] M,
    input [6:0] EX,
    input [31:0] PC,
    input [31:0] Rd1,
    input [31:0] Rd2,
    input [31:0] Immediate,
    input [31:0] Instruction,
    output [1:0] idex_WB,
    output [1:0] idex_M,
    output [1:0] ALUOp,
    output [1:0] ALUSrc1,
    output [1:0] ALUSrc2,
    output [5:0] InstrSeg_1,
    output [19:15] InstrSeg_2,
    output [24:20] InstrSeg_3,
    output [11:7] InstrSeg_4
    );
    assign idex_WB = WB;
    assign idex_M = M[4];
    assign ALUOp = EX[1:0];
    assign ALUSrc1 = EX[3:2];
    assign ALUSrc2 = EX[5:4];
    assign InstrSeg_1 = {Instruction[30], Instruction[25], Instruction[14:12], Instruction[3]};
    assign InstrSeg_2 = Instruction[19:15];
    assign InstrSeg_3 = Instruction[24:20]; 
    assign InstrSeg_4 = Instruction[11:7];
    always @(negedge clock) begin 
    end
endmodule

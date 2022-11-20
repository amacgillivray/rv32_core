`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/30/2022 01:52:55 PM
// Design Name: 
// Module Name: latch_exmem
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


module latch_exmem(
    input clk,
    input[1:0] WB,
    input[1:0] M,
    input[31:0] ALU,
    input[31:0] tempAluOp2,
    input[4:0] InstrSeg4,
    output[1:0] exmem_RW,
    output[1:0] exmem_MR,
    output[1:0] exmem_W,
    output[31:0] addr,
    output[31:0] writeData,
    output[4:0] exmem_RegRD    
    );
    reg [1:0] temp_WB;
    reg [1:0] temp_M;
    reg [31:0] temp_ALU;
    reg [31:0] temp_Op2;
    reg [4:0] temp_Instr;
    assign exmem_RW = temp_WB;
    assign exmem_MR = temp_M;
    assign exmem_W = temp_M;
    assign addr = temp_ALU;
    assign writeData = temp_Op2;
    assign exmem_RegRD = temp_Instr;
    always @(negedge clk) begin
        temp_WB = WB;
        temp_M = M;
        temp_ALU = ALU;
        temp_Op2 = tempAluOp2;
        temp_Instr = InstrSeg4;
    end
endmodule

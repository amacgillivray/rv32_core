`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/30/2022 01:52:55 PM
// Design Name: 
// Module Name: latch_memwb
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


module latch_memwb(
    input clk,
    input[1:0] exmem_RW,
    input[31:0] readData,
    input[31:0] addr,
    input[4:0] exmem_RegRD,
    output[1:0] memwb_RegW,
    output[1:0] memToReg,
    output[31:0] memwb_MemData,
    output[31:0] memwb_ExData,
    output memwb_RegRd
    );
    reg [1:0] temp_RegW;
    reg [1:0] temp_toReg;
    reg [31:0] temp_RD;
    reg [31:0] temp_addr;
    reg [4:0] temp_RegRD;
    assign memwb_RegW = temp_RegW;
    assign memToReg = temp_toReg;
    assign memwb_ExData = temp_addr;
    assign memwb_MemData = temp_RD;
    assign memwb_RegRd = temp_RegRD;
    always @(negedge clk) begin
        temp_addr = addr;
        temp_RD = readData;
        temp_RegRD = exmem_RegRD;
        temp_RegW = exmem_RW;
        temp_toReg = exmem_RW;
    end
endmodule

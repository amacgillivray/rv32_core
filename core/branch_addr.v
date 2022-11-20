`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray 
// 
// Create Date: 10/29/2022 08:58:40 PM
// Design Name: 
// Module Name: branch_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Shifts the immediate value left by 1, then adds it with the 
//  program counter to get the branch address.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branch_addr(
    input [31:0] PC,
    input [31:0] Immediate,
    output [31:0] branch_address
    );
    reg[31:0] result;
    reg[31:0] imd_shft; // Holds the left-shifted (by 1) value of Immediate.
    assign imd_shift = Immediate << 1; 
    assign branch_address = result;
    always @(*)
    begin
        result = imd_shift + PC;
    end
endmodule

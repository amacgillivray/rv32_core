`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 09/26/2022 11:49:49 AM
// Design Name: ALU Prototype 1
// Module Name: alu
// Project Name: Linear Algebra Accelerator
// Target Devices: Arty Z7-20 (XC7Z020-1CLG400C)
// Description: 8-Bit ALU Prototype
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Prototype / experiment to familiarize with Verilog. Will be replaced with a 
// larger version (32- or 64-bit) 
// Resources: 
// http://web.mit.edu/6.111/volume2/www/f2018/run_verilog.html
// http://web.mit.edu/6.111/volume2/www/f2018/
//////////////////////////////////////////////////////////////////////////////////
module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] sel,
    output [31:0] out,
    output carry
);
    reg[31:0] result;
    wire[32:0] tmp;
    assign out = result;
    assign tmp = {1'b0,A} + {1'b0,B};
    assign carry = tmp[32];
    always @(*)
    begin
        case(sel)
            4'b0000: // Add
                result = A + B;
            4'b0001: // Subtract
                result = A - B;
            4'b0010: // Multiply
                result = A * B;
            4'b0011: // Divide
                result = A / B;
            4'b0100: // Shift Left
                result = A << 1;
            4'b0101: // Shift Right
                result = A >> 1;
            4'b0110: // Rotate Left
                result = {A[30:0],A[31]};
            4'b0111: // Rotate Right
                result = {A[0],A[31:1]}; 
            4'b1000: // Logial AND 
                result = A & B;
            4'b1001: // Logical OR
                result = A | B;
            4'b1010: // Logical XOR
                result = A ^ B;
            4'b1011: // Logical NOR
                result = ~(A | B);
            4'b1100: // Logical NAND
                result = ~(A & B);
            4'b1101: // Logical XNOR
                result = ~(A ^ B);
            4'b1110: // Greater than
                result = (A>B) ? 32'd1 : 32'd0;
            4'b1111: // Equal 
                result = (A==B) ? 32'd1 : 32'd0;
            endcase
        end
endmodule

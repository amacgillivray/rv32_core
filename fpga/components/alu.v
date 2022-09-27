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
    input [7:0] A,
    input [7:0] B,
    input [3:0] sel,
    output [7:0] out,
    output carry
);
    reg[7:0] result;
    wire[8:0] tmp;
    assign out = result;
    assign tmp = {1'b0,A} + {1'b0,B};
    assign carry = tmp[8];
    always @(*)
    begin
        case(sel)
            4'b0000:
                result = A + B;
            4'b0001: 
                result = A - B;
            4'b0010:
                result = A * B;
            4'b0011: 
                result = A / B;
            4'b0100: 
                result = A << 1;
            4'b0101:
                result = A >> 1;
            4'b0110: 
                result = {A[6:0],A[7]};
            4'b0111: 
                result = {A[0],A[7:1]}; 
            4'b1000:
                result = A & B;
            4'b1001:
                result = A | B;
            4'b1010: 
                result = A ^ B;
            4'b1011:
                result = ~(A | B);
            4'b1100:
                result = ~(A & B);
            4'b1101:
                result = ~(A ^ B);
            4'b1110:
                result = ~(A>B)?8'd1:8'd0;
            4'b1111:
                result = ~(A==B)?'d1:8'd0;
            endcase
        end
endmodule

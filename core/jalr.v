`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/29/2022 08:46:45 PM
// Design Name: 
// Module Name: jalr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Adds the immediate and Read Data 1 values to generate JALR.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module jalr(
    input [31:0] Immediate,
    input [31:0] Rd1, // read data 1
    output [31:0] jalr
    );
    reg[31:0] result;
    reg[31:0] imd_shft; // Holds the left-shifted (by 1) value of Immediate.
    assign imd_shift = Immediate << 1; 
    assign jalr = result;
    always @(*)
    begin
        result = imd_shift + Rd1;
    end
endmodule

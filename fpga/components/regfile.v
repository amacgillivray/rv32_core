`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/02/2022 01:04:49 PM
// Design Name: Register File
// Module Name: regfile
// Project Name: Linear Algebra Accelerator
// Target Devices: Arty Z7-20 (XC7Z020-1CLG400C)
// Description: Describes a 32x32 register file
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Experimental; Untested
//////////////////////////////////////////////////////////////////////////////////

module regfile(
    input clock,
    input reset,
    input write,
    input [5:0] read_reg_1,
    input [5:0] read_reg_2, 
    input [5:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data_1,
    output [31:0] read_data_2
);
    integer i;
    reg [31:0] regfile [31:0];
    assign read_data_1 = regfile[read_reg_1];
    assign read_data_2 = regfile[read_reg_2];
    always @(posedge clock) begin
        if (!reset) begin
            if (write) regfile[write_reg] <= write_data;
        end else begin
            for (i = 0; i < 31; i = i + 1) begin
                regfile[i] <= 0;
            end
        end
    end
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2022 01:13:06 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input [14:12] instr_hi,
    input [6:0] instr_lo,
    output execption,
    output jump,
    output if_flush,
    output id_flush,
    output ex_flush,
    output [1:0] ctl_wb,
    output [4:0] ctl_m,
    output [5:0] ctl_ex,
    output is_branch,
    input is_jalr
    );
endmodule

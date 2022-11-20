`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/29/2022 01:28:37 PM
// Design Name: 
// Module Name: branch_comparator
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


module branch_comparator(
    output BranchCmp,
    input IsBranch,
    input [14:12] IFID_Funct3,
    input Ctrl_Mux_1_Branch,
    input Ctrl_Mux_2_Branch,
    input Read_Data_1,
    input Read_Data_2,
    input EXMEM_Alu_Data,
    input MEMWB_Mem_Data
    );
endmodule

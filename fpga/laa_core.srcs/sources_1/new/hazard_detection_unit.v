`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2022 12:33:04 PM
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazard_detection_unit(
    output StallL,
    output StallR,
    input IFID_Reg_RS1,
    input IFID_Reg_RS2,
    input IDEX_Reg_RD,
    input EXMEM_Reg_RD,
    output IDEX_MemRead,
    output EXMEM_MemRead
    );
//    wire tmp;
//    assign tmp = 0;
//    assign StallL = tmp;
//    assign StallR = tmp;
//    assign IDEX_MemRead = tmp;
//    assign EXMEM_MemRead = tmp;
//    always @(*)
//    begin
//        // todo 
//    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/17/2022 12:55:05 PM
// Design Name: PC Source
// Module Name: pcsrc
// Project Name: Linear Algebra Accelerator
// Target Devices: Zedboard
// Tool Versions: 
// Description: Generate the PCSRC control signal for the IF MUX using the 
//  branch comparison (bcmp) and jump inputs.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pcsrc(
    input bcmp,
    input jump,
    output pcsrc
    );
    assign pcsrc = bcmp && jump;
endmodule

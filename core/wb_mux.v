`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/29/2022 01:52:39 PM
// Design Name: 
// Module Name: wb_mux
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


module wb_mux(
    input memToReg,
    input[31:0] exData,
    input[31:0] memData,
    output[31:0] result
    );
    reg[31:0] res;
    wire[1:0] sel;
    assign result = res;
    assign sel = {memToReg};
    always @(*)
    begin
        case (sel)
            2'b00: 
                res = exData;
            2'b01: 
                res = memData;
        endcase
    end
endmodule

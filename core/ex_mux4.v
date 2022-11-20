`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/29/2022 06:34:29 PM
// Design Name: 
// Module Name: ex_mux4
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


module ex_mux4(
    input[1:0] ctrl,
    input[31:0] id_exReadData2,
    input[31:0] wbData,
    input[31:0] ex_memData,
    output[31:0] tempAluOp2
    );
    reg[31:0] result;
    wire[1:0] sel;
    assign tempAluOp2 = result;
    assign sel = {ctrl};
    always @(*)
    begin
        case (sel)
            2'b00: 
                result = id_exReadData2;
            2'b01: 
                result = wbData;
            2'b10:
                result = ex_memData;
        endcase
    end
endmodule

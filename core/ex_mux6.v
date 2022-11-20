`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/29/2022 06:34:29 PM
// Design Name: 
// Module Name: ex_mux6
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


module ex_mux6(
    input[1:0] aluSrc2,
    input[31:0] tempAluOp2,
    input[31:0] id_ex_imm,
    output[31:0] aluSrc2
    );
    reg[31:0] result;
    wire[1:0] sel;
    assign aluOp1 = result;
    assign sel = {aluSrc2};
    always @(*)
    begin
        case (sel)
            2'b00: 
                result = tempAluOp2;
            2'b01: 
                result = id_ex_imm;
            2'b10:
                result = 4;
        endcase
    end
endmodule

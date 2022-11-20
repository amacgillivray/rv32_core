`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/29/2022 06:34:29 PM
// Design Name: 
// Module Name: ex_mux5
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


module ex_mux5(
    input[1:0] aluSrc1,
    input[31:0] tempAluOp1,
    input[31:0] id_ex_pc,
    output[31:0] aluOp1
    );
    reg[31:0] result;
    wire[1:0] sel;
    assign aluOp1 = result;
    assign sel = {aluSrc1};
    always @(*)
    begin
        case (sel)
            2'b00: 
                result = tempAluOp1;
            2'b01: 
                result = id_ex_pc;
            2'b10:
                result = 0;
        endcase
    end
endmodule

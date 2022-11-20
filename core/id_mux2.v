`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/28/2022 06:33:59 PM
// Design Name: 
// Module Name: id_mux2
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


module id_mux2(
    input is_jalr,
    input[31:0] branch,
    input[31:0] jalr,
    output[31:0] jump_target
    );
    reg[31:0] result;
    wire[1:0] sel;
    assign jump_target = result;
    assign sel = {is_jalr};
    always @(*)
    begin
        case (sel)
            2'b00: 
                result = branch;
            2'b01: 
                result = jalr;
        endcase
    end
endmodule

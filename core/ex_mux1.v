`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineers: Daniel Ginsberg, Andrew MacGillivray 
// 
// Create Date: 10/29/2022 08:08:00 PM
// Design Name: 
// Module Name: ex_mux1
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

module ex_mux1(
    input ex_flush,
    input id_ex_wb,
    output ex_mem_wb
    );
    reg[1:0] zeros;
    reg result;
    wire sel;
    assign sel = ex_flush;
    assign ex_mem_wb  = result;
    always @(*)
    begin
        case(sel)
            1'b0:
                result = zeros[0];
            1'b1:
                result = id_ex_wb;
        endcase
    end
endmodule
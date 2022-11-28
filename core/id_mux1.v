`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineers: Jarrod Grothusen, Andrew MacGillivray
// 
// Create Date: 10/28/2022 06:20:18 PM
// Design Name: 
// Module Name: id_mux
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

module id_mux1(
    input stall,
    input id_flush,
    input[1:0] cntrl_wb,
    input [4:0] cntrl_m,
    input [5:0] cntrl_ex,
    output [1:0] idex_wb,
    output [4:0] idex_m,
    output [5:0] idex_ex
    );
    wire control;
    always @(*)
    begin
        if(stall || id_flush)
            control = 1;
        else
            control = 0;        

        case (control)
            1'b0: // is not JALR
                idex_wb = cntrl_wb;
                idex_m = cntrl_m;
                idex_ex = cntrl_ex;
            1'b1: // is JALR 
                idex_wb = 00;
                idex_m = 00000;
                idex_ex = 000000;
        endcase
    end
endmodule
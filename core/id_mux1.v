`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
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
    input IsJalr,
    input[31:0] branch_address,
    input [31:0] jalr_address,
    output [31:0] jump_target
    );
    reg [31:0] result;
    assign jump_target = result;
    always @(*)
    begin
        case (IsJalr)
            1'b0: // is not JALR
                result = branch_address;
            1'b1: // is JALR 
                result = jalr_address;
        endcase
    end
endmodule
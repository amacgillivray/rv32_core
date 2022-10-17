`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/17/2022 12:27:36 PM
// Design Name: Instruction Fetch Multiplexer
// Module Name: if_mux
// Project Name: Linear Algebra Accelerator
// Target Devices: Zedboard 
// Description: Updates the Program Counter based on one of three signals.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module if_mux(
    input pcsrc,
    input exception,
    input [31:0] jaddr,
    input [31:0] eaddr,
    input [31:0] oldpc,
    output [31:0] newpc
    );
    reg[31:0] result;
    wire[1:0] sel;
    assign newpc = result;
    assign sel = {pcsrc,exception};
    always @(*)
    begin
        case (sel)
            2'b00: // next instruction
                result = oldpc+4;
            2'b01: // exception address
                result = eaddr; 
            2'b10: // jump address
                result = jaddr;
        endcase
    end
endmodule

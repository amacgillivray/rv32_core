`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Jarrod Grothusen
// 
// Create Date: 10/29/2022 02:06:50 PM
// Design Name: 
// Module Name: data_memory
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


module data_memory(
    input wire memR,
    input wire memW,
    input wire clk,
    input wire [31:0] addr,       //memory address
    input wire [31:0] writeData,  //memory address contents
    output reg [31:0] readData   //outputs memory address contents
    );
    reg [31:0] MEMO [0:255];
    integer i;
    
    initial begin
        readData <= 0;
        for (i = 0; i < 256; i = i + 1) begin
            MEMO[i] = i;
        end 
    end
    always @(posedge  clk) begin
        if (memW == 1'b1) begin
            MEMO[addr] <= writeData;
        end
        if(memR == 1'b1) begin
            readData <= MEMO[addr];
        end
    end
endmodule

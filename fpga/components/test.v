`timescale 1ns / 1ps  
// test the adder at https://www.jdoodle.com/execute-Verilog-online
module jdoodle;
 reg[7:0] A;
 reg[7:0] B;
 reg[3:0] sel;
 wire[7:0] out;
 wire carry;
 integer i;
    alu test_unit(
            A,
            B,
            sel,
            out,
            carry
    );
    initial begin
      A = 8'b11010101;
      B = 8'b00001010;
      sel = 4'b0000;

      // Loop through all possible operations of the ALU
      for (i=0;i<=15;i=i+1)
      begin
        // Show the current state of the inputs
        $display("Program Inputs:");
        $display("\tA: %d\n\tB: %d\n\tSel: %b", A, B, sel);
        // Fire the circuit
        #10;
        // Show the Resulting Ouputs
        $display("Program Output:");
        $display ("\tValue: %d\n\tCarry: %b\n", out, carry);
        // Increment selector bits by 1 to go to the next
        // type of operation
        sel = sel + 8'h01;
      end;
      $finish;
    end
endmodule

module alu(
    input [7:0] A,
    input [7:0] B,
    input [3:0] sel,
    output [7:0] out,
    output carry
    );
    reg[7:0] result;
    wire[8:0] tmp;
    assign out = result;
    assign tmp = {1'b0,A} + {1'b0,B};
    assign carry = tmp[8];
    always @(*)
    begin
        case(sel)
            4'b0000:
                result = A + B;
            4'b0001: 
                result = A - B;
            4'b0010:
                result = A * B;
            4'b0011: 
                result = A / B;
            4'b0100: 
                result = A << 1;
            4'b0101:
                result = A >> 1;
            4'b0110: 
                result = {A[6:0],A[7]};
            4'b0111: 
                result = {A[0],A[7:1]}; 
            4'b1000:
                result = A & B;
            4'b1001:
                result = A | B;
            4'b1010: 
                result = A ^ B;
            4'b1011:
                result = ~(A | B);
            4'b1100:
                result = ~(A & B);
            4'b1101:
                result = ~(A ^ B);
            4'b1110:
                result = ~(A>B)?8'd1:8'd0;
            4'b1111:
                result = ~(A==B)?'d1:8'd0;
            endcase
        end
endmodule

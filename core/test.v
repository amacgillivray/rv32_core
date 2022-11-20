`timescale 1ns / 1ps  
`include "alu.v"
// test the alu at https://www.jdoodle.com/execute-Verilog-online
// copy and paste the contents of alu.v below the jdoodle module

module alutest;
 reg[31:0] A;
 reg[31:0] B;
 reg[3:0] sel;
 wire[31:0] out;
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
      A = 32'hEF2598;
      B = 32'hABC999;
      sel = 4'b0000;

      // Loop through all possible operations of the ALU
      for (i=0;i<=15;i=i+1)
      begin
        // Show the current state of the inputs
        $display("Program Inputs:");
        $display("\tA: %d\n\tB: %d\n\tSel: %b", A, B, sel);
        
        // Indicate what operation is being performed
        case (sel)
            4'b0000: // Add
                $display("Operation: +");
            4'b0001: // Subtract
                $display("Operation: -");
            4'b0010: // Multiply
                $display("Operation: *");
            4'b0011: // Divide
                $display("Operation: /");
            4'b0100: // Shift Left
                $display("Operation: <<");
            4'b0101: // Shift Right
                $display("Operation: >>");
            4'b0110: // Rotate Left
                $display("Operation: RoL");
            4'b0111: // Rotate Right
                $display("Operation: RoR"); 
            4'b1000: // Logial AND 
                $display("Operation: &");
            4'b1001: // Logical OR
                $display("Operation: |");
            4'b1010: // Logical XOR
                $display("Operation: ^");
            4'b1011: // Logical NOR
                $display("Operation: ~|");
            4'b1100: // Logical NAND
                $display("Operation: ~&");
            4'b1101: // Logical XNOR
                $display("Operation: ~^");
            4'b1110: // Greater than
                $display("Operation: > ?");
            4'b1111: // Equal 
                $display("Operation: == ?");
        endcase
        // Fire the circuit
        #10;
        // Show the Resulting Ouputs
        $display("Program Output:");
        $display ("\tValue: %d\n\tCarry: %b\n", out, carry);
        // Increment selector bits by 1 to go to the next
        // type of operation
        sel = sel + 4'h1;
      end;
      $finish;
    end
endmodule


module laa_alu 
(
     input  [3:0]  alu_i_op
    ,input  [31:0] alu_i_a
    ,input  [31:0] alu_i_b,
    ,output [31:0] alu_o
); 

`include "defs.v"

/* Operation Result */
reg  [31:0]  r;

/* Shift right */
reg  [31:16] srf;
reg  [31:0]  sr1;
reg  [31:0]  sr2;
reg  [31:0]  sr4;
reg  [31:0]  sr8;

/* Shift left */
reg  [31:0]  sl1;
reg  [31:0]  sl2;
reg  [31:0]  sl4;
reg  [31:0]  sl8;

/* Subtraction result */
wire [32:0]  s = alu_i_a - alu_i_b;

/* Whenever the operation, either input, or subtraction result changes */
always @ (alu_i_op or alu_i_a or alu_i_b or s)
begin 
    /* initialize shift registers */
    srf = 16'b0;
    sr1 = 32'b0;
    sr2 = 32'b0;
    sr4 = 32'b0;
    sr8 = 32'b0;
    sl1 = 32'b0;
    sl2 = 32'b0;
    sl4 = 32'b0;
    sl8 = 32'b0;

    case (alu_i_op)
    /* Addition / Subtraction */
        `ALU_ADD :
        begin 
            r = (alu_i_a + alu_i_b);
        end
        `ALU_SUBTRACT : 
        begin
            r = s;
        end
    /* Comparisons */
        `ALU_LESS_THAN : 
        begin 
            r = (alu_i_a < alu_i_b) ? 32'h1 : 32'h0;
        end
        `ALU_SIGNED_LESS_THAN : 
        begin
            if (alu_i_a[31] != alu_i_b[31])
                r = alu_i_a[31] ? 32'h1 : 32'h0;
            else
                r = s[31] ? 32'h1 : 32'h0;
        end
    /* Logical Operations */
        `ALU_AND : 
        begin
            r = (alu_i_a & alu_i_b);
        end
        `ALU_OR : 
        begin
            r = (alu_i_a | alu_i_b);
        end
        `ALU_XOR : 
        begin
            r = (alu_i_a ^ alu_i_b);
        end
    /* Shift Operations */
        `ALU_SHIFT_LEFT : 
        begin
            if (alu_i_b[0] == 1'b1)
                sl1 = {alu_i_a[30:0], 1'b0};
            else
                sl1 = alu_i_a;

            if (alu_i_b[1] == 1'b1)
                sl2 = {sl1[29:0], 2'b00};
            else
                sl2 = sl1;
            
            if (alu_i_b[2] == 1'b1)
                sl4 = {sl2[27:0], 4'b0000};
            else
                sl4 = sl2;
            
            if (alu_i_b[3] == 1'b1)
                sl8 = {sl4[23:0], 8'b00000000}
            else 
                sl8 = sl4;

            if (alu_i_b[4] == 1'b1)
                r = {sl8[15:0], 16'b0000000000000000};
            else
                r = sl8;
        end
        `ALU_SHIFT_RIGHT, `ALU_SHIFT_RIGHT_ARITHMETIC
        begin
            if (alu_i_op = `ALU_SHIFT_RIGHT_ARITHMETIC && alu_i_a[31] == 1'b1)
                srf = 16'b1111111111111111;
            else
                srf = 16'b0000000000000000;

                if (alu_i_b[0] == 1'b1)
                    sr1 = {srf[31], alu_i_a[31:1]};
                else
                    sr1 = alu_i_a;
                
                if (alu_i_b[1] == 1'b1)
                    sr2 = {srf[31:30], sr1[31:2]};
                else
                    sr2 = sr1;
                
                if (alu_i_b[2] == 1'b1)
                    sr4 = {srf[31:28], sr2[31:4]};
                else
                    sr4 = sr2;
            
                if (alu_i_b[3] == 1'b1)
                    sr8 = {srf[31:24], sr4[31:8]}; 
                else 
                    sr8 = sr4;

                if (alu_i_b[4] == 1'b1)
                    r = {srf[31:16], sr8[31:16]}; 
                else 
                    r = sr8;
        end
    /* DEFAULT */
    default :
    begin
        r = alu_i_a;
    end
    endcase
end

assign alu_o = r;
endmodule

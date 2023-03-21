//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andrew MacGillivray, Jarrod Grothusen
// 
// Create Date: 
// Design Name: 
// Module Name: ex_ALU_cntrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Checks uses alu_op to decide 
//////////////////////////////////////////////////////////////////////////////////


module ex_alu_cntrl
(
     input clk
    ,input rst
    ,input  [31:0] alu_op // the whole instruction
    ,output [4:0] alu_control
);

`include "defs.v"

reg [3:0] alu_signal;

always @ *
begin
    alu_signal = `ALU_NOOP;
    
    if((alu_op & `M_ADD) == `I_ADD) 
    begin
        alu_signal = `ALU_ADD;
    end
    
    else if((alu_op & `M_ADDI) == `I_ADDI) 
    begin
        alu_signal = `ALU_ADD;
    end 
    
    else if((alu_op & `M_SUB) == `I_SUB) 
    begin
        alu_signal = `ALU_SUBTRACT;
    end 
    
    else if((alu_op & `M_AND) == `I_AND)
    begin
        alu_signal = `ALU_AND;
    end  
    
    else if((alu_op & `M_ANDI) == `I_ANDI)
    begin
        alu_signal = `ALU_AND;
    end  
    
    else if((alu_op & `M_OR) == `I_OR)
    begin
        alu_signal = `ALU_OR;
    end  
    
    else if((alu_op & `M_ORI) == `I_ORI)
    begin
        alu_signal = `ALU_OR;
    end 
    
    else if((alu_op & `M_SLL) == `I_SLL)
    begin
        alu_signal = `ALU_SHIFT_LEFT;
    end 
    
    else if((alu_op & `M_SLLI) == `I_SLLI)
    begin
        alu_signal = `ALU_SHIFT_LEFT;
    end  
    
    else if((alu_op & `M_SRA) == `I_SRA)
    begin
        alu_signal = `ALU_SHIFT_RIGHT_ARITHMETIC;
    end  
    
    else if((alu_op & `M_SRAI) == `I_SRAI) 
    begin
        alu_signal = `ALU_SHIFT_RIGHT_ARITHMETIC;
    end 
    
    else if((alu_op & `M_SRL) == `I_SRL)
    begin
        alu_signal = `ALU_SHIFT_RIGHT;
    end  
    
    else if((alu_op & `M_SRLI) == `I_SRLI)
    begin
        alu_signal = `ALU_SHIFT_RIGHT;
    end  
    
    else if((alu_op & `M_XOR) == `I_XOR)
    begin
        alu_signal = `ALU_XOR;
    end 
    
    else if((alu_op & `M_XORI) == `I_XORI)
    begin
        alu_signal = `ALU_XOR;
    end  
    
    else if((alu_op & `M_SLT) == `I_SLT)
    begin
        alu_signal = `ALU_SIGNED_LESS_THAN;
    end 
    
    else if((alu_op & `M_SLTI) == `I_SLTI)
    begin
        alu_signal = `ALU_SIGNED_LESS_THAN;
    end  
    
    else if((alu_op & `M_SLTU) == `I_SLTU)
    begin
        alu_signal = `ALU_LESS_THAN;
    end 
    
    else if((alu_op & `M_SLTIU) == `I_SLTIU)
    begin
        alu_signal = `ALU_LESS_THAN;
    end  
    
    else if((alu_op & `M_LUI) == `I_LUI)
    begin
        // nothing to do
    end 
    
    else if((alu_op & `M_AUIPC) == `I_AUIPC)
    begin
        alu_signal = `ALU_ADD;
    end 
    
    else if(((alu_op & `M_JAL) == `I_JAL) || ((alu_op & `M_JALR) == `I_JALR))
    begin
        alu_signal = `ALU_ADD;
    end 
end
assign alu_control = alu_signal;
endmodule

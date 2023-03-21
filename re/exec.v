//-----------------------------------------------------------------
//                         RISC-V Core
//                            V1.0.1
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
//
//                   admin@ultra-embedded.com
//
//                       License: BSD
//-----------------------------------------------------------------
//
// Copyright (c) 2014-2019, Ultra-Embedded.com
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions 
// are met:
//   - Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   - Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer 
//     in the documentation and/or other materials provided with the 
//     distribution.
//   - Neither the name of the author nor the names of its contributors 
//     may be used to endorse or promote products derived from this 
//     software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
// SUCH DAMAGE.
//-----------------------------------------------------------------

// Rewritten by Aditi Darade with heavy reference to the original code

module exec
(
    // Inputs 
     input           InClk
    ,input           InRst
    ,input           InOpcodeValid
    ,input  [ 31:0]  InOpcodeOpcode
    ,input  [ 31:0]  InOpcodePc
    ,input           InOpcodeInvalid
    ,input  [  4:0]  InOpcodeRdIdx
    ,input  [  4:0]  InOpcodeRaIdx
    ,input  [  4:0]  InOpcodeRbIdx
    ,input  [ 31:0]  InOpcodeRaOperand
    ,input  [ 31:0]  InOpcodeRbOperand
    ,input           InHold

    // Outputs
    ,output          OutBranchRequest
    ,output          OutBranchIsTaken
    ,output          OutBranchIsNotTaken
    ,output [ 31:0]  OutBranchSource
    ,output          OutBranchIsCall
    ,output          OutBranchIsRet
    ,output          OutBranchIsJmp
    ,output [ 31:0]  OutBranchPc
    ,output          OutBranchDRequest
    ,output [ 31:0]  OutBranchDPc
    ,output [  1:0]  OutBranchDPriv
    ,output [ 31:0]  OutWritebackValue
);

// Includes the following file
`include "defs.v"

// Arithmetic logic unit operations executions
reg [31:0]  Imm20R;
reg [31:0]  Imm12R;
reg [31:0]  BimmR;
reg [31:0]  Jimm20R;
reg [4:0]   ShamtR;

always @ *
begin
    Imm20R = {InOpcodeOpcode[31:12], 12'b0};
    Imm12R = {{20{InOpcodeOpcode[31]}}, InOpcodeOpcode[31:20]};
    BimmR = {{19{InOpcodeOpcode[31]}}, InOpcodeOpcode[31], InOpcodeOpcode[7], InOpcodeOpcode[30:25], InOpcodeOpcode[11:8], 1'b0};
    Jimm20R = {{12{InOpcodeOpcode[31]}}, InOpcodeOpcode[19:12], InOpcodeOpcode[20], InOpcodeOpcode[30:25], InOpcodeOpcode[24:21], 1'b0};
    ShamtR = InOpcodeOpcode[24:20];
end

reg [3:0]  AluFuncR;
reg [31:0] AluInputAR;
reg [31:0] AluInputBR;

always @ *
begin
    AluFuncR = `ALU_NOOP;
    AluInputAR = 32'b0;
    AluInputBR = 32'b0;

    // add mask
    if((InOpcodeOpcode & `M_ADD) == `I_ADD) 
    begin
        AluFuncR = `ALU_ADD;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // and mask
    else if((InOpcodeOpcode & `M_AND) == `I_AND) 
    begin
        AluFuncR = `ALU_AND;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // or mask
    else if((InOpcodeOpcode & `M_OR) == `I_OR) 
    begin
        AluFuncR = `ALU_OR;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // sll mask
    else if ((InOpcodeOpcode & `M_SLL) == `I_SLL) 
    begin
        AluFuncR = `ALU_SHIFT_LEFT;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // sra mask
    else if((InOpcodeOpcode & `M_SRA) == `I_SRA) 
    begin
        AluFuncR = `ALU_SHIFT_RIGHT_ARITHMETIC;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // srl mask
    else if((InOpcodeOpcode & `M_SRL) == `I_SRL) 
    begin
        AluFuncR = `ALU_SHIFT_RIGHT;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // sub mask
    else if((InOpcodeOpcode & `M_SUB) == `I_SUB) 
    begin
        AluFuncR = `ALU_SUBTRACT;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // xor mask
    else if((InOpcodeOpcode & `M_XOR) == `I_XOR) 
    begin
        AluFuncR = `ALU_XOR;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // slt mask
    else if((InOpcodeOpcode & `M_SLT) == `I_SLT) 
    begin
        AluFuncR = `ALU_SIGNED_LESS_THAN;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // sltu mask
    else if((InOpcodeOpcode & `M_SLTU) == `I_SLTU) 
    begin
        AluFuncR = `ALU_LESS_THAN;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = InOpcodeRbOperand;
    end

    // addi mask
    else if((InOpcodeOpcode & `M_ADDI) == `I_ADDI) 
    begin
        AluFuncR = `ALU_ADD;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // andi mask
    else if((InOpcodeOpcode & `M_ANDI) == `I_ANDI) 
    begin
        AluFuncR = `ALU_AND;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // slti mask
    else if((InOpcodeOpcode & `M_SLTI) == `I_SLTI) 
    begin
        AluFuncR = `ALU_SIGNED_LESS_THAN;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // sltiu mask
    else if((InOpcodeOpcode & `M_SLTIU) == `I_SLTIU) 
    begin
        AluFuncR = `ALU_LESS_THAN;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // ori mask
    else if((InOpcodeOpcode & `M_ORI) == `I_ORI) 
    begin
        AluFuncR = `ALU_OR;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // xori mask
    else if((InOpcodeOpcode & `M_XORI) == `I_XORI) 
    begin
        AluFuncR = `ALU_XOR;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = Imm12R;
    end

    // slli mask
    else if((InOpcodeOpcode & `M_SLLI) == `I_SLLI) 
    begin
        AluFuncR = `ALU_SHIFT_LEFT;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = {27'b0, ShamtR};
    end

    // srli mask
    else if((InOpcodeOpcode & `M_SRLI) == `I_SRLI) 
    begin
        AluFuncR = `ALU_SHIFT_RIGHT;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = {27'b0, ShamtR};
    end

    // srai mask
    else if((InOpcodeOpcode & `M_SRAI) == `I_SRAI) 
    begin
        AluFuncR = `ALU_SHIFT_RIGHT_ARITHMETIC;
        AluInputAR = InOpcodeRaOperand;
        AluInputBR = {27'b0, ShamtR};
    end

    // lui mask
    else if((InOpcodeOpcode & `M_LUI) == `I_LUI) 
    begin
        AluInputAR = Imm20R;
    end

    // auipc mask
    else if((InOpcodeOpcode & `M_AUIPC) == `I_AUIPC) 
    begin
        AluFuncR = `ALU_ADD;
        AluInputAR = InOpcodePc;
        AluInputBR = Imm20R;
    end

    // jal mask, jalr mask     
    else if(((InOpcodeOpcode & `M_JAL) == `I_JAL) || ((InOpcodeOpcode & `M_JALR) == `I_JALR)) 
    begin
        AluFuncR = `ALU_ADD;
        AluInputAR = InOpcodePc;
        AluInputBR = 32'd4;
    end
end

wire [31:0]  AluPW;
RiscvAlu
UAlu
(
    .alu_op_i(AluFuncR),
    .alu_a_i(AluInputAR),
    .alu_b_i(AluInputBR),
    .alu_p_o(AluPW)
);

//Flop Output
reg [31:0] ResultQ;
always @ (posedge InClk or posedge InRst)
if(InRst)
    ResultQ <= 32'b0;
else if(~InHold)
    ResultQ <= AluPW;
assign OutWritebackValue = ResultQ;


// x is the left operand and y is the right operand  
// It returns (int)x less than (int)y
//The LessThanSigned operator is signed
function [0:0] LessThanSigned;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if(x[31] != y[31])
        LessThanSigned = x[31];
    else
        LessThanSigned = v[31];
end
endfunction


// x is the left operand and y is the right operand  
// It returns (int)x greater than (int)y
//The GreaterThanSigned operator is signed
function [0:0] GreaterThanSigned;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if(x[31] != y[31])
        GreaterThanSigned = y[31];
    else
        GreaterThanSigned = v[31];
end
endfunction


//This executes the Branch operations
reg        BranchR;
reg        BranchTakenR;
reg [31:0] BranchTargetR;
reg        BranchCallR;
reg        BranchRetR;
reg        BranchJmpR;

always @ *
begin
    BranchR = 1'b0;
    BranchTakenR = 1'b0;
    BranchCallR = 1'b0;
    BranchRetR = 1'b0;
    BranchJmpR = 1'b0;
    BranchTargetR = InOpcodePc + BimmR;
    
    // jal mask
    if((InOpcodeOpcode & `M_JAL) == `I_JAL) 
    begin
        BranchR = 1'b1;
        BranchTakenR = 1'b1;
        BranchTargetR = InOpcodePc + Jimm20R;
        BranchCallR = (InOpcodeRdIdx == 5'd1); 
        BranchJmpR = 1'b1;
    end

    // jalr mask
    else if((InOpcodeOpcode & `M_JALR) == `I_JALR) 
    begin
        BranchR = 1'b1;
        BranchTakenR = 1'b1;
        BranchTargetR = InOpcodeRaOperand + Imm12R;
        BranchTargetR[0] = 1'b0;
        BranchRetR = (InOpcodeRaIdx == 5'd1 && Imm12R[11:0] == 12'b0); 
        BranchCallR = ~BranchRetR && (InOpcodeRdIdx == 5'd1); 
        BranchJmpR = ~(BranchCallR | BranchRetR);
    end

    // beq mask
    else if((InOpcodeOpcode & `M_BEQ) == `I_BEQ) 
    begin
        BranchR = 1'b1;
        BranchTakenR = (InOpcodeRaOperand == InOpcodeRbOperand);
    end

    // bne mask
    else if((InOpcodeOpcode & `M_BNE) == `I_BNE) 
    begin
        BranchR = 1'b1;    
        BranchTakenR = (InOpcodeRaOperand != InOpcodeRbOperand);
    end

    // blt mask
    else if((InOpcodeOpcode & `M_BLT) == `I_BLT) 
    begin
        BranchR = 1'b1;
        BranchTakenR = LessThanSigned(InOpcodeRaOperand, InOpcodeRbOperand);
    end

    // bge mask
    else if((InOpcodeOpcode & `M_BGE) == `I_BGE) 
    begin
        BranchR = 1'b1;    
        BranchTakenR = GreaterThanSigned(InOpcodeRaOperand,InOpcodeRbOperand) | (InOpcodeRaOperand == InOpcodeRbOperand);
    end

    // bltu mask
    else if((InOpcodeOpcode & `M_BLTU) == `I_BLTU) 
    begin
        BranchR = 1'b1;    
        BranchTakenR = (InOpcodeRaOperand < InOpcodeRbOperand);
    end

    // bgeu mask
    else if((InOpcodeOpcode & `M_BGEU) == `I_BGEU) 
    begin
        BranchR = 1'b1;
        BranchTakenR = (InOpcodeRaOperand >= InOpcodeRbOperand);
    end
end

reg        BranchTakenQ;
reg        BranchnTakenQ;
reg [31:0] PcXQ;
reg [31:0] PcMQ;
reg        BranchCallQ;
reg        BranchRetQ;
reg        BranchJmpQ;

always @ (posedge InClk or posedge InRst)
if(InRst)
begin
    BranchTakenQ <= 1'b0;
    BranchnTakenQ <= 1'b0;
    PcXQ <= 32'b0;
    PcMQ <= 32'b0;
    BranchCallQ <= 1'b0;
    BranchRetQ <= 1'b0;
    BranchJmpQ <= 1'b0;
end

else if(InOpcodeValid)
begin
    BranchTakenQ <= BranchR && InOpcodeValid & BranchTakenR;
    BranchnTakenQ <= BranchR && InOpcodeValid & ~BranchTakenR;
    PcXQ <= BranchTakenR ? BranchTargetR : InOpcodePc + 32'd4;
    BranchCallQ <= BranchR && InOpcodeValid && BranchCallR;
    BranchRetQ <= BranchR && InOpcodeValid && BranchRetR;
    BranchJmpQ <= BranchR && InOpcodeValid && BranchJmpR;
    PcMQ <= InOpcodePc;
end

assign OutBranchRequest = BranchTakenQ | BranchnTakenQ;
assign OutBranchIsTaken = BranchTakenQ;
assign OutBranchIsNotTaken = BranchnTakenQ;
assign OutBranchSource = PcMQ;
assign OutBranchPc = PcXQ;
assign OutBranchIsCall = BranchCallQ;
assign OutBranchIsRet = BranchRetQ;
assign OutBranchIsJmp = BranchJmpQ;
assign OutBranchDRequest = (BranchR && InOpcodeValid && BranchTakenR);
assign OutBranchDPc = BranchTargetR;
assign OutBranchDPriv = 2'b0; 

endmodule

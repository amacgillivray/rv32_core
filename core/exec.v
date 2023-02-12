//-----------------------------------------------------------------
// Company: EECS 581 Team 11
// Engineer: Aditi Darade
// 
// Create Date: 02/04/2023 7:51 PM
// Project Name: Linear Algebra Accelerator
// Additional Comments:
// Experimental
//-----------------------------------------------------------------
module riscv_exec
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
    ,output          OutBranchIsImp
    ,output [ 31:0]  OutBranchPc
    ,output          OutBranchDRequest
    ,output [ 31:0]  OutBranchDPc
    ,output [  1:0]  OutBranchDPriv
    ,output [ 31:0]  OutWritebackValue
);




// Includes

`include "defs.v"

reg [31:0]  Imm20R;
reg [31:0]  Imm12R;
reg [31:0]  BimmR;
reg [31:0]  Jimm20R;
reg [4:0]   ShamtR;

always @ *
begin
    Imm20R     = {InOpcodeOpcode[31:12], 12'b0};
    Imm12R     = {{20{InOpcodeOpcode[31]}}, InOpcodeOpcode[31:20]};
    BimmR      = {{19{InOpcodeOpcode[31]}}, InOpcodeOpcode[31], InOpcodeOpcode[7], InOpcodeOpcode[30:25], InOpcodeOpcode[11:8], 1'b0};
    Jimm20R    = {{12{InOpcodeOpcode[31]}}, InOpcodeOpcode[19:12], InOpcodeOpcode[20], InOpcodeOpcode[30:25], InOpcodeOpcode[24:21], 1'b0};
    ShamtR     = InOpcodeOpcode[24:20];
end


reg [3:0]  AluFuncR;
reg [31:0] AluInputAR;
reg [31:0] AluInputBR;

always @ *
begin
    AluFuncR     = `ALU_NONE;
    AluInputAR  = 32'b0;
    AluInputBR  = 32'b0;

    if ((InOpcodeOpcode & `INST_ADD_MASK) == `INST_ADD) // add
    begin
        AluFuncR     = `ALU_ADD;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_AND_MASK) == `INST_AND) // and
    begin
        AluFuncR     = `ALU_AND;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_OR_MASK) == `INST_OR) // or
    begin
        AluFuncR     = `ALU_OR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SLL_MASK) == `INST_SLL) // sll
    begin
        AluFuncR     = `ALU_SHIFTL;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SRA_MASK) == `INST_SRA) // sra
    begin
        AluFuncR     = `ALU_SHIFTR_ARITH;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SRL_MASK) == `INST_SRL) // srl
    begin
        AluFuncR     = `ALU_SHIFTR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SUB_MASK) == `INST_SUB) // sub
    begin
        AluFuncR     = `ALU_SUB;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_XOR_MASK) == `INST_XOR) // xor
    begin
        AluFuncR     = `ALU_XOR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SLT_MASK) == `INST_SLT) // slt
    begin
        AluFuncR     = `ALU_LessThanSigned;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_SLTU_MASK) == `INST_SLTU) // sltu
    begin
        AluFuncR     = `ALU_LESS_THAN;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = InOpcodeRbOperand;
    end
    else if ((InOpcodeOpcode & `INST_ADDI_MASK) == `INST_ADDI) // addi
    begin
        AluFuncR     = `ALU_ADD;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_ANDI_MASK) == `INST_ANDI) // andi
    begin
        AluFuncR     = `ALU_AND;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_SLTI_MASK) == `INST_SLTI) // slti
    begin
        AluFuncR     = `ALU_LessThanSigned;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_SLTIU_MASK) == `INST_SLTIU) // sltiu
    begin
        AluFuncR     = `ALU_LESS_THAN;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_ORI_MASK) == `INST_ORI) // ori
    begin
        AluFuncR     = `ALU_OR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_XORI_MASK) == `INST_XORI) // xori
    begin
        AluFuncR     = `ALU_XOR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = Imm12R;
    end
    else if ((InOpcodeOpcode & `INST_SLLI_MASK) == `INST_SLLI) // slli
    begin
        AluFuncR     = `ALU_SHIFTL;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = {27'b0, ShamtR};
    end
    else if ((InOpcodeOpcode & `INST_SRLI_MASK) == `INST_SRLI) // srli
    begin
        AluFuncR     = `ALU_SHIFTR;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = {27'b0, ShamtR};
    end
    else if ((InOpcodeOpcode & `INST_SRAI_MASK) == `INST_SRAI) // srai
    begin
        AluFuncR     = `ALU_SHIFTR_ARITH;
        AluInputAR  = InOpcodeRaOperand;
        AluInputBR  = {27'b0, ShamtR};
    end
    else if ((InOpcodeOpcode & `INST_LUI_MASK) == `INST_LUI) // lui
    begin
        AluInputAR  = Imm20R;
    end
    else if ((InOpcodeOpcode & `INST_AUIPC_MASK) == `INST_AUIPC) // auipc
    begin
        AluFuncR     = `ALU_ADD;
        AluInputAR  = InOpcodePc;
        AluInputBR  = Imm20R;
    end     
    else if (((InOpcodeOpcode & `INST_JAL_MASK) == `INST_JAL) || ((InOpcodeOpcode & `INST_JALR_MASK) == `INST_JALR)) // jal, jalr
    begin
        AluFuncR     = `ALU_ADD;
        AluInputAR  = InOpcodePc;
        AluInputBR  = 32'd4;
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


reg [31:0] ResultQ;
always @ (posedge InClk or posedge InRst)
if (InRst)
    ResultQ  <= 32'b0;
else if (~InHold)
    ResultQ <= AluPW;

assign OutWritebackValue  = ResultQ;


function [0:0] LessThanSigned;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if (x[31] != y[31])
        LessThanSigned = x[31];
    else
        LessThanSigned = v[31];
end
endfunction


function [0:0] GreaterThanSigned;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if (x[31] != y[31])
        GreaterThanSigned = y[31];
    else
        GreaterThanSigned = v[31];
end
endfunction


reg        BranchR;
reg        BranchTakenR;
reg [31:0] BranchTargetR;
reg        BranchCallR;
reg        BranchRetR;
reg        BranchJmpR;

always @ *
begin
    BranchR        = 1'b0;
    BranchTakenR  = 1'b0;
    BranchCallR   = 1'b0;
    BranchRetR    = 1'b0;
    BranchJmpR    = 1'b0;

    // Default BranchR target is relative to current PC
    BranchTargetR = InOpcodePc + BimmR;

    if ((InOpcodeOpcode & `INST_JAL_MASK) == `INST_JAL) // jal
    begin
        BranchR        = 1'b1;
        BranchTakenR  = 1'b1;
        BranchTargetR = InOpcodePc + Jimm20R;
        BranchCallR   = (InOpcodeRdIdx == 5'd1); // RA
        BranchJmpR    = 1'b1;
    end
    else if ((InOpcodeOpcode & `INST_JALR_MASK) == `INST_JALR) // jalr
    begin
        BranchR            = 1'b1;
        BranchTakenR      = 1'b1;
        BranchTargetR     = InOpcodeRaOperand + Imm12R;
        BranchTargetR[0]  = 1'b0;
        BranchRetR        = (InOpcodeRaIdx == 5'd1 && Imm12R[11:0] == 12'b0); // RA
        BranchCallR       = ~BranchRetR && (InOpcodeRdIdx == 5'd1); // RA
        BranchJmpR        = ~(BranchCallR | BranchRetR);
    end
    else if ((InOpcodeOpcode & `INST_BEQ_MASK) == `INST_BEQ) // beq
    begin
        BranchR      = 1'b1;
        BranchTakenR= (InOpcodeRaOperand == InOpcodeRbOperand);
    end
    else if ((InOpcodeOpcode & `INST_BNE_MASK) == `INST_BNE) // bne
    begin
        BranchR      = 1'b1;    
        BranchTakenR= (InOpcodeRaOperand != InOpcodeRbOperand);
    end
    else if ((InOpcodeOpcode & `INST_BLT_MASK) == `INST_BLT) // blt
    begin
        BranchR      = 1'b1;
        BranchTakenR= LessThanSigned(InOpcodeRaOperand, InOpcodeRbOperand);
    end
    else if ((InOpcodeOpcode & `INST_BGE_MASK) == `INST_BGE) // bge
    begin
        BranchR      = 1'b1;    
        BranchTakenR= GreaterThanSigned(InOpcodeRaOperand,InOpcodeRbOperand) | (InOpcodeRaOperand == InOpcodeRbOperand);
    end
    else if ((InOpcodeOpcode & `INST_BLTU_MASK) == `INST_BLTU) // bltu
    begin
        BranchR      = 1'b1;    
        BranchTakenR= (InOpcodeRaOperand < InOpcodeRbOperand);
    end
    else if ((InOpcodeOpcode & `INST_BGEU_MASK) == `INST_BGEU) // bgeu
    begin
        BranchR      = 1'b1;
        BranchTakenR= (InOpcodeRaOperand >= InOpcodeRbOperand);
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
if (InRst)
begin
    BranchTakenQ   <= 1'b0;
    BranchnTakenQ  <= 1'b0;
    PcXQ           <= 32'b0;
    PcMQ           <= 32'b0;
    BranchCallQ    <= 1'b0;
    BranchRetQ     <= 1'b0;
    BranchJmpQ     <= 1'b0;
end
else if (InOpcodeValid)
begin
    BranchTakenQ   <= BranchR && InOpcodeValid & BranchTakenR;
    BranchnTakenQ  <= BranchR && InOpcodeValid & ~BranchTakenR;
    PcXQ           <= BranchTakenR ? BranchTargetR : InOpcodePc + 32'd4;
    BranchCallQ    <= BranchR && InOpcodeValid && BranchCallR;
    BranchRetQ     <= BranchR && InOpcodeValid && BranchRetR;
    BranchJmpQ     <= BranchR && InOpcodeValid && BranchJmpR;
    PcMQ           <= InOpcodePc;
end

assign OutBranchRequest   = BranchTakenQ | BranchnTakenQ;
assign OutBranchIsTaken  = BranchTakenQ;
assign OutBranchIsNotTaken = BranchnTakenQ;
assign OutBranchSource    = PcMQ;
assign OutBranchPc        = PcXQ;
assign OutBranchIsCall   = BranchCallQ;
assign OutBranchIsRet    = BranchRetQ;
assign OutBranchIsImp    = BranchJmpQ;

assign OutBranchDRequest = (BranchR && InOpcodeValid && BranchTakenR);
assign OutBranchDPc      = BranchTargetR;
assign OutBranchDPriv    = 2'b0; // don't care



endmodule

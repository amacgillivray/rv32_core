//-----------------------------------------------------------------
// Company: EECS 581 Team 11
// Engineer: Aditi Darade
// 
// Create Date: 01/29/2023 12:04 PM
// Project Name: Linear Algebra Accelerator
// Additional Comments:
// Experimental
//-----------------------------------------------------------------

module riscv_decode
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_MULDIV   = 1
    ,parameter EXTRA_DECODE_STAGE = 0
)
----------------------------------------------------------------
(
    // Inputs
     input           InClk
    ,input           InRst
    ,input           InFetchInValid
    ,input  [ 31:0]  InFetchInInstr
    ,input  [ 31:0]  InFetchInPC
    ,input           InFetchInFaultFetch
    ,input           InFetchInFaultPage
    ,input           InFetchOutAccept
    ,input           InSquashDecode

    // Outputs
    ,output          OutFetchInAccept
    ,output          OutFetchOutValid
    ,output [ 31:0]  OutFetchOutInstr
    ,output [ 31:0]  OutFetchOutPc
    ,output          OutFetchOutFaultFetch
    ,output          OutFetchOutFaultPage
    ,output          OutFetchOutInstrExec
    ,output          OutFetchOutInstrLsu
    ,output          OutFetchOutInstrBranch
    ,output          OutFetchOutInstrMul
    ,output          OutFetchOutInstrDiv
    ,output          OutFetchOutInstrCsr
    ,output          OutFetchOutInstrRdValid
    ,output          OutFetchOutInstrInvalid
);



wire        EnableMuldivW     = SUPPORT_MULDIV;


generate
if (EXTRA_DECODE_STAGE)
begin
    wire [31:0] FetchInInstrW = (InFetchInFaultPage | InFetchInFaultFetch) ? 32'b0 : InFetchInInstr;
    reg [66:0]  BufferQ;

    always @(posedge InClk or posedge InRst)
    if (InRst)
        BufferQ <= 67'b0;
    else if (InSquashDecode)
        BufferQ <= 67'b0;
    else if (InFetchOutAccept || !OutFetchOutValid)
        BufferQ <= {InFetchInValid, InFetchInFaultPage, InFetchInFaultFetch, FetchInInstrW, InFetchInPC};

    assign {OutFetchOutValid,
            OutFetchOutFaultPage,
            OutFetchOutFaultFetch,
            OutFetchOutInstr,
            OutFetchOutPc} = BufferQ;

    riscv_decoder
    u_dec
    (
         .valid_i(OutFetchOutValid)
        ,.fetch_fault_i(OutFetchOutFaultPage | OutFetchOutFaultFetch)
        ,.enable_muldiv_i(EnableMuldivW)
        ,.opcode_i(OutFetchOutInstr)

        ,.invalid_o(OutFetchOutInstrInvalid)
        ,.exec_o(OutFetchOutInstrExec)
        ,.lsu_o(OutFetchOutInstrLsu)
        ,.branch_o(OutFetchOutInstrBranch)
        ,.mul_o(OutFetchOutInstrMul)
        ,.div_o(OutFetchOutInstrDiv)
        ,.csr_o(OutFetchOutInstrCsr)
        ,.rd_valid_o(OutFetchOutInstrRdValid)
    );

    assign OutFetchInAccept        = InFetchOutAccept;
end

else
begin
    wire [31:0] FetchInInstrW = (InFetchInFaultPage | InFetchInFaultFetch) ? 32'b0 : InFetchInInstr;

    riscv_decoder
    u_dec
    (
         .valid_i(InFetchInValid)
        ,.fetch_fault_i(InFetchInFaultFetch | InFetchInFaultPage)
        ,.enable_muldiv_i(EnableMuldivW)
        ,.opcode_i(OutFetchOutInstr)

        ,.invalid_o(OutFetchOutInstrInvalid)
        ,.exec_o(OutFetchOutInstrExec)
        ,.lsu_o(OutFetchOutInstrLsu)
        ,.branch_o(OutFetchOutInstrBranch)
        ,.mul_o(OutFetchOutInstrMul)
        ,.div_o(OutFetchOutInstrDiv)
        ,.csr_o(OutFetchOutInstrCsr)
        ,.rd_valid_o(OutFetchOutInstrRdValid)
    );

    // Outputs
    assign OutFetchOutValid        = InFetchInValid;
    assign OutFetchOutPc           = InFetchInPC;
    assign OutFetchOutInstr        = FetchInInstrW;
    assign OutFetchOutFaultPage   = InFetchInFaultPage;
    assign OutFetchOutFaultFetch  = InFetchInFaultFetch;

    assign OutFetchInAccept        = InFetchOutAccept;
end
endgenerate


endmodule

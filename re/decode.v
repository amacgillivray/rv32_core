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

module decode

// Parameters
#(
     parameter SUPPORT_MULDIV = 1
    ,parameter EXTRA_DECODE_STAGE = 0
)

(
    // Inputs
     input           clk
    ,input           rst
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

wire EnableMuldivW = SUPPORT_MULDIV;

//To better the cycle time, extra decode stage is added
generate
if(EXTRA_DECODE_STAGE)
begin
    wire [31:0] FetchInInstrW = (InFetchInFaultPage | InFetchInFaultFetch) ? 32'b0 : InFetchInInstr;
    reg [66:0]  BufferQ;

    always @(posedge clk or posedge rst)
    if(rst)
        BufferQ <= 67'b0;

    else if(InSquashDecode)
        BufferQ <= 67'b0;

    else if(InFetchOutAccept || !OutFetchOutValid)
        BufferQ <= {InFetchInValid, InFetchInFaultPage, InFetchInFaultFetch, FetchInInstrW, InFetchInPC};


    assign {OutFetchOutValid,
            OutFetchOutFaultPage,
            OutFetchOutFaultFetch,
            OutFetchOutInstr,
            OutFetchOutPc} = BufferQ;

    decoder
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
    assign OutFetchInAccept = InFetchOutAccept;
end

// Through decoder
else
begin
    wire [31:0] FetchInInstrW = (InFetchInFaultPage | InFetchInFaultFetch) ? 32'b0 : InFetchInInstr;
    decoder
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
    assign OutFetchOutValid = InFetchInValid;
    assign OutFetchOutPc = InFetchInPC;
    assign OutFetchOutInstr = FetchInInstrW;
    assign OutFetchOutFaultPage = InFetchInFaultPage;
    assign OutFetchOutFaultFetch = InFetchInFaultFetch;
    assign OutFetchInAccept = InFetchOutAccept;
end
endgenerate
endmodule

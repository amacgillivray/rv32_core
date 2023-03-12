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
//--------------------------------------------------------------

// Rewritten by Andrew MacGillivray with heavy reference to the original code

module divider
(
    ///////////////////
    // INPUTS 
    ///////////////////
    // clock / reset
     input clk
    ,input rst
    // opcode 
    ,input        oc_valid
    ,input [31:0] oc_oc
    ,input [31:0] oc_pc
    ,input        oc_invalid
    ,input [ 4:0] oc_rd_idx
    ,input [ 4:0] oc_ra_idx
    ,input [ 4:0] oc_rb_idx
    ,input [31:0] oc_ra_operand
    ,input [31:0] oc_rb_operand

    ///////////////////
    // OUTPUTS  
    ///////////////////
    // writeback
    ,output        wb_valid
    ,output [31:0] wb_value
);

`include "defs.v"

// Registers / Wires
reg          valid_q;
reg  [31:0]  wb_result_q;

// Divider
wire inst_div_w  = (oc_oc & `INST_DIV_MASK)  == `INST_DIV;
wire inst_divu_w = (oc_oc & `INST_DIVU_MASK) == `INST_DIVU;
wire inst_rem_w  = (oc_oc & `INST_REM_MASK)  == `INST_REM;
wire inst_remu_w = (oc_oc & `INST_REMU_MASK) == `INST_REMU;

wire div_rem_inst_w =   ((oc_oc & `INST_DIV_MASK)  == `INST_DIV)  || 
                        ((oc_oc & `INST_DIVU_MASK) == `INST_DIVU) ||
                        ((oc_oc & `INST_REM_MASK)  == `INST_REM)  ||
                        ((oc_oc & `INST_REMU_MASK) == `INST_REMU);

wire signed_operation_w = ((oc_oc & `INST_DIV_MASK) == `INST_DIV) || ((oc_oc & `INST_REM_MASK)  == `INST_REM);
wire div_operation_w    = ((oc_oc & `INST_DIV_MASK) == `INST_DIV) || ((oc_oc & `INST_DIVU_MASK) == `INST_DIVU);

reg [31:0] dividend_q;
reg [62:0] divisor_q;
reg [31:0] quotient_q;
reg [31:0] q_mask_q;
reg        div_inst_q;
reg        div_busy_q;
reg        invert_res_q;

wire div_start_w    = oc_valid & div_rem_inst_w;
wire div_complete_w = !(|q_mask_q) & div_busy_q;

always @(posedge clk or posedge rst)
if (rst)
begin
    div_busy_q     <= 1'b0;
    dividend_q     <= 32'b0;
    divisor_q      <= 63'b0;
    invert_res_q   <= 1'b0;
    quotient_q     <= 32'b0;
    q_mask_q       <= 32'b0;
    div_inst_q     <= 1'b0;
end
else if (div_start_w)
begin
    div_busy_q     <= 1'b1;
    div_inst_q     <= div_operation_w;

    if (signed_operation_w && oc_ra_operand[31])
        dividend_q <= -oc_ra_operand;
    else
        dividend_q <= oc_ra_operand;

    if (signed_operation_w && oc_rb_operand[31])
        divisor_q <= {-oc_rb_operand, 31'b0};
    else
        divisor_q <= {oc_rb_operand, 31'b0};

    invert_res_q  <= (((oc_oc & `INST_DIV_MASK) == `INST_DIV) && (oc_ra_operand[31] != oc_rb_operand[31]) && |oc_rb_operand) || 
                     (((oc_oc & `INST_REM_MASK) == `INST_REM) && oc_ra_operand[31]);

    quotient_q     <= 32'b0;
    q_mask_q       <= 32'h80000000;
end
else if (div_complete_w)
begin
    div_busy_q <= 1'b0;
end
else if (div_busy_q)
begin
    if (divisor_q <= {31'b0, dividend_q})
    begin
        dividend_q <= dividend_q - divisor_q[31:0];
        quotient_q <= quotient_q | q_mask_q;
    end

    divisor_q <= {1'b0, divisor_q[62:1]};
    q_mask_q  <= {1'b0, q_mask_q[31:1]};
end

reg [31:0] div_result_r;
always @ *
begin
    div_result_r = 32'b0;

    if (div_inst_q)
        div_result_r = invert_res_q ? -quotient_q : quotient_q;
    else
        div_result_r = invert_res_q ? -dividend_q : dividend_q;
end

always @(posedge clk or posedge rst)
if (rst)
    valid_q <= 1'b0;
else
    valid_q <= div_complete_w;

always @(posedge clk or posedge rst)
if (rst)
    wb_result_q <= 32'b0;
else if (div_complete_w)
    wb_result_q <= div_result_r;

assign wb_valid = valid_q;
assign wb_value  = wb_result_q;

endmodule

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

// Rewritten by Jarrod Grothusen with heavy reference to the original code

/* todo - defines don't match names in defs.v */
module multiplier(
	input clk,
	input rst,
	input Valid,
	input [31:0] opcode,
	input [31:0] pc,
	input invalid,
	input [4:0] rd_idx,
	input [4:0] ra_idx,
	input [4:0] rb_idx,
	input [31:0] ra_operand,
	input [31:0] rb_operand,
	input hold,
	output [31:0] wb_value
);

`include "defs.v"

//registers & wires
reg [31:0]  result_1;
reg [32:0]  operand_a_2;
reg [32:0]  operand_b_2;
reg         mulhi_sel;


//multiplier

wire [64:0] mult_result;
reg [32:0] operand_a_1;
reg [32:0] operand_b_1;
reg [31:0] result;

wire mult_inst =	((oc & `IM__MUL) == `I__MUL) ||
					((oc & `IM__MULH) == `I__MULH) ||
					((oc & `IM__MULHSU) == `I__MULHSU) ||
					((oc & `IM__MULHU) == `I__MULHU);

//This sets operand_a
always @ *
begin
	if(((opcode & `IM__MULHSU) == `I__MULHSU) || ((opcode & `IM__MULH) == `I__MULH))
		operand_a_1 = {ra_operand[31], ra_operand[31:0]};
	else //is MULHU or MUL
		operand_a_1 = {1'b0, ra_operand[31:0]};
end

//This sets operand_b
always @ *
begin
	if(((opcode & `IM__MULHSU) == `I__MULHSU) || ((opcode & `IM__MULH) == `I__MULH))
		operand_b_1 = {rb_operand[31], rb_operand[31:0]};
	else //is MULHU or MUL
		operand_b_1 = {1'b0, rb_operand[31:0]};
end

//pipeline flops for mult
always @(posedge clk or posedge rst)
if(rst)
begin
	operand_a_2 <= 33'b0;
	operand_b_2 <= 33'b0;
	mulhi_sel <= 1'b0;
end
else if(hold)
	//do nothing
else if(valid && mult_inst)
begin
	operand_a_2 <= operand_a;
	operand_b_2 <= operand_b;
	mulhi_sel <= ~((opcode & `IM__MUL) == `I__MUL);
end
else
begin
	operand_a_2 <= 33'b0;
	operand_b_2 <= 33'b0;
	mulhi_sel <= 1'b0;
end

assign mult_result = {{32 {operand_a_2[32]}}, operand_a_2}*{{32 {operand_b_2[32]}}, operand_b_2};

always @*
begin
	result = mulhi_sel ? mult_result[63:32] : mult_result[31:0];
end

always @(posedge clk or posedge rst)
if(rst)
	result_1 <= 32'b0;
else if(~hold)
	result_1 <= result;

assign wb_value = result_1;
endmodule

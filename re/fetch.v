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

module fetch
// Params
#( parameter SUPPORT_MMU = 1)

// Ports
// _i for inputs and _o for outputs
(
    // Inputs
     input           clk
    ,input           rst
    ,input           f_accept_i
    ,input           ic_accept_i
    ,input           ic_valid_i
    ,input           ic_error_i
    ,input [31:0]    ic_inst_i
    ,input           ic_page_fault_i
    ,input           f_invalidate_i
    ,input           br_request_i
    ,input [31:0]    br_pc_i
    ,input [1:0]     br_priv_i

    // Outputs
    ,output          f_valid_o
    ,output [31:0]   f_instr_o
    ,output [31:0]   f_pc_o
    ,output          f_fault_o
    ,output          f_fault_page_o
    ,output          ic_rd_o
    ,output          ic_flush_o
    ,output          ic_invalidate_o
    ,output [31:0]   ic_pc_o
    ,output [1:0]    ic_priv_o
    ,output          squash_decode_o
);

// Registers / Wires

reg         active_q;
wire        ic_busy_w;
wire        stall_w = !f_accept_i || ic_busy_w || !ic_accept_i;

// Buffered branch
reg         br_q;
reg [31:0]  br_pc_q;
reg [1:0]   br_priv_q;

always @(posedge clk or posedge rst)
if(rst)
begin
    br_q <= 1'b0;
    br_pc_q <= 32'b0;
    br_priv_q <= 2'd3;
end
else if(br_request_i)
begin
    br_q <= 1'b1;
    br_pc_q <= br_pc_i;
    br_priv_q <= br_priv_i;
end
else if(ic_rd_o && ic_accept_i)
begin
    br_q <= 1'b0;
    br_pc_q <= 32'b0;
end

wire        br_w = br_q;
wire [31:0] br_pc_w = br_pc_q;
wire [1:0]  br_priv_w = br_priv_q;

assign squash_decode_o = br_request_i;

// Active flag

always @(posedge clk or posedge rst)
if(rst)
    active_q <= 1'b0;
else if(br_w && ~stall_w)
    active_q <= 1'b1;

// Stall flag

reg stall_q;

always @(posedge clk or posedge rst)
if(rst)
    stall_q <= 1'b0;
else
    stall_q <= stall_w;

// Request tracking

reg ic_f_q;
reg ic_invalidate_q;

// ICACHE fetch tracking

always @(posedge clk or posedge rst)
if(rst)
    ic_f_q <= 1'b0;
else if(ic_rd_o && ic_accept_i)
    ic_f_q <= 1'b1;
else if(ic_valid_i)
    ic_f_q <= 1'b0;

always @(posedge clk or posedge rst)
if(rst)
    ic_invalidate_q <= 1'b0;
else if(ic_invalidate_o && !ic_accept_i)
    ic_invalidate_q <= 1'b1;
else
    ic_invalidate_q <= 1'b0;

// PC

reg [31:0]  pc_f_q;
reg [31:0]  pc_d_q;

wire [31:0] ic_pc_w;
wire [1:0]  ic_priv_w;
wire        f_resp_drop_w;

reg [1:0] priv_f_q;
reg       br_d_q;

always @(posedge clk or posedge rst)
if(rst)
begin
    pc_f_q  <= 32'b0;
    priv_f_q  <= 2'd3;
    br_d_q  <= 1'b0;
end
else if(br_w && ~stall_w)   // Branch request
begin
    pc_f_q  <= br_pc_w;
    priv_f_q  <= br_priv_w;
    br_d_q  <= 1'b1;
end
else if(!stall_w)               // NPC
begin
    pc_f_q  <= {ic_pc_w[31:2],2'b0} + 32'd4; 
    br_d_q  <= 1'b0;   
end

assign ic_pc_w = pc_f_q;
assign ic_priv_w = priv_f_q;
assign f_resp_drop_w = br_w | br_d_q;

// Last fetch address

always @(posedge clk or posedge rst)
if(rst)
    pc_d_q <= 32'b0;
else if(ic_rd_o && ic_accept_i)
    pc_d_q <= ic_pc_w;

// Outputs

assign ic_rd_o = active_q & f_accept_i & !ic_busy_w;
assign ic_pc_o = {ic_pc_w[31:2], 2'b0};
assign ic_priv_o = ic_priv_w;
assign ic_flush_o = f_invalidate_i | ic_invalidate_q;
assign ic_invalidate_o = 1'b0;

assign ic_busy_w =  ic_f_q && !ic_valid_i;

// Response Buffer

reg [65:0]  skid_buffer_q;
reg         skid_valid_q;

always @(posedge clk or posedge rst)
if(rst)
begin
    skid_buffer_q  <= 66'b0;
    skid_valid_q   <= 1'b0;
end 
// Instruction output back-pressured - hold in skid buffer
else if(f_valid_o && !f_accept_i)
begin
    skid_valid_q  <= 1'b1;
    skid_buffer_q <= {f_fault_page_o, f_fault_o, f_pc_o, f_instr_o};
end
else
begin
    skid_valid_q  <= 1'b0;
    skid_buffer_q <= 66'b0;
end

assign f_valid_o = (ic_valid_i || skid_valid_q) & !f_resp_drop_w;
assign f_pc_o = skid_valid_q ? skid_buffer_q[63:32] : {pc_d_q[31:2],2'b0};
assign f_instr_o = skid_valid_q ? skid_buffer_q[31:0]  : ic_inst_i;

// Faults
assign f_fault_o = skid_valid_q ? skid_buffer_q[64] : ic_error_i;
assign f_fault_page_o  = skid_valid_q ? skid_buffer_q[65] : ic_page_fault_i;

endmodule
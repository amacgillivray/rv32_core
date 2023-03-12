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

module mmu

// Parameters
#(
     parameter MEM_CACHE_ADDR_MIN = 32'h80000000
    ,parameter MEM_CACHE_ADDR_MAX = 32'h8fffffff
    ,parameter SUPPORT_MMU = 1
)

// Ports
(
    // Inputs
     input           InClk
    ,input           InRst
    ,input  [  1:0]  InPrivI
    ,input           InSum
    ,input           InMxr
    ,input           InFlush
    ,input  [ 31:0]  InSatp
    ,input           InFetchInRd
    ,input           FetchInInFlush
    ,input           InFetchInInvalidate
    ,input  [ 31:0]  InFetchInPc
    ,input  [  1:0]  InFetchInPriv
    ,input           InFetchOutAccept
    ,input           InFetchOutValid
    ,input           InFetchOutError
    ,input  [ 31:0]  InFetchOutInst
    ,input  [ 31:0]  InLsuInAddr
    ,input  [ 31:0]  InLsuInDataWr
    ,input           InLsuInRd
    ,input  [  3:0]  InLsuInWr
    ,input           InLsuInCacheable
    ,input  [ 10:0]  InLsuInReqTag
    ,input           InLsuInInvalidate
    ,input           InLsuInWriteback
    ,input           InLsuInFlush
    ,input  [ 31:0]  InLsuOutDataRd
    ,input           InLsuOutAccept
    ,input           InLsuOutAck
    ,input           InLsuOutError
    ,input  [ 10:0]  InLsuOutRespTag

    // Outputs
    ,output          OutFetchInAccept
    ,output          OutFetchInValid
    ,output          OutFetchInError
    ,output [ 31:0]  OutFetchInInst
    ,output          OutFetchOutRd
    ,output          OutFetchOutFlush
    ,output          OutFetchOutInvalidate
    ,output [ 31:0]  OutFetchOutPc
    ,output          OutFetchInFault
    ,output [ 31:0]  OutLsuInDataRd
    ,output          OutLsuInAccept
    ,output          OutLsuInAck
    ,output          OutLsuInError
    ,output [ 10:0]  OutLsuInRespTag
    ,output [ 31:0]  OutLsuOutAddr
    ,output [ 31:0]  OutLsuOutDataWr
    ,output          OutLsuOutRd
    ,output [  3:0]  OutLsuOutWr
    ,output          OutLsuOutCacheable
    ,output [ 10:0]  OutLsuOutReqTag
    ,output          OutLsuOutInvalidate
    ,output          OutLsuOutWriteback
    ,output          OutLsuOutFlush
    ,output          OutLsuInLoadFault
    ,output          OutLsuInStoreFault
);

// Includes the following file
`include "defs.v"

// Local definitions
localparam  STATE_W = 2;
localparam  STATE_IDLE = 0;
localparam  STATE_LEVEL_FIRST = 1;
localparam  STATE_LEVEL_SECOND = 2;
localparam  STATE_UPDATE = 3;

// Basic support of Memory Management Unit 
generate
if (SUPPORT_MMU)
begin

    // Registers
    reg [STATE_W-1:0] state_q;
    wire idle_w = (state_q == STATE_IDLE);

    // Only Memory Management Unit uses this magic combination
    wire resp_mmu_w = (InLsuOutRespTag[9:7] == 3'b111);
    wire resp_valid_w = resp_mmu_w & InLsuOutAck;
    wire resp_error_w = resp_mmu_w & InLsuOutError;
    wire [31:0] resp_data_w = InLsuOutDataRd;
    wire cpu_accept_w;


    // Store and Load
    reg load_q;
    reg [3:0] store_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        load_q <= 1'b0;

    else if (InLsuInRd)
        load_q <= ~OutLsuInAccept;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        store_q <= 4'b0;

    else if (|InLsuInWr)
        store_q <= OutLsuInAccept ? 4'b0 : InLsuInWr;

    wire load_w = InLsuInRd | load_q;
    wire [3:0] store_w = InLsuInWr | store_q;

    reg [31:0] lsu_in_addr_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        lsu_in_addr_q <= 32'b0;

    else if (load_w || (|store_w))
        lsu_in_addr_q <= InLsuInAddr;

    wire [31:0] lsu_addr_w = (load_w || (|store_w)) ? InLsuInAddr : lsu_in_addr_q;

    // Page-table walker
    wire itlb_hit_w;
    wire dtlb_hit_w;
    reg dtlb_req_q;

    // Global enable
    wire vm_enable_w = InSatp[`SATP_MODE_R];
    wire [31:0] ptbr_w = {InSatp[`SATP_PPN_R], 12'b0};

    wire ifetch_vm_w = (InFetchInPriv != `PRIV_MACHINE);
    wire dfetch_vm_w = (InPrivI != `PRIV_MACHINE);

    wire supervisor_i_w = (InFetchInPriv == `PRIV_SUPER);
    wire supervisor_d_w = (InPrivI == `PRIV_SUPER);

    wire vm_i_enable_w = (ifetch_vm_w);
    wire vm_d_enable_w = (vm_enable_w & dfetch_vm_w);

    // Request address does not match translation lookaside buffer entry
    wire itlb_miss_w = InFetchInRd & vm_i_enable_w & ~itlb_hit_w;
    wire dtlb_miss_w = (load_w || (|store_w)) & vm_d_enable_w & ~dtlb_hit_w;

    // Instruction has a lower priority than data miss
    wire [31:0] request_addr_w = idle_w ? 
                                (dtlb_miss_w ? lsu_addr_w : InFetchInPc) :
                                 dtlb_req_q ? lsu_addr_w : InFetchInPc;

    reg [31:0]  pte_addr_q;
    reg [31:0]  pte_entry_q;
    reg [31:0]  virt_addr_q;

    wire [31:0] pte_ppn_w = {`PAGE_PFN_SHIFT'b0, resp_data_w[31:`PAGE_PFN_SHIFT]};
    wire [9:0]  pte_flags_w = resp_data_w[9:0];

    always @ (posedge InClk or posedge InRst)
    if (InRst)
    begin
        pte_addr_q <= 32'b0;
        pte_entry_q <= 32'b0;
        virt_addr_q <= 32'b0;
        dtlb_req_q <= 1'b0;
        state_q <= STATE_IDLE;
    end
    else
    begin
        // Walk page table when translation lookaside buffer miss
        if (state_q == STATE_IDLE && (itlb_miss_w || dtlb_miss_w))
        begin
            pte_addr_q <= ptbr_w + {20'b0, request_addr_w[31:22], 2'b0};
            virt_addr_q <= request_addr_w;
            dtlb_req_q <= dtlb_miss_w;
            state_q <= STATE_LEVEL_FIRST;
        end

        // First level which is 4MB superpage
        else if (state_q == STATE_LEVEL_FIRST && resp_valid_w)
        begin
            // Page or error are absent
            if (resp_error_w || !resp_data_w[`PAGE_PRESENT])
            begin
                pte_entry_q <= 32'b0;
                state_q <= STATE_UPDATE;
            end

            // Good entry, but you need to fetch another level
            else if (!(resp_data_w[`PAGE_READ] || resp_data_w[`PAGE_WRITE] || resp_data_w[`PAGE_EXEC]))
            begin
                pte_addr_q  <= {resp_data_w[29:10], 12'b0} + {20'b0, request_addr_w[21:12], 2'b0};
                state_q <= STATE_LEVEL_SECOND;
            end

            // Valid entry and actual valid PTE
            else
            begin
                pte_entry_q <= ((pte_ppn_w | {22'b0, request_addr_w[21:12]}) << `MMU_PGSHIFT) | {22'b0, pte_flags_w};
                state_q <= STATE_UPDATE;
            end
        end

        // Second level which is 4KB page
        else if (state_q == STATE_LEVEL_SECOND && resp_valid_w)
        begin
            // Valid entry and the final level
            if (resp_data_w[`PAGE_PRESENT])
            begin
                pte_entry_q <= (pte_ppn_w << `MMU_PGSHIFT) | {22'b0, pte_flags_w};
                state_q <= STATE_UPDATE;
            end

            // Page fault
            else
            begin
                pte_entry_q <= 32'b0;
                state_q <= STATE_UPDATE;
            end
        end
        else if (state_q == STATE_UPDATE)
        begin
            state_q <= STATE_IDLE;
        end
    end

    // IMMU translation lookaside buffer
    reg         itlb_valid_q;
    reg [31:12] itlb_va_addr_q;
    reg [31:0]  itlb_entry_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        itlb_valid_q <= 1'b0;

    else if (InFlush)
        itlb_valid_q <= 1'b0;

    else if (state_q == STATE_UPDATE && !dtlb_req_q)
        // Still matches incoming request, get translation lookaside buffer
        itlb_valid_q <= (itlb_va_addr_q == InFetchInPc[31:12]);

    else if (state_q != STATE_IDLE && !dtlb_req_q)
        itlb_valid_q <= 1'b0;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
    begin
        itlb_va_addr_q <= 20'b0;
        itlb_entry_q <= 32'b0;
    end

    else if (state_q == STATE_UPDATE && !dtlb_req_q)
    begin
        itlb_va_addr_q <= virt_addr_q[31:12];
        itlb_entry_q <= pte_entry_q;
    end

    // Even with a page fault, the translation lookaside buffer address matched
    assign itlb_hit_w = InFetchInRd & itlb_valid_q & (itlb_va_addr_q == InFetchInPc[31:12]);

    reg pc_fault_r;
    always @ *
    begin
        pc_fault_r = 1'b0;

        if (vm_i_enable_w && itlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_i_w)
            begin

                // Supervisor cannot run on the user page
                if (itlb_entry_q[`PAGE_USER])
                    pc_fault_r = 1'b1;

                // Examine the exec permissions
                else
                    pc_fault_r = ~itlb_entry_q[`PAGE_EXEC];
            end

            // User mode
            else
                pc_fault_r = (~itlb_entry_q[`PAGE_EXEC]) | (~itlb_entry_q[`PAGE_USER]);
        end
    end

    reg pc_fault_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        pc_fault_q <= 1'b0;

    else
        pc_fault_q <= pc_fault_r;

    assign OutFetchOutRd = (~vm_i_enable_w & InFetchInRd) || (itlb_hit_w & ~pc_fault_r);
    assign OutFetchOutPc = vm_i_enable_w ? {itlb_entry_q[31:12], InFetchInPc[11:0]} : InFetchInPc;
    assign OutFetchOutFlush = FetchInInFlush;
    assign OutFetchOutInvalidate = InFetchInInvalidate; // TODO: ...
    assign OutFetchInAccept = (~vm_i_enable_w & InFetchOutAccept) | (vm_i_enable_w & itlb_hit_w & InFetchOutAccept) | pc_fault_r;
    assign OutFetchInValid = InFetchOutValid | pc_fault_q;
    assign OutFetchInError = InFetchOutValid & InFetchOutError;
    assign OutFetchInFault = pc_fault_q;
    assign OutFetchInInst = InFetchOutInst;

    // DMMU translation lookaside buffer
    reg  dtlb_valid_q;
    reg [31:12] dtlb_va_addr_q;
    reg [31:0]  dtlb_entry_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        dtlb_valid_q <= 1'b0;

    else if (InFlush)
        dtlb_valid_q <= 1'b0;

    else if (state_q == STATE_UPDATE && dtlb_req_q)
        dtlb_valid_q <= 1'b1;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
    begin
        dtlb_va_addr_q <= 20'b0;
        dtlb_entry_q <= 32'b0;
    end

    else if (state_q == STATE_UPDATE && dtlb_req_q)
    begin
        dtlb_va_addr_q <= virt_addr_q[31:12];
        dtlb_entry_q <= pte_entry_q;
    end

    // Even with a page fault the translation lookaside buffer address matched
    assign dtlb_hit_w = dtlb_valid_q & (dtlb_va_addr_q == lsu_addr_w[31:12]);

    reg load_fault_r;
    always @ *
    begin
        load_fault_r = 1'b0;

        if (vm_d_enable_w && load_w && dtlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_d_w)
            begin
                // Supervisor user mode is not enabled on the user page
                if (dtlb_entry_q[`PAGE_USER] && !InSum)
                    load_fault_r = 1'b1;

                // Examine the exec permissions
                else
                    load_fault_r = ~(dtlb_entry_q[`PAGE_READ] | (InMxr & dtlb_entry_q[`PAGE_EXEC]));
            end

            // User mode
            else
                load_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_USER]);
        end
    end

    reg store_fault_r;
    always @ *
    begin
        store_fault_r = 1'b0;

        if (vm_d_enable_w && (|store_w) && dtlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_d_w)
            begin
                // Supervisor user mode is not enabled on the user page
                if (dtlb_entry_q[`PAGE_USER] && !InSum)
                    store_fault_r = 1'b1;

                // Examine the exec permissions
                else
                    store_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_WRITE]);
            end
            // User mode
            else
                store_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_WRITE]) | (~dtlb_entry_q[`PAGE_USER]);
        end
    end

    reg store_fault_q;
    reg load_fault_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        store_fault_q <= 1'b0;
    else
        store_fault_q <= store_fault_r;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        load_fault_q <= 1'b0;
    else
        load_fault_q <= load_fault_r;   

    wire lsu_out_rd_w = vm_d_enable_w ? (load_w  & dtlb_hit_w & ~load_fault_r)       : InLsuInRd;
    wire [3:0]  lsu_out_wr_w = vm_d_enable_w ? (store_w & {4{dtlb_hit_w & ~store_fault_r}}) : InLsuInWr;
    wire [31:0] lsu_out_addr_w = vm_d_enable_w ? {dtlb_entry_q[31:12], lsu_addr_w[11:0]}      : lsu_addr_w;
    wire [31:0] lsu_out_data_wr_w = InLsuInDataWr;
    wire lsu_out_invalidate_w = InLsuInInvalidate;
    wire lsu_out_writeback_w  = InLsuInWriteback;

    reg         lsu_out_cacheable_r;

    always @ *
    begin
    //verilator lint_off UNSIGNED 
    // verilator lint_off CMPCONST 
        if (InLsuInInvalidate || InLsuInWriteback || InLsuInFlush)
            lsu_out_cacheable_r = 1'b1;
        else
            lsu_out_cacheable_r = (lsu_out_addr_w >= MEM_CACHE_ADDR_MIN && lsu_out_addr_w <= MEM_CACHE_ADDR_MAX);
    // verilator lint_on CMPCONST 
    // verilator lint_on UNSIGNED 
    end

    wire [10:0] lsu_out_req_tag_w = InLsuInReqTag;
    wire lsu_out_flush_w = InLsuInFlush;

    assign OutLsuInAck = (InLsuOutAck & ~resp_mmu_w) | store_fault_q | load_fault_q;
    assign OutLsuInRespTag = InLsuOutRespTag;
    assign OutLsuInError = (InLsuOutError & ~resp_mmu_w) | store_fault_q | load_fault_q;
    assign OutLsuInDataRd = InLsuOutDataRd;
    assign OutLsuInStoreFault = store_fault_q;
    assign OutLsuInLoadFault = load_fault_q;
    assign OutLsuInAccept = (~vm_d_enable_w & cpu_accept_w) | (vm_d_enable_w & dtlb_hit_w & cpu_accept_w) | store_fault_r | load_fault_r;

    // PTE Fetch Port
    reg mem_req_q;
    wire mmu_accept_w;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
        mem_req_q <= 1'b0;

    else if (state_q == STATE_IDLE && (itlb_miss_w || dtlb_miss_w))
        mem_req_q <= 1'b1;

    else if (state_q == STATE_LEVEL_FIRST && resp_valid_w && !resp_error_w && resp_data_w[`PAGE_PRESENT] && (!(resp_data_w[`PAGE_READ] || resp_data_w[`PAGE_WRITE] || resp_data_w[`PAGE_EXEC])))
        mem_req_q <= 1'b1; 

    else if (mmu_accept_w)
        mem_req_q <= 1'b0;

    // Muxing is requested
    reg  read_hold_q;
    reg  src_mmu_q;
    wire src_mmu_w = read_hold_q ? src_mmu_q : mem_req_q;

    always @ (posedge InClk or posedge InRst)
    if (InRst)
    begin
        read_hold_q <= 1'b0;
        src_mmu_q <= 1'b0;
    end

    else if ((OutLsuOutRd || (|OutLsuOutWr)) && !InLsuOutAccept)
    begin
        read_hold_q <= 1'b1;
        src_mmu_q <= src_mmu_w;
    end

    else if (InLsuOutAccept)
        read_hold_q <= 1'b0;

    assign mmu_accept_w = src_mmu_w  & InLsuOutAccept;
    assign cpu_accept_w = ~src_mmu_w & InLsuOutAccept;
    assign OutLsuOutRd = src_mmu_w ? mem_req_q : lsu_out_rd_w;
    assign OutLsuOutWr = src_mmu_w ? 4'b0 : lsu_out_wr_w;
    assign OutLsuOutAddr = src_mmu_w ? pte_addr_q : lsu_out_addr_w;
    assign OutLsuOutDataWr = lsu_out_data_wr_w;
    assign OutLsuOutInvalidate = src_mmu_w ? 1'b0 : lsu_out_invalidate_w;
    assign OutLsuOutWriteback = src_mmu_w ? 1'b0 : lsu_out_writeback_w;
    assign OutLsuOutCacheable = src_mmu_w ? 1'b1 : lsu_out_cacheable_r;
    assign OutLsuOutReqTag = src_mmu_w ? {1'b0, 3'b111, 7'b0} : lsu_out_req_tag_w;
    assign OutLsuOutFlush = src_mmu_w ? 1'b0 : lsu_out_flush_w;

end

// No support for Memory Management Unit
else
begin
    assign OutFetchOutRd = InFetchInRd;
    assign OutFetchOutPc = InFetchInPc;
    assign OutFetchOutFlush = FetchInInFlush;
    assign OutFetchOutInvalidate = InFetchInInvalidate;
    assign OutFetchInAccept = InFetchOutAccept;
    assign OutFetchInValid = InFetchOutValid;
    assign OutFetchInError = InFetchOutError;
    assign OutFetchInFault = 1'b0;
    assign OutFetchInInst = InFetchOutInst;
    assign OutLsuOutRd = InLsuInRd;
    assign OutLsuOutWr = InLsuInWr;
    assign OutLsuOutAddr = InLsuInAddr;
    assign OutLsuOutDataWr = InLsuInDataWr;
    assign OutLsuOutInvalidate = InLsuInInvalidate;
    assign OutLsuOutWriteback = InLsuInWriteback;
    assign OutLsuOutCacheable = InLsuInCacheable;
    assign OutLsuOutReqTag = InLsuInReqTag;
    assign OutLsuOutFlush = InLsuInFlush;
    assign OutLsuInAck = InLsuOutAck;
    assign OutLsuInRespTag = InLsuOutRespTag;
    assign OutLsuInError = InLsuOutError;
    assign OutLsuInDataRd = InLsuOutDataRd;
    assign OutLsuInStoreFault = 1'b0;
    assign OutLsuInLoadFault = 1'b0;
    assign OutLsuInAccept = InLsuOutAccept;

end
endgenerate

endmodule
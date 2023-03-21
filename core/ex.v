//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 03/20/2023 04:42:17 PM
// Design Name: Execution Module
// Module Name: ex
// Project Name: RV32 Core
// Target Devices: 
// Description: Untested
//////////////////////////////////////////////////////////////////////////////////
module ex(

    // Clock and Reset
     input clk
    ,input rst
    
    // Control Unit Signals
    ,input ex_i_flush
    
    // ALU Forwarding Signals
    ,input ex_i_ctrl_mux3
    ,input ex_i_ctrl_mux4
    
    // Forwarding: 
    ,input ex_i_mem_data // from Mem
    ,input ex_i_wb_data  // from WriteBack

    // ID/EX Latch Parts
    ,input [1:0] ex_i_wb
    ,input [4:0] ex_i_mem
    ,input [5:0] ex_i_ex

    // Program Counter (Forwarded)
    ,input [31:0] ex_i_pc

    // From Register File / Instruction Decode Stage
    ,input [31:0] ex_i_read_data_a
    ,input [31:0] ex_i_read_data_b

    // Instruction segments
    // TODO: could send just the ex_i_instr to the latch, split there
    ,input [31:0] ex_i_instr 
    ,input [5:0]  ex_i_instr_s1 // instruction [30, 25, 14:12, 3]
    ,input [4:0]  ex_i_instr_s2 // instruction [19-15]
    ,input [4:0]  ex_i_instr_s3 // instruction [24-20]
    ,input [4:0]  ex_i_instr_s4 // instruction [11-7]
    
    // values to send to EX/MEM Latch
    ,output [1:0] ex_o_wb
    ,output [4:0] ex_o_mem
    ,output [31:0] ex_o_alu_result
    
);

/* "em1_{x}": Values to carry forward to EX/MEM latch */
wire [1:0]  eml_wb  = ex_i_wb;  // writeback
wire [4:0]  em1_mem = ex_i_mem; // memory
wire [31:0] em1_alu_result;

/* "ea_{x}": Intermediary values to send towards ALU */
wire [31:0] ea_opr_at; // operand A (temp), from output of mux 3  ->  mux 5
wire [31:0] ea_opr_a ; // operand A, from output of mux 5  ->  ALU
wire [31:0] ea_opr_bt; // operand B (temp), from output of mux 4  ->  mux 6
wire [31:0] ea_opr_b ; // operand B, from output of mux 6  ->  ALU
wire [4:0]  ea_aluc  ; // ALU control signal, from ALU Control Unit

/* Do EX MUX 1, store output in em1_wb for carry to the ex/mem latch */
/* Purpose: Sets wb control signals to 0 for wb stage if there's an exception */
ex_mux1
exmux1( 
    //  .clk(clk)
    // ,.rst(rst),
     .ex_flush(ex_i_flush)
    ,.id_ex_wb(ex_i_wb)
    ,.ex_mem_wb(em1_wb)
);

/* Do EX MUX 2, store output in em1_mem for carry to the ex/mem latch */
/* Purpose: Sets mem control signals to 0 for wb stage if there's an exception */
ex_mux2
exmux2(
    //  .clk(clk)
    // ,.rst(rst),
     .ex_flush(ex_i_flush)
    ,.id_ex_m(ex_i_mem)
    ,.ex_mem_m(em1_mem)
);

/* Do EX MUX 3, send output to EX MUX 5 */
/* Purpose: Used to control forwarding for ALU Source 1 */
ex_mux3
exmux3(
    //  .clk(clk)
    // ,.rst(rst),
     .ctrl(ex_i_ctrl_mux3)
    ,.id_exReadData1(ex_i_read_data_a)
    ,.wbData(ex_i_wb_data)
    ,.ex_memData(ex_i_mem_data)
    ,.tempAluOp1(ea_opr_at)
);

/* Do EX MUX 4, send output to EX MUX 6 */
/* Purpose: Used to control forwarding for ALU Source 2 */
ex_mux4
exmux4(
    //  .clk(clk)
    // ,.rst(rst),
     .ctrl(ex_i_ctrl_mux4)
    ,.id_exReadData2(ex_i_read_data_b)
    ,.wbData(ex_i_wb_data)
    ,.ex_memData(ex_i_mem_data)
    ,.tempAluOp2(ea_opr_bt)
);

/* Do EX MUX 5, send output to ALU */
/* Purpose: Choose ALU Source 1 as MUX 3 output, Program Counter, or 0. */
ex_mux5
exmux5(
    //  .clk(clk)
    // ,.rst(rst),
     .aluSrc1(ex_i_ex) // TODO: comes from ex_i_ex, not sure which bit?
    ,.tempAluOp1(ea_opr_at)
    ,.id_ex_pc(ex_i_pc)
    ,.aluOp1(ea_opr_a)
);

/* Do EX MUX 6, send output to ALU */
/* Purpose: Choose ALU Source 2 as MUX 4 output, Immediate Value, or 4. */
ex_mux6
exmux6(
    //  .clk(clk)
    // ,.rst(rst),
     .aluSrc2(ex_i_ex) // TODO: comes from ex_i_ex, not sure which bit?
    ,.tempAluOp1(ea_opr_at)
    ,.id_ex_pc(ex_i_pc)
    ,.aluOp1(ea_opr_a)
);

/* Do ALU Control Unit, use as signal to ALU */
/* Checks the opcode and uses it to create the appropriate ALU control signal */
ex_alu_cntrl
exalucontrol(
     .clk(clk)
    ,.rst(rst)
    ,.alu_op(ex_i_instr)
    ,.alu_control(ea_aluc)
);

/* Run the ALU */
alu 
exalu(
     .alu_i_op(ea_aluc)
    ,.alu_i_a(ea_opr_a)
    ,.alu_i_b(ea_opr_b)
    ,.alu_o(em1_alu_result)
);

// TODO: CSR Unit?
// TODO: ALU forwarding unit?
// TODO: Sending to next latch?

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineer: Andrew MacGillivray
// 
// Create Date: 10/02/2022 01:04:49 PM
// Design Name: Register File
// Module Name: regfile
// Project Name: RV32 Core
// Target Devices: 
// Description: Describes a 32x32 register file
//////////////////////////////////////////////////////////////////////////////////

module regfile
(
    // Clock and Reset
     input           clk
    ,input           rst

    // Reading (Inputs)
    ,input  [4:0]    rf_i_read_reg_a // READ REG 1
    ,input  [4:0]    rf_i_read_reg_b // READ REG 2 

    // Writing
    ,input  [4:0]    rf_i_write_reg  // WRITE REG
    ,input  [31:0]   rf_i_write_data // WRITE DATA

    // Reading (Outputs)
    ,output [31:0]   rf_o_data_reg_a // READ DATA 1
    ,output [31:0]   rf_o_data_reg_b // READ DATA 2
);

//  VERILOG          | REG | ABI    | USAGE
// --------------------------------------------------------------------------------
//  regfile[0]         x0  | zero   | Hardwired Zeros
//  regfile[1]         x1  | ra     | Return Adddress
//  regfile[2]         x2  | sp     | Stack  Pointer
//  regfile[3]         x3  | gp     | Global Pointer
//  regfile[4]         x4  | tp     | Thread Pointer
//  regfile[5]         x5  | t0     | Temporary
//  regfile[6]         x6  | t1     | Temporary 
//  regfile[7]         x7  | t2     | Temporary
//  regfile[8]         x8  | s0/fp  | Saved Register / Frame Pointer
//  regfile[9]         x9  | s1     | Saved Register
//  regfile[10]        x10 | a0     | Function Argument / Return Value
//  regfile[11]        x11 | a1     | Function Argument / Return Value
//  regfile[12]        x12 | a2     | Function Argument 
//  regfile[13]        x13 | a3     | Function Argument 
//  regfile[14]        x14 | a4     | Function Argument 
//  regfile[15]        x15 | a5     | Function Argument 
//  regfile[16]        x16 | a6     | Function Argument 
//  regfile[17]        x17 | a7     | Function Argument 
//  regfile[18]        x18 | s2     | Saved Register
//  regfile[19]        x19 | s3     | Saved Register
//  regfile[20]        x20 | s4     | Saved Register
//  regfile[21]        x21 | s5     | Saved Register
//  regfile[22]        x22 | s6     | Saved Register
//  regfile[23]        x23 | s7     | Saved Register
//  regfile[24]        x24 | s8     | Saved Register
//  regfile[25]        x25 | s9     | Saved Register
//  regfile[26]        x26 | s10    | Saved Register
//  regfile[27]        x27 | s11    | Saved Register
//  regfile[28]        x28 | t3     | Temporary
//  regfile[29]        x29 | t4     | Temporary
//  regfile[30]        x30 | t5     | Temporary
//  regfile[31]        x31 | t6     | Temporary
    reg [31:0] regfile [31:0];
    
    wire [31:0] rw_x0_zero = 32'b0;
    wire [31:0] rw_x1_ra   = regfile[1];
    wire [31:0] rw_x2_sp   = regfile[2];
    wire [31:0] rw_x3_gp   = regfile[3];
    wire [31:0] rw_x4_tp   = regfile[4];
    wire [31:0] rw_x5_t0   = regfile[5];
    wire [31:0] rw_x6_t1   = regfile[6];
    wire [31:0] rw_x7_t2   = regfile[7];
    wire [31:0] rw_x8_s0   = regfile[8];
    wire [31:0] rw_x9_s1   = regfile[9];
    wire [31:0] rw_x10_a0  = regfile[10];
    wire [31:0] rw_x11_a1  = regfile[11];
    wire [31:0] rw_x12_a2  = regfile[12];
    wire [31:0] rw_x13_a3  = regfile[13];
    wire [31:0] rw_x14_a4  = regfile[14];
    wire [31:0] rw_x15_a5  = regfile[15];
    wire [31:0] rw_x16_a6  = regfile[16];
    wire [31:0] rw_x17_a7  = regfile[17];
    wire [31:0] rw_x18_s2  = regfile[18];
    wire [31:0] rw_x19_s3  = regfile[19];
    wire [31:0] rw_x20_s4  = regfile[20];
    wire [31:0] rw_x21_s5  = regfile[21];
    wire [31:0] rw_x22_s6  = regfile[22];
    wire [31:0] rw_x23_s7  = regfile[23];
    wire [31:0] rw_x24_s8  = regfile[24];
    wire [31:0] rw_x25_s9  = regfile[25];
    wire [31:0] rw_x26_s10 = regfile[26];
    wire [31:0] rw_x27_s11 = regfile[27];
    wire [31:0] rw_x28_t3  = regfile[28];
    wire [31:0] rw_x29_t4  = regfile[29];
    wire [31:0] rw_x30_t5  = regfile[30];
    wire [31:0] rw_x31_t6  = regfile[31];
    
    /* Registers to store data from read_reg_a, read_reg_b */ 
    reg [31:0] reg_a_data;
    reg [31:0] reg_b_data;
    
    genvar i;

    /* Regfile Writing (Synchronous) 
     */ 
    for (i = 1; i < 32; i = i+1) begin
    always @(posedge clk )
        if(rst)
            begin
                /* RST -> Reset all registers to 0s */
                regfile[i] <= 32'h00000000;
            end
        else
            begin
                /* Write the data in rf_i_write_data to the register specified by rf_i_write_reg */
                if (rf_i_write_reg == i) regfile[i] <= rf_i_write_data;
            end
    end
    
    /* Regfile Reading (Asynchronous) */
    always @ *
    begin
        /* Set to 0 before reading */
        reg_a_data <= 32'h00000000;
        reg_b_data <= 32'h00000000;
    end 
    for (i = 1; i < 32; i = i+1) begin
    always @ *
        begin
            /* Read from Register A */
            if (rf_i_read_reg_a == i) reg_a_data <= regfile[i];
            /* Read from Register B */
            if (rf_i_read_reg_b == i) reg_b_data <= regfile[i];
        end
    end
    
    /* Put what was read into the reg_a, reg_b data outputs */
    assign rf_o_data_reg_a = reg_a_data;
    assign rf_o_data_reg_b = reg_b_data;
endmodule

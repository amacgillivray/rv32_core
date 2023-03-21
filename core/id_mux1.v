//////////////////////////////////////////////////////////////////////////////////
// Company: EECS 581 Team 11
// Engineers: Jarrod Grothusen, Andrew MacGillivray
// 
// Create Date: 10/28/2022 06:20:18 PM
// Design Name: Instruction Decode Mux 1
// Module Name: id_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module id_mux1(
    input stall,
    input id_flush,
    input[1:0] cntrl_wb,
    input [4:0] cntrl_m,
    input [5:0] cntrl_ex,
    output [1:0] idex_wb,
    output [4:0] idex_m,
    output [5:0] idex_ex
    );
    reg control;
    reg [1:0] wb;
    reg [4:0] m;
    reg [5:0] ex;
    always @(*)
    begin
        control <= (stall | id_flush);
        case (control)
            1'b0: begin // is not JALR
                wb <= cntrl_wb;
                m <= cntrl_m;
                ex <= cntrl_ex;
            end
            1'b1: begin // is JALR 
                wb <= 2'b00;
                m <= 5'b00000;
                ex <= 6'b000000;
            end
        endcase
    end
    assign idex_wb = wb;
    assign idex_m  = m;
    assign idex_ex = ex;
endmodule

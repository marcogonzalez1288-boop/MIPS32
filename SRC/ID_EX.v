module ID_EX(
    input clk,
    input [5:0] opcode_in,
    output reg [5:0] opcode_out,

    // Control (NUEVO: Branch_in)
    input RegDst_in,
    input ALUSrc_in,
    input [1:0] ALUOp_in,
    input MemRead_in,
    input MemWrite_in,
    input RegWrite_in,
    input MemToReg_in,
    input Branch_in, 

    // Datos
    input [31:0] PC4_in,
    input [31:0] RD1_in,
    input [31:0] RD2_in,
    input [31:0] SignExt_in,

    input [4:0] rs_in,
    input [4:0] rt_in,
    input [4:0] rd_in,

    input [5:0] funct_in,

    // Salidas (NUEVO: Branch_out)
    output reg RegDst_out,
    output reg ALUSrc_out,
    output reg [1:0] ALUOp_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg Branch_out, 

    output reg [31:0] PC4_out,
    output reg [31:0] RD1_out,
    output reg [31:0] RD2_out,
    output reg [31:0] SignExt_out,

    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,

    output reg [5:0] funct_out
);

always @(posedge clk)
begin
    opcode_out   <= opcode_in;
    RegDst_out   <= RegDst_in;
    ALUSrc_out   <= ALUSrc_in;
    ALUOp_out    <= ALUOp_in;
    MemRead_out  <= MemRead_in;
    MemWrite_out <= MemWrite_in;
    RegWrite_out <= RegWrite_in;
    MemToReg_out <= MemToReg_in;
    Branch_out   <= Branch_in; // <--- NUEVO

    PC4_out      <= PC4_in;
    RD1_out      <= RD1_in;
    RD2_out      <= RD2_in;
    SignExt_out  <= SignExt_in;

    rs_out       <= rs_in;
    rt_out       <= rt_in;
    rd_out       <= rd_in;

    funct_out    <= funct_in;
end

endmodule
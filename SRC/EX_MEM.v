module EX_MEM(
    input clk,

    // Control (NUEVO: Branch_in)
    input MemRead_in,
    input MemWrite_in,
    input RegWrite_in,
    input MemToReg_in,
    input Branch_in,

    // Datos (NUEVO: Zero_in y BranchTarget_in)
    input [31:0] ALUResult_in,
    input [31:0] RD2_in,
    input [4:0] WriteReg_in,
    input Zero_in,
    input [31:0] BranchTarget_in,

    // Salidas (NUEVO: Branch_out, Zero_out, BranchTarget_out)
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg Branch_out,

    output reg [31:0] ALUResult_out,
    output reg [31:0] RD2_out,
    output reg [4:0] WriteReg_out,
    output reg Zero_out,
    output reg [31:0] BranchTarget_out
);

always @(posedge clk)
begin
    MemRead_out      <= MemRead_in;
    MemWrite_out     <= MemWrite_in;
    RegWrite_out     <= RegWrite_in;
    MemToReg_out     <= MemToReg_in;
    Branch_out       <= Branch_in;       // <--- NUEVO

    ALUResult_out    <= ALUResult_in;
    RD2_out          <= RD2_in;
    WriteReg_out     <= WriteReg_in;
    Zero_out         <= Zero_in;         // <--- NUEVO
    BranchTarget_out <= BranchTarget_in; // <--- NUEVO
end

endmodule
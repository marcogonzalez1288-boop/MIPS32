module CONTROL(
    input [5:0] OPCode,

    output reg RegDst,
    output reg Branch,
    output reg MemRead,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg MemToReg,
    output reg Jump
);

always @(*)
begin

    // Valores por defecto
    RegDst   = 0;
    Branch   = 0;
    MemRead  = 0;
    ALUOp    = 2'b00;
    MemWrite = 0;
    ALUSrc   = 0;
    RegWrite = 0;
    MemToReg = 0;
    Jump     = 0;

    case(OPCode)

        // R-Type
        6'b000000:
        begin
            RegDst   = 1;
            ALUSrc   = 0;
            RegWrite = 1;
            ALUOp    = 2'b10;
        end

        // ADDI
        6'b001000:
        begin
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp    = 2'b00;
        end

        // ANDI
        6'b001100:
        begin
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp    = 2'b11;
        end

        // ORI
        6'b001101:
        begin
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp    = 2'b11;
        end

        // SLTI
        6'b001010:
        begin
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp    = 2'b11;
        end

        // LW
        6'b100011:
        begin
            ALUSrc   = 1;
            MemRead  = 1;
            RegWrite = 1;
            MemToReg = 1;
            ALUOp    = 2'b00;
        end

        // SW
        6'b101011:
        begin
            ALUSrc   = 1;
            MemWrite = 1;
            ALUOp    = 2'b00;
        end

        // BEQ
        6'b000100:
        begin
            Branch = 1;
            ALUOp  = 2'b01;
        end

        // J
        6'b000010:
        begin
            Jump = 1;
        end

    endcase

end

endmodule
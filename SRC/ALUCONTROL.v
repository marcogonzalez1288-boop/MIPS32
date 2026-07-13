module ALUCONTROL(
    input [1:0] ALUOp,
    input [5:0] FNC,
    input [5:0] OPCode,

    output reg [3:0] ALC
);

always @(*)
begin

    case(ALUOp)

        // ADD
        2'b00:
            ALC = 4'b0010;

        // SUB (BEQ)
        2'b01:
            ALC = 4'b0110;

        // R-Type
        2'b10:
        begin

            case(FNC)

                6'b100000: ALC = 4'b0010; // ADD
                6'b100010: ALC = 4'b0110; // SUB
                6'b100100: ALC = 4'b0000; // AND
                6'b100101: ALC = 4'b0001; // OR
                6'b101010: ALC = 4'b0111; // SLT

                default:   ALC = 4'b1111;

            endcase

        end

        // I-Type especiales
        2'b11:
        begin

            case(OPCode)

                6'b001100: ALC = 4'b0000; // ANDI
                6'b001101: ALC = 4'b0001; // ORI
                6'b001010: ALC = 4'b0111; // SLTI

                default:   ALC = 4'b0010;

            endcase

        end

        default:
            ALC = 4'b1111;

    endcase

end

endmodule
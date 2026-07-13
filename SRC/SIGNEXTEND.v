// Extensor de signo: Instruction[15-0] (16 bits) -> 32 bits
module SIGNEXTEND (
    input  [15:0] in,
    output [31:0] out
);

    assign out = {{16{in[15]}}, in};

endmodule

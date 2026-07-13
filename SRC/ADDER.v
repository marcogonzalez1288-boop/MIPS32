// Sumador generico (se instancia para PC+4 y para el "Add" del branch)
module ADDER #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);

    assign y = a + b;

endmodule

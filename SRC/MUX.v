module MUX
#(
    parameter DATA_WIDTH = 5 
)
(
    input sel,
    input [DATA_WIDTH-1:0] e1, 
    input [DATA_WIDTH-1:0] e2, 
    output [DATA_WIDTH-1:0] s  
);

// Asignación continua: Si sel es 1, la salida 's' toma el valor de 'e1'. 
// Si sel es 0, toma el valor de 'e2'.
assign s = sel ? e1 : e2;

endmodule
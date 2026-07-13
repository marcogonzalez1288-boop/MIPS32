module PC (
    input clk,
    input rst,
    input [31:0] i_dir,       // Entrada (PC_IN)
    output reg [31:0] o_dir   // Salida (PC_OUT)
);

// Forzamos un valor inicial limpio para la simulación antes del primer ciclo
initial begin
    o_dir = 32'd0;
end

always @(posedge clk) begin
    if (rst) begin
        o_dir <= 32'd0;       // Si el reset está en 1 al llegar el reloj, se limpia a 0
    end else begin
        // Protección extra: Si la entrada es inválida (puras X), mantenemos el PC actual
        if (i_dir === 32'hxxxxxxxx) begin
            o_dir <= o_dir;
        end else begin
            o_dir <= i_dir;   // Flujo normal del pipeline
        end
    end
end

endmodule
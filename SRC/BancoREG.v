module BancoREG(
    input clk,
    input EW,
    input [4:0] AR1,
    input [4:0] AR2,
    input [4:0] AW,
    input [31:0] DW,

    output reg [31:0] DR1,
    output reg [31:0] DR2
);

// MEMORIA DE REGISTROS
reg [31:0] banco [0:31];

// INICIALIZACIÓN
initial
begin
    $readmemb("E:/UNIVERSIDAD CUCEI/VERANO 2026/Arquitectura/ProyectoFinal/SRC/Banco.txt",banco);
end

// LECTURA COMBINACIONAL CORREGIDA
always @(*)
begin
    // Leer Registro 1: Protege el registro 0 y hace bypass si WB escribe en el mismo ciclo
    if (AR1 == 5'd0) 
        DR1 = 32'd0; 
    else if ((AR1 == AW) && EW) 
        DR1 = DW;    
    else 
        DR1 = banco[AR1];

    // Leer Registro 2: Protege el registro 0 y hace bypass si WB escribe en el mismo ciclo
    if (AR2 == 5'd0) 
        DR2 = 32'd0; 
    else if ((AR2 == AW) && EW) 
        DR2 = DW;    
    else 
        DR2 = banco[AR2];
end

endmodule
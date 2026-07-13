module ARAM(
    input clk,

    input [31:0] Dir,
    input WE,
    input RE,

    input [31:0] DatoE,

    output reg [31:0] DatoS
);

reg [31:0] MeM [0:255];
integer i;

// Un solo bloque de Inicialización
initial
begin
    // 1. Primero limpiamos toda la memoria poniendo ceros
    for(i=0;i<256;i=i+1)
        MeM[i] = 32'd0;

    // 2. LUEGO cargamos el archivo (para que sobreescriba los ceros iniciales)
    $readmemb(
        "E:/UNIVERSIDAD CUCEI/VERANO 2026/Arquitectura/ProyectoFinal/SRC/Memoria.txt",
        MeM
    );
end

// Escritura
always @(posedge clk)
begin
    if(WE)
        MeM[Dir[9:2]] <= DatoE; 
end

// Lectura
always @(*)
begin
    if(RE)
        DatoS = MeM[Dir[9:2]]; 
    else
        DatoS = 32'd0;
end

endmodule
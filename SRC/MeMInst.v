module MeMInst(
    input [31:0] Dir,
    output reg [31:0] DatoS
);

// Memoria de instrucciones
reg [31:0] MeM [0:255];

// Inicialización
initial
begin
    $readmemb(
        "E:/UNIVERSIDAD CUCEI/VERANO 2026/Arquitectura/ProyectoFinal/Instrucciones.txt",
        MeM
    );
end

always @(*)
begin
    DatoS = MeM[Dir[9:2]];
end

endmodule
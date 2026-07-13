`timescale 1ns/1ps

module MIPS();

reg clk;

// =========================================================
// CABLES: ETAPA 1 - IF (Instruction Fetch)
// =========================================================
wire [31:0] PC_IN;
wire [31:0] PC_OUT;
wire [31:0] PC_PLUS4;
wire [31:0] INSTR_IF;

// --- NUEVO: Cables para los MUX de salto ---
wire [31:0] PC_NEXT_NO_JUMP; 
wire PCSrc; // Señal final que decide si el BEQ se toma o no

// =========================================================
// CABLES: ETAPA 2 - ID (Instruction Decode)
// =========================================================
wire [31:0] PC4_ID;
wire [31:0] INSTR_ID;
wire [31:0] RD1_ID, RD2_ID;
wire [31:0] SIGN_EXT_ID;

wire RegDst_ID, Branch_ID, MemRead_ID, MemWrite_ID;
wire ALUSrc_ID, RegWrite_ID, MemToReg_ID, Jump_ID;
wire [1:0] ALUOp_ID;

// --- NUEVO: Cable para la dirección de Jump absoluta ---
wire [31:0] JUMP_TARGET; 

// =========================================================
// CABLES: ETAPA 3 - EX (Execute)
// =========================================================
wire RegDst_EX, ALUSrc_EX, MemRead_EX, MemWrite_EX;
wire RegWrite_EX, MemToReg_EX;
wire Branch_EX; // --- NUEVO: Branch en etapa EX ---

wire [1:0] ALUOp_EX;
wire [31:0] PC4_EX, RD1_EX, RD2_EX, SIGN_EXT_EX;
wire [4:0] rs_EX, rt_EX, rd_EX;
wire [5:0] funct_EX;
wire [5:0] opcode_EX; 

wire [4:0] WRITE_REG_EX;
wire [31:0] ALU_B;
wire [3:0] ALUCTRL;
wire [31:0] ALU_RESULT_EX;
wire ZERO_EX;

// --- NUEVO: Cables para calcular la dirección del Branch ---
wire [31:0] SHIFTED_OFFSET;
wire [31:0] BRANCH_TARGET_EX;

// =========================================================
// CABLES: ETAPA 4 - MEM (Memory Access)
// =========================================================
wire MemRead_MEM, MemWrite_MEM, RegWrite_MEM, MemToReg_MEM;
wire Branch_MEM; // --- NUEVO: Branch en etapa MEM ---
wire Zero_MEM;   // --- NUEVO: Zero flag en etapa MEM ---

wire [31:0] ALU_RESULT_MEM;
wire [31:0] RD2_MEM;
wire [4:0] WRITE_REG_MEM;
wire [31:0] READ_DATA_MEM;
wire [31:0] BRANCH_TARGET_MEM; // --- NUEVO: Dirección final del Branch ---

// =========================================================
// CABLES: ETAPA 5 - WB (Write Back)
// =========================================================
wire RegWrite_WB, MemToReg_WB;
wire [31:0] READ_DATA_WB;
wire [31:0] ALU_RESULT_WB;
wire [4:0] WRITE_REG_WB;

wire [31:0] RESULT_WB; 

// =========================================================
// INSTANCIAS DEL PIPELINE
// =========================================================

// ---------------- ETAPA IF ----------------

// --- NUEVO: MUX para decidir entre PC+4 o el Salto del BEQ ---
MUX #(.DATA_WIDTH(32)) U_MUX_BRANCH (
    .sel(PCSrc), 
    .e1(BRANCH_TARGET_MEM), // sel=1 (Toma el salto BEQ)
    .e2(PC_PLUS4),          // sel=0 (Flujo normal)
    .s(PC_NEXT_NO_JUMP)
);

// --- NUEVO: MUX para decidir si hay un salto absoluto J ---
MUX #(.DATA_WIDTH(32)) U_MUX_JUMP (
    .sel(Jump_ID),
    .e1(JUMP_TARGET),       // sel=1 (Toma el salto J)
    .e2(PC_NEXT_NO_JUMP),   // sel=0 (Flujo de la decisión anterior)
    .s(PC_IN)
);

PC U_PC (
    .clk(clk),
    .i_dir(PC_IN),
    .o_dir(PC_OUT)
);

ADDER #(.WIDTH(32)) U_ADDER_PC4 (
    .a(PC_OUT),
    .b(32'd4),
    .y(PC_PLUS4)
);

MeMInst U_IMEM (
    .Dir(PC_OUT), 
    .DatoS(INSTR_IF)
);

IF_ID U_BUF_IF_ID (
    .clk(clk),
    .PC4_in(PC_PLUS4),
    .Instr_in(INSTR_IF),
    .PC4_out(PC4_ID),
    .Instr_out(INSTR_ID)
);

// ---------------- ETAPA ID ----------------

// --- NUEVO: Cálculo de la dirección absoluta del Jump ---
// (Los 4 bits más significativos de PC+4 concatenados con el Inmediato recorrido 2 bits)
assign JUMP_TARGET = {PC4_ID[31:28], INSTR_ID[25:0], 2'b00};

CONTROL U_CTRL (
    .OPCode(INSTR_ID[31:26]),
    .RegDst(RegDst_ID),
    .Branch(Branch_ID),
    .MemRead(MemRead_ID),
    .ALUOp(ALUOp_ID),
    .MemWrite(MemWrite_ID),
    .ALUSrc(ALUSrc_ID),
    .RegWrite(RegWrite_ID),
    .MemToReg(MemToReg_ID),
    .Jump(Jump_ID)
);

BancoREG U_REGS (
    .clk(clk),
    .EW(RegWrite_WB),        
    .AR1(INSTR_ID[25:21]),
    .AR2(INSTR_ID[20:16]),
    .AW(WRITE_REG_WB),       
    .DW(RESULT_WB),          
    .DR1(RD1_ID),
    .DR2(RD2_ID)
);

SIGNEXTEND U_SIGNEXT (
    .in(INSTR_ID[15:0]),
    .out(SIGN_EXT_ID)
);

ID_EX U_BUF_ID_EX (
    .clk(clk),
    .opcode_in(INSTR_ID[31:26]),
    .opcode_out(opcode_EX),
    
    // Control in/out
    .RegDst_in(RegDst_ID),      .RegDst_out(RegDst_EX),
    .ALUSrc_in(ALUSrc_ID),      .ALUSrc_out(ALUSrc_EX),
    .ALUOp_in(ALUOp_ID),        .ALUOp_out(ALUOp_EX),
    .MemRead_in(MemRead_ID),    .MemRead_out(MemRead_EX),
    .MemWrite_in(MemWrite_ID),  .MemWrite_out(MemWrite_EX),
    .RegWrite_in(RegWrite_ID),  .RegWrite_out(RegWrite_EX),
    .MemToReg_in(MemToReg_ID),  .MemToReg_out(MemToReg_EX),
    .Branch_in(Branch_ID),      .Branch_out(Branch_EX),      // --- NUEVO ---
    
    // Datos in/out
    .PC4_in(PC4_ID),            .PC4_out(PC4_EX),
    .RD1_in(RD1_ID),            .RD1_out(RD1_EX),
    .RD2_in(RD2_ID),            .RD2_out(RD2_EX),
    .SignExt_in(SIGN_EXT_ID),   .SignExt_out(SIGN_EXT_EX),
    .rs_in(INSTR_ID[25:21]),    .rs_out(rs_EX),
    .rt_in(INSTR_ID[20:16]),    .rt_out(rt_EX),
    .rd_in(INSTR_ID[15:11]),    .rd_out(rd_EX),
    .funct_in(INSTR_ID[5:0]),   .funct_out(funct_EX)
);

// ---------------- ETAPA EX ----------------

// --- NUEVO: Desplazar a la izquierda 2 bits (Shift Left 2) para el Branch ---
assign SHIFTED_OFFSET = {SIGN_EXT_EX[29:0], 2'b00};

// --- NUEVO: Sumador que calcula la dirección destino del BEQ ---
ADDER #(.WIDTH(32)) U_ADDER_BRANCH (
    .a(PC4_EX),
    .b(SHIFTED_OFFSET),
    .y(BRANCH_TARGET_EX)
);

MUX #(.DATA_WIDTH(5)) U_MUX_REGDST (
    .sel(RegDst_EX),
    .e1(rd_EX), 
    .e2(rt_EX), 
    .s(WRITE_REG_EX)
);

MUX #(.DATA_WIDTH(32)) U_MUX_ALUSRC (
    .sel(ALUSrc_EX),
    .e1(SIGN_EXT_EX), 
    .e2(RD2_EX),      
    .s(ALU_B)
);

ALUCONTROL U_ALUCTRL (
    .ALUOp(ALUOp_EX),
    .FNC(funct_EX),
    .OPCode(opcode_EX),
    .ALC(ALUCTRL)
);

ALU U_ALU (
    .ALUctl(ALUCTRL),
    .A(RD1_EX),
    .B(ALU_B),
    .ALUOut(ALU_RESULT_EX),
    .Zero(ZERO_EX)
);

EX_MEM U_BUF_EX_MEM (
    .clk(clk),
    // Control in/out
    .MemRead_in(MemRead_EX),     .MemRead_out(MemRead_MEM),
    .MemWrite_in(MemWrite_EX),   .MemWrite_out(MemWrite_MEM),
    .RegWrite_in(RegWrite_EX),   .RegWrite_out(RegWrite_MEM),
    .MemToReg_in(MemToReg_EX),   .MemToReg_out(MemToReg_MEM),
    .Branch_in(Branch_EX),       .Branch_out(Branch_MEM),           // --- NUEVO ---
    
    // Datos in/out
    .ALUResult_in(ALU_RESULT_EX),       .ALUResult_out(ALU_RESULT_MEM),
    .RD2_in(RD2_EX),                    .RD2_out(RD2_MEM),
    .WriteReg_in(WRITE_REG_EX),         .WriteReg_out(WRITE_REG_MEM),
    .Zero_in(ZERO_EX),                  .Zero_out(Zero_MEM),               // --- NUEVO ---
    .BranchTarget_in(BRANCH_TARGET_EX), .BranchTarget_out(BRANCH_TARGET_MEM) // --- NUEVO ---
);

// ---------------- ETAPA MEM ----------------

// --- NUEVO: Compuerta AND para decidir si se toma el Branch ---
// (Si es instrucción BEQ y los valores en la ALU fueron iguales)
assign PCSrc = Branch_MEM & Zero_MEM;

ARAM U_DMEM (
    .clk(clk),
    .Dir(ALU_RESULT_MEM), 
    .WE(MemWrite_MEM),
    .RE(MemRead_MEM),
    .DatoE(RD2_MEM),
    .DatoS(READ_DATA_MEM)
);

MEM_WB U_BUF_MEM_WB (
    .clk(clk),
    // Control in/out
    .RegWrite_in(RegWrite_MEM),   .RegWrite_out(RegWrite_WB),
    .MemToReg_in(MemToReg_MEM),   .MemToReg_out(MemToReg_WB),
    
    // Datos in/out
    .MemData_in(READ_DATA_MEM),   .MemData_out(READ_DATA_WB),
    .ALUResult_in(ALU_RESULT_MEM),.ALUResult_out(ALU_RESULT_WB),
    .WriteReg_in(WRITE_REG_MEM),  .WriteReg_out(WRITE_REG_WB)
);

// ---------------- ETAPA WB ----------------

MUX #(.DATA_WIDTH(32)) U_MUX_MEMTOREG (
    .sel(MemToReg_WB),
    .e1(READ_DATA_WB),  
    .e2(ALU_RESULT_WB), 
    .s(RESULT_WB)
);

// =========================================================
// CONTROL DE RELOJ Y SIMULACIÓN
// =========================================================

initial begin
    clk = 1'b0;
end

always #10 clk = ~clk; // Periodo de 20ns

initial begin
    // Se aumentó el tiempo a 2000ns para asegurar que tu ciclo termine de procesar 
    // los 5 elementos del arreglo y guarde los valores en ARAM.
    #2000; 
    $finish;
end

endmodule
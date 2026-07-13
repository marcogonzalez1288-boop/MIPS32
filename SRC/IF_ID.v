module IF_ID(
    input clk,

    input [31:0] PC4_in,
    input [31:0] Instr_in,

    output reg [31:0] PC4_out,
    output reg [31:0] Instr_out
);

always @(posedge clk)
begin
    PC4_out   <= PC4_in;
    Instr_out <= Instr_in;
end

endmodule
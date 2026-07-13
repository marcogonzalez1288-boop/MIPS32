module PC (
    input clk,
    input [31:0] i_dir,
    output reg [31:0] o_dir
);

initial
begin
    o_dir = 32'd0;
end

always @(posedge clk)
begin
    o_dir <= i_dir;
end

endmodule
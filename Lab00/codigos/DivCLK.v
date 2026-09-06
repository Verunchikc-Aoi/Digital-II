module DivCLK (
    input OCLK,
    input reset,
    output reg CLK
);
    reg [0:20] contador;

    always @(posedge OCLK, posedge reset) begin
        if (reset) begin
            contador <= 21'b0;
            CLK   <= 1'b0;
        end
        else if (contador == 21'b010011000100101101000) begin
            contador <= 21'b0;
            CLK   <= ~CLK;
        end
        else begin
            contador <= contador + 1;
        end
    end
endmodule

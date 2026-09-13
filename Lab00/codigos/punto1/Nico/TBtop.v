`timescale 1ns/1ps

module TBtop;
    reg CLK = 0;
    reg reset = 0;

    wire Verde;
    wire Amarillo;
    wire Rojo;
    
    Top uut (
        .CLK     (CLK),
        .reset   (reset),
        .Verde   (Verde),
        .Amarillo(Amarillo),
        .Rojo    (Rojo)
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin
        $dumpfile("TBtop.vcd");
        $dumpvars(0, TBtop);

        #5;
        reset = 1'b1;

        #5;
        reset = 0;

        #500;
        reset = 1'b1;

        #5
        reset = 0;

        #500;

        $finish;
    end
endmodule

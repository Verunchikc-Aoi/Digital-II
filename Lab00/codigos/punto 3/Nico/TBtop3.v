`timescale 1ns/1ps

module TBtop3;
    reg CLK = 0;
    reg reset = 0;
    reg start = 0;
    reg [7:0] data = 0;

    wire tx;
    wire busy;
    wire done;

    Top3 uut (
        .CLK  (CLK),
        .reset(reset),
        .start(start),
        .data (data),
        .tx   (tx),
        .busy (busy),
        .done (done)
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin
        $dumpfile("Ejer3/TBtop3.vcd");
        $dumpvars(0, TBtop3);

        #5;
        reset = 1'b1;

        #5;
        reset = 1'b0;

        #15;
        data = 8'hA5;

        #5;
        start = 1'b1;

        #10;
        start = 1'b0;

        #750;
        data = 8'h3C;

        #5;
        start = 1'b1;

        #10;
        start = 1'b0;
        
        #750;
        reset = 1;

        #10;
        reset = 0;

        #50;

        $finish;
    end
endmodule

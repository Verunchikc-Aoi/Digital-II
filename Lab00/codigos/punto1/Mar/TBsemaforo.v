`timescale 1ns/1ps

module TBsemaforo;
    reg clk = 0;
    reg rst = 0;

    wire green;
    wire yellow;
    wire red;
    
    semaforo uut (
        .clk     (clk),
        .rst   (rst),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("TBsemaforo.vcd");
        $dumpvars(0, TBsemaforo);

        #5;
        rst = 1'b1;

        #5;
        rst = 0;

        #500;
        rst = 1'b1;

        #5
        rst = 0;

        #500;

        $finish;
    end
endmodule

`timescale 1ns/1ps

module TBTrasA;
    reg CLK = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] data_in = 8'b0;
    wire busy;
    wire done;
    wire tx;

    
    TrasA uut (
        .CLK     (CLK),
        .rst   (rst),
        .start   (start),
        .data_in (data_in),
        .busy    (busy),
        .done    (done),
        .tx      (tx)
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin

        $dumpfile("TBTrasA.vcd");
        $dumpvars(0, TBTrasA);

        // Monitoreo en consola
        $monitor("t=%0t ns | rst=%b | start=%b | data_in=%h | busy=%b | tx=%b | done=%b",
                 $time, rst, start, data_in, busy, tx, done);

        CLK     = 1'b0;
        rst     = 1'b1;
        start   = 1'b0;
        data_in = 8'b0;

        repeat (2) @(negedge CLK);
        rst = 1'b0;
        @(negedge CLK);

        // primera transmisión (0x05)
        data_in = 8'hA5;
        start   = 1'b1;
        @(negedge CLK);
        start   = 1'b0;

        wait(done); // Espera a que termine
        repeat (5) @(negedge CLK);

        // segunda transmisión (0xA3)
        rst     = 1'b1;
        data_in = 8'h3C;
        repeat (2) @(negedge CLK); 
        rst     = 1'b0;
        @(negedge CLK);

        start   = 1'b1;
        @(negedge CLK);
        start   = 1'b0;
        repeat (15) @(negedge CLK);

        
        rst = 1'b1; // Interrupción de la transmisión
        repeat (3) @(negedge CLK); 
        rst = 1'b0;               

        repeat (10) @(negedge CLK);
        $finish;
    end
endmodule

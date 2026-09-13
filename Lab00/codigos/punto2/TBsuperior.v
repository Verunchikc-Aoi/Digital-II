`timescale 1ns/1ns

module TBsuperior;
    reg CLK = 0;
    reg reset = 0;
    reg start = 0;
    reg [3:0] x = 0;
    reg parar = 0;
    reg [1:0] operacion = 0;

    wire [5:0] acumulado;
    wire done;

    Superior uut (
        .CLK      (CLK),
        .reset    (reset),
        .start    (start),
        .x        (x),
        .parar    (parar),
        .operacion(operacion),
        .acumulado(acumulado),
        .done     (done)
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin
        $dumpfile("TBsuperior.vcd");
        $dumpvars(0, TBsuperior);

        // Monitoreo de variables en consola
        $monitor("start=%b | t=%0t ns | reset=%b parar=%b x=%d | acumulado=%d | done=%b",
                 start, $time, reset, parar, x, acumulado, done);

    //Valor inicial
        reset     = 1'b1;
        start     = 1'b0;
        parar     = 1'b0;
        x         = 4'd0;
        operacion = 2'd0;

        repeat (2) @(negedge CLK); //2 ciclos de reloj
        reset = 1'b0;
        @(negedge CLK);

        // x = 5
        x     = 4'd5;
        start = 1'b1;
        @(negedge CLK);  // "@(negedge CLK)" cambia la señal
        start = 1'b0;

        repeat (5) @(negedge CLK); // Espera a que complete la suma y marque done

        reset = 1'b1;
        x     = 4'd3;
        repeat (2) @(negedge CLK); // Corrección: Sincronizado con reloj (sin usar #10)
        reset = 1'b0;
        @(negedge CLK);

        operacion = 2'd1;  // Segunda operación

        start     = 1'b1;
        @(negedge CLK);
        start     = 1'b0;

        @(negedge CLK); // 1 solo ciclo de reloj para que haga la suma y luego se presiona stop

       
        parar = 1'b1;
        @(negedge CLK);  // Parar durante 1 ciclo completo de reloj
        parar = 1'b0; // Deberá marcar done y mantener el valor de la suma en la salida

        // Esperar al done de la operación 2 antes de iniciar la operación 3
        wait(done);
        @(negedge CLK);

        //Tercera operación
        operacion = 2'd2;
        start     = 1'b1;
        @(negedge CLK);
        start     = 1'b0;

        // Finalizar simulación
        repeat (10) @(negedge CLK);

        $finish;
    end
endmodule

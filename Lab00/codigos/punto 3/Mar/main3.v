`timescale 1ns / 1ps

module tb_serial_tx;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    
    wire tx;
    wire busy;
    wire done;

    // Instancia del módulo
    serial_tx #(
        .CLKS_PER_BIT(8) // Usamos 8 ciclos por bit para la simulación
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    // Generador de reloj (Periodo de 10ns)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Configuración para GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_serial_tx);

        // Inicialización y Reset
        rst = 1;
        start = 0;
        data_in = 8'h00;
        #20;
        rst = 0;
        #20;

        // ---- Transmisión 1: 8'hA5 (10100101) ----
        // Al enviar LSB primero, tx debería mostrar: 1, 0, 1, 0, 0, 1, 0, 1
        data_in = 8'hA5;
        start = 1;      // Pulso de 1 ciclo
        #10 start = 0;
        
        // Espera a que termine la transmisión
        wait(done == 1);
        #40;

        // ---- Transmisión 2: 8'h3C (00111100) ----
        // LSB primero: 0, 0, 1, 1, 1, 1, 0, 0
        data_in = 8'h3C;
        start = 1;
        #10 start = 0;

        wait(done == 1);
        #40;

        $display("Simulación completada con éxito.");
        $finish;
    end
endmodule
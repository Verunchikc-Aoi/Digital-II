`timescale 1ns/1ps

module TBALU2;
    // Entradas al módulo (reg para controlarlas en el initial)
    reg clk = 0;
    reg [3:0] sw = 0;
    reg [3:0] btn = 0;

    // Salidas del módulo (wire para leer la respuesta)
    wire [3:0] led;
    wire [2:0] rgb;

    // Instanciación de la ALU (UUT)
    ALU2 uut (
        .clk (clk),
        .sw  (sw),
        .btn (btn),
        .led (led),
        .rgb (rgb)
    );

    // Generador de reloj: período de 10ns (50MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("TBALU2.vcd");
        $dumpvars(0, TBALU2);

        // Inicialización
        sw  = 4'b0000;
        btn = 4'b0000;
        #10;

        // Operandos
        // Cargar A = 3
        sw = 4'b0011;
        btn = 4'b0001; // btn[0]
        #10;
        btn = 4'b0000;
        #10;

        // Cargar B = 5
        sw = 4'b0101;
        btn = 4'b0010; // btn[1]
        #10;
        btn = 4'b0000;
        #10; // Estado 4
        
        // MODO 00 (Suma: 3 + 5 = 8)
        #20;

        // MODO 01 (Resta: 3 - 5 = E)
        btn = 4'b0100; // Activa btn[2]
        #10;
        btn = 4'b0000;
        #20;

        // MODO 11 (OR: 3 OR 5 = 7)
        // Correccion de error: Se presiona btn[3] inmediatamente en la misma ventana de tiempo
        btn = 4'b1000; // Activa btn[3]
        #10;
        btn = 4'b0000;
        #20;
        // --- 4. MODO 10 (AND) ---
        // Pulsar btn[2] para conmutar modo[0] de 1 a 0 (11 -> 10)
        btn = 4'b0100; // Activa btn[2]
        #10;
        btn = 4'b0000;
        #20;

        $finish;
        $finish;
    end
endmodule
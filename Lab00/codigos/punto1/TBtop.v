`timescale 1ns/1ps   // Unidad de tiempo = 1ns, precision = 1ps
 
module TBtop;
    // CLK y reset son 'reg' porque el testbench los controla "a mano", en un testbench, las entradas del DUT (Device Under Test) siempre deben declararse como reg
    reg CLK = 0;
    reg reset = 0;

    wire Verde;
    wire Amarillo;
    wire Rojo;
 
    // Instancia del modulo a probar (DUT), conectando cada puerto

    Top uut (
        .CLK     (CLK),
        .reset   (reset),
        .Verde   (Verde),
        .Amarillo(Amarillo),
        .Rojo    (Rojo)
    );
 
    // Generador de reloj: invierte CLK cada 5ns -> periodo de 10ns (frecuencia de 100 MHz en la escala de tiempo definida arriba).
    always begin
        #5 CLK = ~CLK;
    end
 
    // Secuencia de estimulos de la simulacion.
    initial begin
        // Configura el volcado de señales para poder verlas despues en un visor de ondas
        $dumpfile("TBtop.vcd");   // archivo de salida
        $dumpvars(0, TBtop);      // graba todas las señales de este modulo (nivel 0 = recursivo)
 
        // --- Primer ciclo de reset ---
        #5;
        reset = 1'b1;   // activa reset
 
        #5;
        reset = 0;      // libera reset, la FSM empieza a correr
 
        // Deja correr la FSM libremente 500ns para observar su comportamiento normal (cambios de estado del semaforo)
        #500;
 
        // --- Segundo ciclo de reset (prueba que se puede resetear
        //     de nuevo en cualquier momento, no solo al inicio) ---
        reset = 1'b1;
 
        #5
        reset = 0;
 
        // Deja correr otros 500ns tras el segundo reset
        #500;
 
        $finish;   // termina la simulacion
    end
endmodule

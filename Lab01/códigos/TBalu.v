`timescale 1ns / 1ps

module TBalu;

    reg        CLK;
    reg  [3:0] SW;
    reg  [5:0] BTN;
    wire [3:0] LED;
    wire       LED_R, LED_G, LED_B;

    // Instancia del módulo con T3S acelerado para simulación (10 ciclos = 100 ns por ventana)
    alu #(.T3S(10)) uut (
        .CLK(CLK),
        .SW(SW),
        .BTN(BTN),
        .LED(LED),
        .LED_R(LED_R),
        .LED_G(LED_G),
        .LED_B(LED_B)
    );

    // Generador de reloj (Periodo = 10 ns)
    always #5 CLK = ~CLK;

    initial begin
        // ---------- ARCHIVO DE ONDAS VCD ----------
        $dumpfile("TBalu.vcd");
        $dumpvars(0, TBalu);

        // Inicialización
        CLK = 0;
        SW  = 4'b0101; // A = 5
        BTN = 6'b0000;

        #20;
        // -------------------------------------------------------------------
        // 1. Pulso en BTN[3] -> B[3]=1 (Avanza a slot 1) [t = 20 ns]
        // -------------------------------------------------------------------
        BTN = 6'b001000; 
        #20;
        BTN = 6'b000000;

        // La FSM recorre automáticamente por timeout (100 ns cada uno):
        // slot 1 (B[2]) : t = 40ns  -> 140ns
        // slot 2 (B[1]) : t = 140ns -> 240ns
        // slot 3 (B[0]) : t = 240ns -> 340ns
        //
        // A los 340ns la FSM entra a slot 4 (espera op[1] mediante BTN[4])
        #310; // Avanzamos hasta t = 350 ns (dentro de slot 4)

        // -------------------------------------------------------------------
        // 2. Pulso en BTN[4] -> op[1]=1 (Configura op = 2'b10) [t = 350 ns]
        // -------------------------------------------------------------------
        BTN = 6'b010000; // Presiona BTN[4] para op[1]
        #20;
        BTN = 6'b000000;

        // Al presionar BTN[4], la FSM guarda op[1]=1 y avanza a slot 5 (op[0]).
        // Dejamos pasar la ventana slot 5 (~100 ns) por timeout para que op[0]=0.
        #200;

        $finish;
    end

endmodule
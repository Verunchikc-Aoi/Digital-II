// ALU secuencial controlada por una FSM. Lee el operando A, captura B y op mediante botones, y muestra el resultado en LEDs.

module alu #(
    // T3S: Límite de conteo para la ventana de espera.
    // En simulación se usa un valor pequeño (10). En FPGA física para 3s a 100MHz se usa 300_000_000.
    parameter T3S = 400000000
)(
    input            CLK,   // Reloj
    input      [3:0] SW,    // Primer operando A (4 switches)
    input      [5:0] BTN,   // Entradas de botones (5:0)
    output reg [3:0] LED,   // Salida principal a LEDs de 4 bits
    output reg       LED_R, // Indicador para resultado en operación AND
    output reg       LED_G, // Indicador para resultado en operación OR
    output reg       LED_B  // Indicador para resultado en operación XOR
);

    // Sincronizador de Entradas y Detector de Flanco de Subida

    reg [5:0] s0 = 6'b0, s1 = 6'b0, s1_prev = 6'b0;

    always @(posedge CLK) begin
        s0      <= BTN;
        s1      <= s0;
        s1_prev <= s1;
    end

    wire [5:0] pulse = s1 & ~s1_prev; // Pulso de 1 ciclo en el flanco de subida
    wire       anyp  = |pulse;        // '1' lógico si se presionó cualquier botón

    // Declaración de Estados y Registros Internos

    localparam IDLE = 3'd7; // Estado de reposo e inicio

    reg [3:0]  A    = 4'b0; // Registro para almacenamiento del operando A
    reg [3:0]  B    = 4'b0; // Registro para almacenamiento del operando B
    reg [1:0]  op   = 2'b0; // Registro para código de operación
    reg [2:0]  slot = IDLE; // Estado actual de la FSM (3 bits)
    reg [28:0] c    = 29'd0;// Contador de tiempo para las ventanas de espera

    reg wp; // Mantiene el pulso del botón esperado según la ventana actual

    // Selección Combinacional del Botón Esperado por Estado

    always @(*) begin 
        case (slot)
            3'd0: wp = pulse[3]; // Espera pulso para B[3]
            3'd1: wp = pulse[2]; // Espera pulso para B[2]
            3'd2: wp = pulse[1]; // Espera pulso para B[1]
            3'd3: wp = pulse[0]; // Espera pulso para B[0]
            3'd4: wp = pulse[4]; // Espera pulso para op[1]
            3'd5: wp = pulse[5]; // Espera pulso para op[0]
            default: wp = 1'b0;
        endcase
    end

    // FSM

    always @(posedge CLK) begin
        case (slot)
            // Estado Reposo: Carga A desde los switches y espera la pulsación inicial
            IDLE: begin
                A    <= SW;
                B    <= 4'b0000;
                op   <= 2'b00;
                c    <= 29'd0;
                
                if (pulse[3]) begin
                    B[3] <= 1'b1; // ERROR SOLUCIONADO: Registra B[3]=1 si se presionó el botón correspondiente
                    slot <= 3'd1; // Transiciona inmediatamente a la ventana de B[2]
                end else if (anyp) begin
                    slot <= 3'd1; // Si fue otro botón, mantiene B[3]=0 y avanza
                end
            end

            // Ventana para la captura del bit B[2]
            3'd1: begin 
                if (pulse[2] || c == T3S-1) begin
                    if (pulse[2]) B[2] <= 1'b1;
                    slot <= 3'd2;
                    c    <= 29'd0;
                end else c <= c + 1;
            end

            // Ventana para la captura del bit B[1]
            3'd2: begin 
                if (pulse[1] || c == T3S-1) begin
                    if (pulse[1]) B[1] <= 1'b1;
                    slot <= 3'd3;
                    c    <= 29'd0;
                end else c <= c + 1;
            end

            // Ventana para la captura del bit B[0]
            3'd3: begin 
                if (pulse[0] || c == T3S-1) begin
                    if (pulse[0]) B[0] <= 1'b1;
                    slot <= 3'd4;
                    c    <= 29'd0;
                end else c <= c + 1;
            end

            // Ventana para la captura del bit op[0]
            3'd4: begin 
                if (pulse[4] || c == T3S-1) begin
                    if (pulse[4]) op[0] <= 1'b1;
                    slot <= 3'd5;
                    c    <= 29'd0;
                end else c <= c + 1;
            end

            // Ventana para la captura del bit op[1]
            3'd5: begin 
                if (pulse[5] || c == T3S-1) begin
                    if (pulse[5]) op[1] <= 1'b1;
                    slot <= 3'd6;
                    c    <= 29'd0;
                end else c <= c + 1;
            end

            // Estado de Resultado: Muestra el cálculo realizado hasta recibir un reinicio
            3'd6: begin 
                if (anyp) slot <= IDLE;
            end

            default: slot <= IDLE;
        endcase
    end

    // Lógica Combinacional de Operaciones Arithmetic/Logic

    wire [3:0] sum_result = A + B; // Suma aritmética de 4 bits
    wire [3:0] and_result = A & B; // Operación lógica AND bit a bit
    wire [3:0] or_result  = A | B; // Operación lógica OR bit a bit
    wire [3:0] xor_result = A ^ B; // Operación lógica XOR bit a bit

    // Decodificación y Mapeo de Salidas

    always @(*) begin
        // Valores por defecto (se limpian en cada evaluación del bloque combinacional)
        LED   = 4'b0000;
        LED_R = 1'b0;
        LED_G = 1'b0;
        LED_B = 1'b0;

        case (slot)
            IDLE:             LED = A;           // Muestra A en switches
            3'd1: begin
                LED = B;
                LED_B = 1'b1;
                LED_R = 1'b1;
            end
            3'd2: begin
                LED = B;
                LED_R = 1'b1;
                LED_G = 1'b1;
                
            end
            3'd3: begin
                LED = B;
                LED_G = 1'b1;
                LED_B = 1'b1;
            end

            // Ventanas de captura de operación: prende RGB en Blanco como aviso
            3'd4, 3'd5: begin
                LED   = {2'b00, op};
                LED_R = 1'b1;
                LED_G = 1'b1;
                LED_B = 1'b1;
            end
            // Ventanas de captura de operación: prende RGB en Blanco como aviso
            3'd4, 3'd5: begin
                LED   = {2'b00, op};
                LED_R = 1'b1;
                LED_G = 1'b1;
                LED_B = 1'b1;
            end

            // Estado de despliegue de resultado
            3'd6: begin
                case (op)
                    2'b00: begin
                        LED   = sum_result; // Suma
                    end
                    2'b01: begin
                        LED   = and_result;
                        LED_R = 1'b1;       // Solo Rojo
                    end
                    2'b10: begin
                        LED   = or_result;
                        LED_G = 1'b1;       // Solo Verde
                    end
                    2'b11: begin
                        LED   = xor_result;
                        LED_B = 1'b1;       // Solo Azul
                    end  
                endcase
            end

            default: ;
        endcase
    end

endmodule

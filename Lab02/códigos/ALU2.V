// Módulo ALU2: Unidad Aritmético Lógica de 4 bits controlada por una Máquina de Estados Finitos (FSM)
module ALU2 (
    input clk,          // Reloj del sistema
    input [3:0] sw,     // Interruptores de entrada (para ingresar operandos A y B)
    input [3:0] btn,    // Botones de control (transición de estados y cambio de modo)
    output reg [3:0] led, // Salida de LEDs (muestra switches o resultado de la operación)
    output reg [2:0] rgb  // Salida para LED RGB (indica la operación actual)
);
    // Registros internos de la máquina de estados y operandos
    reg [2:0] estado; // Estado actual de la FSM (0 a 5)
    reg [3:0] A;      // Registro para el primer operando
    reg [3:0] B;      // Registro para el segundo operando
    reg [1:0] modo;   // Selector de operación ALU (0: Suma, 1: Resta, 2: AND, 3: OR)

    // Lógica secuencial (FSM): Captura de operandos, cambio de modo y transición de estados
    always @(posedge clk) begin
        case (estado)
            // Estado 0: Espera la pulsación de btn[0] para capturar el operando A desde los switches
            3'd0: if (btn[0]) begin
                A <= sw;
                estado <= 3'd1;
            end
            
            // Estado 1: Anti-rebote/espera a que se libere btn[0]
            3'd1: if (!btn[0]) estado <= 3'd2;
            
            // Estado 2: Espera la pulsación de btn[1] para capturar el operando B desde los switches
            3'd2: if (btn[1]) begin
                B <= sw;
                estado <= 3'd3;
            end
            
            // Estado 3: Anti-rebote/espera a que se libere btn[1]
            3'd3: if (!btn[1]) estado <= 3'd4;
            
            // Estado 4: Modo de ejecución / Selección de operación
            // - Presionar btn[0] o btn[1] avanza al estado 5 para reiniciar el flujo.
            // - Presionar btn[2] conmuta el bit inferior de modo (modo[0]).
            // - Presionar btn[3] conmuta el bit superior de modo (modo[1]).
            3'd4: if (btn[0] | btn[1]) estado <= 3'd5;
                else if (btn[2]) modo[0] <= ~modo[0];
                else if (btn[3]) modo[1] <= ~modo[1];
            
            // Estado 5: Espera a que se liberen btn[0] y btn[1] para reiniciar la FSM al estado 0
            3'd5: if (!(btn[0] | btn[1])) estado <= 3'd0;
            
            // Estado por defecto: Reinicia las señales si ocurre un estado inválido
            default: begin
                estado <= 0;
                A <= 0;
                B <= 0;
                modo <= 0;
            end
        endcase
    end

    // Lógica combinacional: Salidas para los LEDs y el LED RGB según el estado y el modo
    always @(*) begin
        rgb = 0; // Valor por defecto del RGB
        case (estado)
            // En los estados 0 a 3, los LEDs reflejan directamente la posición actual de los switches
            3'd0, 3'd1, 3'd2, 3'd3: led = sw;
            
            // En los estados 4 y 5, los LEDs muestran el resultado de la ALU según 'modo'
            3'd4, 3'd5: begin
                case (modo)
                    2'd0: begin // Operación: Suma (A + B)
                        led = A+B;
                        rgb = 3'b010; // Color RGB para Suma
                    end
                    2'd1: begin // Operación: Resta (A - B)
                        led = A-B;
                        rgb = 3'b001; // Color RGB para Resta
                    end
                    2'd2: begin // Operación: AND bit a bit (A & B)
                        led = A&B;
                        rgb = 3'b100; // Color RGB para AND
                    end
                    2'd3: begin // Operación: OR bit a bit (A | B)
                        led = A|B;
                        rgb = 3'b111; // Color RGB para OR
                    end
                    default: begin
                        led = A+B;
                        rgb = 3'b010;
                    end 
                endcase
            end
            
            // Estado por defecto para la lógica combinacional de salida
            default: begin
                led = 0;
                rgb = 0;
            end
        endcase
    end
endmodule
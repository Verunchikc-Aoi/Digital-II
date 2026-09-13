// Módulo que controla al resto: Selector de Operación / Acumuladores
//Multiplexación/Demultiplexación de submódulos

module Superior (
    input  wire       CLK,        // Reloj 
    input  wire       reset,      // Reset global
    input  wire       start,      // Señal de inicio multiplexada
    input  wire [3:0] x,          // Valor de entrada de 4 bits
    input  wire       parar,      // Parada de emergencia
    input  wire [1:0] operacion,  // Selector de submódulo (0, 1, 2)

    output reg  [5:0] acumulado,  // Resultado acumulado multiplexado
    output reg        done        // Bandera de finalización multiplexada
);

    // Habilitación individual de inicio
    reg  [3:0] conection;

    // Buses internos para capturar las salidas de los submódulos
    wire [5:0] acumulado0, acumulado1, acumulado2;
    wire       done0, done1, done2;

    
    //Demux de 'start' y Mux de salidas
    
    always @(*) begin
        conection = 4'd0;        // Valor por defecto
        case (operacion)
            // Operación 0 (y 3 por omisión): Activa 'Acc3' (acumulador_secuencial)
            2'd0, 2'd3: begin
                conection[0] = start;
                acumulado    = acumulado0;
                done         = done0;
            end

            // Operación 1: Activa 'Acc4' (Top2A)
            2'd1: begin
                conection[1] = start;
                acumulado    = acumulado1;
                done         = done1;
            end

            // Operación 2: Activa 'Acc20' (Top2 - límite 20)
            2'd2: begin
                conection[2] = start;
                acumulado    = acumulado2;
                done         = done2;
            end

            // Estado por defecto de seguridad
            default: begin
                conection = 4'd0;
                acumulado = 6'd0;
                done      = 1'b0;
            end
        endcase
    end

    // submódulos instanciados

    // Submódulo 0: Suma fija de 3 iteraciones
    acumulador_secuencial Acc3 (
        .clk   (CLK),
        .rst   (reset),
        .start (conection[0]),
        .x     (x),
        .acc   (acumulado0),
        .done  (done0),
        .stop  (parar)
    );

    // Submódulo 1: Acumulador variante A
    Top2A Acc4 (
        .CLK   (CLK),
        .start (conection[1]),
        .reset (reset),
        .stop  (parar),
        .x     (x),
        .sum   (acumulado1),
        .done  (done1)
    );

    // Submódulo 2: Acumulador por tope (>= 20)
    Top2 Acc20 (
        .CLK       (CLK),
        .reset     (reset),
        .start     (conection[2]),
        .parar     (parar),
        .x         (x),
        .acumulado (acumulado2),
        .done      (done2)
    );

endmodule

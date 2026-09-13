
module Top2 (
    input  wire       CLK,        // Reloj
    input  wire       reset,      // Reset
    input  wire       start,      // Señal de inicio
    input  wire       parar,      // Parada de emergencia
    input  wire [3:0] x,          // Valor de entrada a acumular (4 bits)
    output reg  [5:0] acumulado,  // Salida del valor acumulado (6 bits)
    output reg        done        // Indicador finalización
);

    reg [1:0] estado;             // Estado
    wire [5:0] add;               // Extensión de ceros para el valor x (6 bits)

    // Extensión de ceros: convierte x (4 bits) a 6 bits para operar con 'acumulado'
    assign add = {2'd0, x};

    always @(posedge CLK or posedge reset) begin
        if (reset) begin
            estado    <= 2'd0;    // Regresa a IDLE (Estado 0)
            acumulado <= 6'd0;    // Limpia el acumulador
        end else begin
            case (estado)
                // Estado 0
                2'd0: begin
                    if (start & (x > 4'd0)) begin
                        acumulado <= 6'd0;  // Reinicia la suma
                        estado    <= 2'd1;  
                    end
                end

                // Estado 1: Ciclo de transición
                2'd1: begin
                    estado <= 2'd2;         
                end

                // Estado 2
                2'd2: begin
                    if (parar) begin
                        estado <= 2'd3;     // Señal 'parar'
                    end else if (acumulado >= 6'd20) begin
                        estado <= 2'd3;     // Se pasa (>= 20)
                    end else begin
                        acumulado <= acumulado + add; // Suma
                    end
                end

                // Estado 3 mantiene resultado y espera liberación de control
                2'd3: begin
                    if (!start & !parar) begin
                        estado <= 2'd0;     // Va a IDLE al soltar start/parar
                    end
                end

                // Cobertura para estados no contemplados
                default: begin
                    estado    <= 2'd0;
                    acumulado <= 6'd0;
                end
            endcase
        end
    end

    always @(*) begin
        case (estado)
            2'd3:    done = 1'b1;  
            default: done = 1'b0;  
        endcase
    end

endmodule

module Top2A (
    input  wire       CLK,        // Reloj
    input  wire       start,      // Boton de inicio
    input  wire       reset,      // Reset de sistema
    input  wire       stop,       // Boton de parada de emergencia (Abortar)
    input  wire [3:0] x,          // Número de entrada (4 bits)
    output reg  [5:0] sum,        // Salida suma (6 bits)
    output reg        done        // Señal de terminar
);

    reg [1:0] estado; 
    reg [5:0] acumulador;   // Registra la suma
    reg [1:0] cuenta;       // Contador de 0 a 3

    localparam IDL   = 2'd0; // Corrección: 'local Brigadier' a 'localparam', son los estados
    localparam SUMAR = 2'd1;
    localparam HOLD  = 2'd2;

    // Bloque Secuencial
    always @(posedge CLK or posedge reset) begin
        if (reset) begin // Si se presiona RESET, reinicia todo y va directo a IDL
            estado     <= IDL;
            acumulador <= 6'd0;
            cuenta     <= 2'd0;
            sum        <= 6'd0;
            done       <= 1'b0;
        end else begin
            case (estado)
                IDL: begin
                    done <= 1'b0;
                    if (start) begin  //Espera la señal de inicio para ir al estado SUMAR, limpia acumulador y contador
                        acumulador <= 6'd0;
                        cuenta     <= 2'd0;
                        sum        <= 6'd0;
                        estado     <= SUMAR;
                    end
                end

                SUMAR: begin 
                    if (stop) begin  //Correcciobn: Se agregó la condición de parada de emergencia, que congela el resultado y pone done en 1, de la otra forma daba una suma de más
                        // Parada de emergencia, detiene la suma y congela el resultado
                        sum    <= acumulador; // Guarda
                        done   <= 1'b1;       // Finaliza el proceso
                        estado <= HOLD;       // Va al estado HOLD
                    end else if (cuenta == 2'd3) begin // Sumo 4 veces
                        acumulador <= acumulador + x;
                        sum        <= acumulador + x; //No se especifica en el ejercicio que no se pueda mostrar lo que se va asumando, entonces se puso para ir viendo el valor de la suma en cada ciclo
                        done       <= 1'b1; // Finaliza el proceso
                        estado     <= HOLD;
                    end else begin
                        // Suma normal en progreso
                        acumulador <= acumulador + x;
                        sum        <= acumulador + x;
                        cuenta     <= cuenta + 2'd1;
                    end
                end

                HOLD: begin
                     // Mantiene la suma final en la salida hasta recibir RESET o un nuevo START
                    if (start) begin
                        done   <= 1'b0;
                        estado <= IDL;
                    end
                end

                default: estado <= IDL;
            endcase
        end
    end

endmodule
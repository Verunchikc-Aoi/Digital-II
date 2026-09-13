// Acumulador secuencial con FSM (Moore), sumar un numero x 3 veces (NUM_SUMAS = 3)

module acumulador_secuencial (
    input  wire       clk,     // Reloj
    input  wire       rst,     // Reset
    input  wire       start,   // Señal inicio
    input  wire [3:0] x,       // Valor x
    input  wire       stop,    // Parada de emergencia
    output reg  [5:0] acc,     // Acumulador
    output reg        done     // Señal de finalización
);

    // Estados
    localparam IDLE = 2'b00,
               LOAD = 2'b01,
               ADD  = 2'b10,
               DONE = 2'b11;

    localparam NUM_SUMAS = 3;   //Límite sumas

    reg [1:0] estado, sig_estado; 
    reg [1:0] contador;          

    // Registro de estado

    always @(posedge clk or posedge rst) begin
        if (rst)
            estado <= IDLE;       // Rst estado de reposo
        else
            estado <= sig_estado;
    end

    // Siguiente estado
    always @(*) begin
        case (estado)
            // Si está en reposo y recibe 'start', va a cargar datos; de lo contrario, se queda en IDLE
            IDLE: sig_estado = start ? LOAD : IDLE;

            // Pasa automáticamente a sumar tras inicializar los registros
            LOAD: sig_estado = ADD;

            // Evalúa si debe continuar sumando, terminar por límite o parar
            ADD: begin
                if (stop)
                    sig_estado = DONE; // Stop va a DONE
                else
                    // Si alcanzó la cantidad de sumas requerida va a DONE
                    sig_estado = (contador == NUM_SUMAS) ? DONE : ADD;
            end

            // Se mantiene en DONE hasta recibir un nuevo 'start' o un 'reset'
            DONE: sig_estado = start ? LOAD : DONE;

            default: sig_estado = IDLE;
        endcase
    end

    // Ruta de datos
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc      <= 6'd0;
            contador <= 2'd0;
            done     <= 1'b0;
        end else begin
            case (estado)
                IDLE: begin
                    done <= 1'b0; // Limpia
                end

                LOAD: begin
                    acc      <= 6'd0; // Reinicia
                    contador <= 2'd0; 
                    done     <= 1'b0;
                end

                ADD: begin
                    // Mientras no haya stop y no se supere la meta de sumas, acumula e incrementa
                    if (!stop && (contador < NUM_SUMAS)) begin
                        acc      <= acc + x;        
                        contador <= contador + 1'b1;
                    end
                end

                DONE: begin
                    done <= 1'b1; // Señal de finalización
                end
            endcase
        end
    end

endmodule
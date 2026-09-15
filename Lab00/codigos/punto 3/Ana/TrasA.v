// Transmisor Serial Síncrono

module TrasA #(
    parameter CLKS_PER_BIT = 8 // Número de ciclos de reloj por bit transmitido, valor fijo para la simulación, pero puede ser parametrizado para diferentes velocidades de transmisión
)(
    input  CLK,     // Reloj 
    input  rst,     // Reset 
    input  wire [7:0] data_in, // Dato en paralelo a transmitir (8 bits)
    input  wire       start,   // Señal para iniciar
    output reg        busy,    // Transmisión en progreso
    output reg        tx,      // Salida serial (bit actual transmitido)
    output reg        done     // Señal de finalización
);

    // Registros 
    reg [2:0] bit_count;                       // Cuenta los bits enviados (0 a 7)
    reg [1:0] estado;                          // Estado de la FSM (son 4)
    reg [$clog2(CLKS_PER_BIT)-1:0] tick_cnt;   // "Cronómetro" variable por bit, funciona con un logaritmo para determinar el tamaño del registro según CLKS_PER_BIT
    reg [7:0] shift_reg;                       // Registro de desplazamiento PISO

    // Estados
    localparam IDLE     = 2'd0; 
    localparam LOAD     = 2'd1; 
    localparam TRANSMIT = 2'd2; 
    localparam DONE     = 2'd3; 

    // Inicio
    always @(posedge CLK or posedge rst) begin
        if (rst) begin
            // Reset, valores por defecto
            estado    <= IDLE;
            bit_count <= 3'd0;
            tick_cnt  <= 0;
            tx        <= 1'b1; // Línea en alto (inactiva)
            busy      <= 1'b0;
            done      <= 1'b0;
            shift_reg <= 8'd0;
        end
        else begin
            case (estado)
                IDLE: begin
                    done <= 1'b0; // Limpia
                    tx   <= 1'b1; // Mantiene la línea serial en nivel alto (Idle)
                    busy <= 1'b0; // Indica que está libre
                    
                    if (start) begin
                        estado <= LOAD; // Inicia
                    end
                end

                LOAD: begin
                    estado    <= TRANSMIT;
                    bit_count <= 3'd0;         // Conteo de bits desde 0
                    tick_cnt  <= 0;            // Reinicia el contador de tiempo
                    shift_reg <= data_in;      // Carga paralela del byte
                    busy      <= 1'b1;         // Sistema ocupado
                    done      <= 1'b0;         // Limpia
                    tx        <= data_in[0];   // Expone el bit LSB inmediatamente
                end

                TRANSMIT: begin
                    tx <= shift_reg[bit_count]; // Utiliza bit_count como puntero

                    if (tick_cnt == CLKS_PER_BIT - 1) begin
                        tick_cnt <= 0;
                        
                        if (bit_count == 3'd7) begin
                            estado <= DONE;
                        end else begin
                            bit_count <= bit_count + 3'd1; // Solo se incrementa el puntero
                        end
                    end else begin
                        tick_cnt <= tick_cnt + 1'b1;
                    end  
                end

                DONE: begin
                    done   <= 1'b1; // Señal de listo 
                    busy   <= 1'b0; // 0 la señal de ocupado
                    tx     <= 1'b1; // Devuelve la línea a nivel alto
                    estado <= IDLE; // Va al reposo otra vez
                end

                default: begin
                    estado <= IDLE;
                end
            endcase
        end
    end

endmodule

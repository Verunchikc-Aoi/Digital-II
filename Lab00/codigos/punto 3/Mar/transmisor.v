
// Transmisor Serial 
module serial_tx #(
    parameter CLKS_PER_BIT = 8 
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy,
    output reg        done
);

    // Codificacion de los 5 estados
    localparam IDLE       = 3'd0,
               LOAD       = 3'd1,
               BIT_HOLD   = 3'd2,
               SHIFT_NEXT = 3'd3,
               DONE_ST    = 3'd4;

    reg [2:0] state, next_state;

    reg [7:0] shift_reg;
    reg [2:0] bit_count; 
    reg [$clog2(CLKS_PER_BIT)-1:0] tick_cnt;

    // FSM: Memoria de estado
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    //  FSM: Logica combinacional de proximo estado 
    always @(*) begin
        case (state)
            IDLE:       next_state = start ? LOAD : IDLE;
            LOAD:       next_state = BIT_HOLD;
            
            // Se queda en BIT_HOLD hasta que el tiempo del bit termine
            BIT_HOLD:   next_state = (tick_cnt == CLKS_PER_BIT - 1) ? SHIFT_NEXT : BIT_HOLD;
            
            // Decide si pasa al siguiente bit o si ya termino los 8
            SHIFT_NEXT: next_state = (bit_count == 3'd7) ? DONE_ST : BIT_HOLD;
            
            DONE_ST:    next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end

    // Datapath: Registros y temporizacion 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            shift_reg <= 8'd0;
            bit_count <= 3'd0;
            tick_cnt  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b0;
                end
                LOAD: begin
                    shift_reg <= data_in;
                    bit_count <= 3'd0;
                    tick_cnt  <= 0;
                    busy      <= 1'b1;
                    tx        <= 1'b1;
                    done      <= 1'b0;
                end
                BIT_HOLD: begin
                    tx   <= shift_reg[0]; // Mantiene la linea con el bit actual
                    busy <= 1'b1;
                    done <= 1'b0;
                    // Incrementa el temporizador si aun no termina
                    if (tick_cnt < CLKS_PER_BIT - 1) begin
                        tick_cnt <= tick_cnt + 1'b1;
                    end
                end
                SHIFT_NEXT: begin
                    busy <= 1'b1;
                    tick_cnt <= 0; // Reinicia el temporizador para el nuevo bit
                    if (bit_count < 3'd7) begin
                        shift_reg <= {1'b0, shift_reg[7:1]}; // Desplaza
                        bit_count <= bit_count + 1'b1;       // Cuenta el nuevo bit
                    end
                end
                DONE_ST: begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    tx   <= 1'b1; 
                end
            endcase
        end
    end
endmodule
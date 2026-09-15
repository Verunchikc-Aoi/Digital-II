module Top3 (
    input CLK,
    input reset,
    input start,

    input [7:0] data,

    output reg tx,
    output reg busy,
    output reg done
);
    parameter N = 8;
    parameter CLKS_PER_BIT = N;

    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    reg [$clog2(CLKS_PER_BIT)-1:0] tick_cnt;

    reg [1:0] estado;

    localparam IDLE = 2'd0;
    localparam LOAD = 2'd1;
    localparam TRANSMIT = 2'd2;
    localparam DONE = 2'd3;

    always @(posedge CLK, posedge reset) begin
        if (reset) begin
            busy <= 0;
            done <= 0;
            tx = 1;
            shift_reg <= 0;
            bit_count <= 0;
            tick_cnt <= 0;
            estado <= 0;
        end else begin
            case (estado)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    tx <= 1;
                    bit_count <= 0;
                    shift_reg <= 0;
                    tick_cnt <= 0;
                    if (start) estado <= LOAD;
                end
                LOAD: begin
                    busy <= 1;
                    done <= 0;
                    tx <= 1;
                    bit_count <= 0;
                    shift_reg <= data;
                    tick_cnt <= 0;
                    estado <= TRANSMIT;
                end
                TRANSMIT: begin
                    busy <= 1;
                    done <= 0;
                    tx <= shift_reg[0];
                    if (&tick_cnt) begin
                        if (bit_count == 3'd7) estado <= DONE;
                        else begin
                            bit_count <= bit_count + 3'd1;
                            tick_cnt <= 0;
                            shift_reg = shift_reg >> 1;
                        end
                    end else tick_cnt = tick_cnt + 3'd1;
                end
                DONE: begin
                    busy <= 0;
                    done <= 1;
                    tx <= 1;
                    bit_count <= bit_count;
                    shift_reg <= shift_reg;
                    tick_cnt <= tick_cnt;
                    estado <= IDLE;
                end
            default: begin 
                busy <= 0;
                done <= 0;
                tx <= 1;
                bit_count <= 0;
                shift_reg <= 0;
                tick_cnt <= 0;
                estado <= IDLE;
            end
            endcase
        end
    end
endmodule

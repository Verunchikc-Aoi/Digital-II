module debounce ( // ~10 ms a 125 MHz
    input  clk,
    input  btn_in,      // botón crudo
    output reg pulse    // 1 ciclo por cada pulsación
);
    parameter CNT_MAX = 1_250_000;
    reg s0 = 0, s1 = 0;          // sincronizador (2 flip-flops)
    reg stable = 0;              // valor filtrado
    reg [20:0] cnt = 0;

    always @(posedge clk) begin
        s0 <= btn_in;
        s1 <= s0;
        pulse <= 0;
        if (s1 == stable)
            cnt <= 0;
        else begin
            cnt <= cnt + 1;
            if (cnt == CNT_MAX) begin
                stable <= s1;
                cnt <= 0;
                if (s1) pulse <= 1;   // solo flanco de subida
            end
        end
    end
endmodule

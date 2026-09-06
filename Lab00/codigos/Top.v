module Top (
    input CLK,
    input reset,
    output reg Verde,
    output reg Amarillo,
    output reg Rojo
);
    //wire CLK;
    reg [1:0] estado;
    reg [2:0] cuenta;

    /*
    DivCLK FSM1 (
        .OCLK (OCLK),
        .reset(reset),
        .CLK  (CLK)
    );*/

    always @(posedge CLK, posedge reset) begin
        if (reset) begin
            Verde <= 1'b0;
            Amarillo <= 1'b0;
            Rojo <= 1'b0;
            cuenta <= 3'd0;
        end
        else begin
            case (estado)
                2'd0: if (cuenta == 3'd4) begin
                    estado <= 2'd1;
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
                2'd1: if (cuenta == 3'd1) begin
                    estado <= 2'd2;
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
                2'd2: if (cuenta == 3'd3) begin
                    estado <= 2'd0;
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
                default: begin
                    estado <= 2'd0;
                    cuenta <= 3'd0;
                end
            endcase
        end
    end

    always @(*) begin
        Verde = 1'b0;
        Amarillo = 1'b0;
        Rojo = 1'b0;
        case (estado)
            2'd0: Verde = 1'b1;
            2'd1: Amarillo = 1'b1;
            2'd2: Rojo = 1'b1;
            default: begin
                Verde = 1'b1;
                Amarillo = 1'b0;
                Rojo = 1'b0;
            end
        endcase
    end
endmodule

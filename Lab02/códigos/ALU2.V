module ALU2 (
    input clk,
    input [3:0] sw,
    input [3:0] btnCrudo,
    output reg [3:0] led,
    output reg [2:0] rgb
);
    reg [2:0] estado;
    reg [3:0] A;
    reg [3:0] B;
    reg [1:0] modo;
    wire [3:0] btn;

    debounce DB1 (
        .clk   (clk),
        .btn_in(btnCrudo[0]),
        .pulse (btn[0])
    );

    debounce DB2 (
        .clk   (clk),
        .btn_in(btnCrudo[1]),
        .pulse (btn[1])
    );

    debounce DB3 (
        .clk   (clk),
        .btn_in(btnCrudo[2]),
        .pulse (btn[2])
    );

    debounce DB4 (
        .clk   (clk),
        .btn_in(btnCrudo[3]),
        .pulse (btn[3])
    );

    always @(posedge clk) begin
        case (estado)
            3'd0: if (btn[0]) begin
                A <= sw;
                estado <= 3'd1;
            end
            3'd1: if (!btn[0]) estado <= 3'd2;
            3'd2: if (btn[1]) begin
                B <= sw;
                estado <= 3'd3;
            end
            3'd3: if (!btn[1]) estado <= 3'd4;
            3'd4: if (btn[0] | btn[1]) estado <= 3'd5;
                else if (btn[2]) modo[0] <= ~modo[0];
                else if (btn[3]) modo[1] <= ~modo[1];
            3'd5: if (!(btn[0] | btn[1])) estado <= 3'd0;
            default: begin
                estado <= 0;
                A <= 0;
                B <= 0;
                modo <= 0;
            end
        endcase
    end

    always @(*) begin
        rgb = 0;
        case (estado)
            3'd0, 3'd1, 3'd2, 3'd3: led = sw;
            3'd4, 3'd5: begin
                case (modo)
                    2'd0: begin
                        led = A+B;
                        rgb = 3'b010;
                    end
                    2'd1: begin
                        led = A-B;
                        rgb = 3'b001;
                    end
                    2'd2: begin
                        led = A&B;
                        rgb = 3'b100;
                    end
                    2'd3: begin
                        led = A|B;
                        rgb = 3'b111;
                    end
                    default: begin
                        led = A+B;
                        rgb = 3'b010;
                    end 
                endcase
            end
            default: begin
                led = 0;
                rgb = 0;
            end
        endcase
    end
endmodule

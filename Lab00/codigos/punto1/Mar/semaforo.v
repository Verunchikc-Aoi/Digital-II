module semaforo (
    input clk,
    input rst,
    output reg green,
    output reg yellow, // Se deja una sola salida para el amarillo
    output reg red
);

localparam verde     = 2'b00,
           amarillo1 = 2'b01,
           rojo      = 2'b10,
           amarillo2 = 2'b11;
        
reg [1:0] estado;
reg [2:0] contador;

// Logica secuencial: transicion de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        estado   <= verde;
        contador <= 0;
    end else begin
        case (estado)
            verde: begin
                if (contador == 4) begin
                    estado   <= amarillo1;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            amarillo1: begin
                if (contador == 1) begin
                    estado   <= rojo;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            rojo: begin
                if (contador == 3) begin
                    estado   <= amarillo2;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            amarillo2: begin
                if (contador == 1) begin
                   estado   <= verde;
                   contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end       
            default: begin
                estado   <= verde;
                contador <= 0;
            end
        endcase
    end
end

// Logica combinacional: salidas segun el estado actual
always @(*) begin
    green  = (estado == verde);
    // El LED amarillo se enciende tanto en la ida como en el regreso
    yellow = (estado == amarillo1) || (estado == amarillo2);
    red    = (estado == rojo);
end

endmodule
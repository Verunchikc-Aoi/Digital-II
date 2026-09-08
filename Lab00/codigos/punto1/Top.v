module Top (
    input CLK,           // Reloj
    input reset,         // Reset
    output reg Verde,    // Salida luz verde encendida
    output reg Amarillo, // Salida luz amarilla encendida
    output reg Rojo      // Salida luz roja encendida

);
    //wire CLK;
    reg [1:0] estado; // Estado actual de la FSM (2 bits: 0,1,2 = Verde,Amarillo,Rojo) se actualiza en el bloque secuencial, memoria real (flip-flops) de la FSM
    reg [2:0] cuenta;  // Contador interno de ciclos dentro de cada estado, memoria
 
    /*
    DivCLK FSM1 (
        .OCLK (OCLK),
        .reset(reset),
        .CLK  (CLK)
    );*/
    // version Top, recibe CLK directamente en vez de generarlo internamente con DivCLK)
 
    // Bloque 1: logica secuencial (registros de estado), avanza 'estado' y 'cuenta' en cada flanco de CLK, reset

    always @(posedge CLK, posedge reset) begin
        if (reset) begin
            //reinicia el contador
            Verde <= 1'b0;
            Amarillo <= 1'b0;
            Rojo <= 1'b0;
            cuenta <= 3'd0;
        end
        else begin
            case (estado)
                // Estado Verde: dura 5 ciclos
                2'd0: if (cuenta == 3'd4) begin
                    estado <= 2'd1;      // pasa a Amarillo
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
 
                // Estado Amarillo: dura 2 ciclos
                2'd1: if (cuenta == 3'd1) begin
                    estado <= 2'd2;      // pasa a Rojo
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
 
                // Estado Rojo: dura 4 ciclos
                2'd2: if (cuenta == 3'd3) begin
                    estado <= 2'd0;      // vuelve a Verde
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
 
                // Estado invalido (2'd3, no deberia ocurrir): se fuerza a volver a Verde por seguridad.
                default: begin
                    estado <= 2'd0;
                    cuenta <= 3'd0;
                end
            endcase
        end
    end

    // Bloque 2: logica combinacional (decodificador de salidas) es el 'estado' actual en las luces fisicas encendidas
    always @(*) begin
        // Valores por defecto: todo apagado, evita latches y asegura que solo se encienda la luz correcta
        Verde = 1'b0;
        Amarillo = 1'b0;
        Rojo = 1'b0;
        case (estado)
            2'd0: Verde = 1'b1;
            2'd1: Amarillo = 1'b1;
            2'd2: Rojo = 1'b1;
            default: begin
                // Estado invalido: por seguridad se enciende Verde.
                Verde = 1'b1;
                Amarillo = 1'b0;
                Rojo = 1'b0;
            end
        endcase
    end
endmodule

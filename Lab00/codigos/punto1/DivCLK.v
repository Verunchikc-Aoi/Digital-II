module DivCLK (
    input OCLK,     // Reloj rapido de entrada (el que queremos dividir)
    input reset,    // Reset asincronico, activo en alto
    output reg CLK  // Reloj lento de salida ya dividido, se asigna dentro de un bloque
);
    // Contador de 21 bits, se actualiza, es una memoria, dentro de un bloque secuencial
    reg [0:20] contador;
 
    // Bloque secuencial con reset asincronico disparado con el flanco de subida de OCLK o con el flanco de subida de reset
    always @(posedge OCLK, posedge reset) begin
        if (reset) begin
            // Reset asincronico: lleva todo a su estado inicial
            contador <= 21'b0;
            CLK   <= 1'b0;
        end
        else if (contador == 21'b010011000100101101000) begin
            // El contador llego al valor limite,se reinicia el contador y se invierte CLK, "divide" la frecuencia
            contador <= 21'b0;
            CLK   <= ~CLK;
        end
        else begin
            // Se sigue contando flancos de OCLK
            contador <= contador + 1;
        end
    end
endmodule

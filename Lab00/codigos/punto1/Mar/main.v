// Testbench de simulacion
`include "semaforo.v"
module main;
    reg clk;
    reg rst;
    wire green;
    wire yellow; // Se reemplazan yellow1 y yellow2 por un solo yellow
    wire red;

    semaforo dut (
        .clk(clk),
        .rst(rst),
        .green(green),
        .yellow(yellow), // Conexión a la única salida amarilla del módulo
        .red(red)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        #12 rst = 1'b0;

        // Se ajusta el número de repeticiones si deseas ver más de un ciclo completo
        repeat (28) begin
            @(posedge clk);
            #1;
            // Se actualiza el display para mostrar solo las 3 luces físicas
            $display("t=%0t green=%b yellow=%b red=%b",
                     $time, green, yellow, red);

            // Comprobación de seguridad actualizada para 3 luces
            if ((green + yellow + red) != 1)
                $display("ERROR: cantidad incorrecta de luces encendidas");
        end

        $finish;
    end

initial begin
  $dumpfile("ondas.vcd");
  $dumpvars(0, main);
end
endmodule
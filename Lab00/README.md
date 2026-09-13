# Lab 0 - Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)

<hr style="height: 4px; border: none; background-color: #c0f0f4;">

### Integrantes 2026 - 2

**Grupo 4**

- Ana Lucía Molina López - 1061697969
- Nicolás Ramírez González - 1023371323
- Diana Margarita Castillo - 1011201869

## Índice

- [Lab 0 - Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)](#lab-0---introducción-a-verilog-simulación-y-máquinas-de-estados-finitos-fsm)
    - [Integrantes 2026 - 2](#integrantes-2026---2)
  - [Índice](#índice)
  - [Punto 1](#punto-1)
    - [Diseño implementado](#diseño-implementado)
      - [Ana](#ana)
      - [Diana](#diana)
      - [Nicolás](#nicolás)
    - [Simulaciones](#simulaciones)
    - [Implementación](#implementación)
  - [Punto 2](#punto-2)
    - [Diseño implementado](#diseño-implementado-1)
      - [Ana](#ana-1)
      - [Diana](#diana-1)
      - [Nicolás](#nicolás-1)
    - [Simulaciones](#simulaciones-1)
    - [Implementación](#implementación-1)
      - [Ana](#ana-2)
      - [Diana](#diana-2)
      - [Nicolás](#nicolás-2)
  - [Punto 3](#punto-3)
  - [Conclusiones](#conclusiones)
  - [Código punto 1](#código-punto-1)
  - [Código punto 2](#código-punto-2)

## Punto 1

### Diseño implementado

Cada uno hizo un diseño diferente, pero el que se va a implementar en Verilog será el de Nicolás.

#### Ana

<img src="assets/fsmAna.png" width="600">

**Figura 1.** FSM.

> Si el reset vale 1, regresa al estado `S0`.

Para este se realizó las tablas de transición, que se pueden encontrar [aquí](https://docs.google.com/spreadsheets/d/1C5YlcoK99f4i70GjKSwNL7btG8Hh6j6SiFM0LFeSxWA/edit?usp=sharing "Holas de cálculo de google con las tablas de transición") y además se simulo el circuito en [Circuitverse](https://circuitverse.org/users/397629/projects/secuencial-feee2124-a29d-4914-8d60-471e157a33a3/simulator/embed "Circuito laboratorio 0 punto 1").

<img src="assets/punto1A.png" width="600">


#### Diana

<img src="assets/punto1asmM.png" width="600">

Las señales obtenidas con este [código](codigos/punto1/Mar/) fueron:

<img src="assets/punto1M.png" width="600">


#### Nicolás

<img src="assets/asmN.png" width="600">

**Figura 3.** ASM.

> Si el reset vale 1, entonces se devuelve al estado 0 y la cuenta `C = 0`.

### Simulaciones

Se realizó una simulación en Verilog mediante un testbench. 

El testbench genera una señal de reloj periódica y aplica la señal de reset al inicio de la simulación para llevar el circuito a su estado inicial. Para que luego, el sistema avance de manera sincronizada con el reloj, observando la activación de las diferentes salidas.

Se observan las señales:

`CLK`: señal de reloj utilizada para sincronizar el funcionamiento del circuito.

`reset`: señal utilizada para inicializar el sistema.

`Rojo`: salida estado rojo, que permanece activo durante 4 unidades de CLK.

`Verde`: salida  estado verde, permanece activo durante 5 unidades de CLK.

`Amarillo`: salida estado amarillo, que permanece activo durante 2 unidades de CLK.

La captura de GTKWave muestra el comportamiento temporal de las señales y permite evidenciar las transiciones entre los estados.

![Simulación en GTKWave](assets/punto1N.png)



### Implementación

El sistema es una máquina de estados secuencial que interactúa con un reloj (contador interno) `CLK`.

Primero se defienieron 3 estados principales: S0, S1 y S2, luego se especificaron las salidas de cada estado y que señal binaria ese activa:

- En S0: `V = 1` 
- En S1: `A = 1`
- En S2: `R = 1`
  
Además se agregó un registro de control `C`, un contador que se incrementa en 1 o se reinicia  a `C = 0`. 

Cada estado se comporta de manera autónoma durante un ciclo de reloj y se puede mapear directamente dentro de un bloque always @(*) para la lógica de transición o en las asignaciones de registros.

El código está en la parte de abajo y el la carpeta códigos.


## Punto 2

### Diseño implementado

Para este se dividio el punto entre los 3 integrantes, cada uno encargado de realizar una secuancia:

#### Ana 
<img src="assets/asmApunto2.png" width="600">


#### Diana

<img src="assets/asmMpunto2.png" width="600">

#### Nicolás

<img src="assets/asmNpunto2.png" width="600">

### Simulaciones

Se realizó una simulación en Verilog mediante un testbench. 

Se observan las señales:

`CLK`: señal de reloj utilizada para sincronizar el funcionamiento del circuito.

`reset`: señal utilizada para reiniciar el sistema.

`start`: señal utilizada para inicializar el sistema.

`x`: entrada de 4 bits que será el número a sumar cierta cantidad de veces.

`acumylado`: salida del resultado de sumar `x` cierta cantidad de veces.

`operacion`: entrada de un 2 bits, que selecciona cual de las 3 operaciones se quiere hacer.

> Si `operacion = 00` entonces el número de entrada `x` se sumará 3 veces.

> Si `operacion = 01` entonces el número de entrada `x` se sumará 4 veces.

> Si `operacion = 10` entonces el número de entrada `x` se sumará hasta que el acumulador `acumulado` sea `acc ≥ 20`.

`parar`: señal que frena la suma y deja el resulatado en el ciclo que se haya quedado.

`done`: salida que indica que ya se ha terminado la operación.

La captura de GTKWave muestra el comportamiento temporal de las señales con `x = 5` y luego `x = 3`.

![Simulación en GTKWave](assets/wavepunto2.png)



### Implementación

El sistema es una máquina de estados secuencial que interactúa con un reloj (contador interno) `CLK`.

Primero se identificaron salidas y entradas, los parametros que afectaran todos los casos (`star`, `stop` y `done`), luegonos dividimos y cada uno hizo una difernte operación:

#### Ana 

- Operación 01

Se uzaron 3 estados: 

- IDL: estado donde además de limpiar parametros (como `sum = 0`, `acumulador = 0`...), se espera una señal `star = 1` para poder continuar a SUMAR. 
- SUMAR: si no se ha precionado `stop = 1` y `cuenta` es diferente de 3, entonces se suma, se muestra, se aumenta `cuenta` y se actualiza el `acumulador`. En caso contrario (si `stop = 1` o `cuenta == 3`) se guarda el `acumulador`, se manda la señal de finalización y pasa al siguiente estado `HOLD`
- HOLD: Se va mantener aquí hasta que `star = 1` 0 `reset = 1`

La suma se va a mostrar en cada ciclo, que será la salida del estado `SUMAR`, además del `done = 1`.
  

#### Diana

- Operación 00
  
Para esta operación, se hizo algo parecido a la anterior, solo que aquí se agrego un estado de más para asegurar la limpieza en un ciclo de reloj dedicado justo después de recibir `star = 1`. Esto asegura que las sumas en `ADD` comiencen desde cero y evita falsos disparos o acumulación sobre valores previos al reiniciar el ciclo:

- IDLE: estado de reposo donde se mantiene el `done = 0`, y se espera la señal `start`.
- LOAD: encargado exclusivamente de limpiar los registros (`acc = 0` y `contador = 0`) para garantizar un punto de partida limpio antes de procesar.
- ADD: aquí en cada ciclo de reloj suma el valor de `x`, incrementa el contador y evalúa las salidas: avanza a `DONE` si se activa `stop = 1` o si se alcanzan las 3 sumas (`contador == 3`).
- DONE: activa `done = 1` y congela el resultado final en la salida hasta que se ordene un nuevo reinicio o un nuevo inicio con `star = 1`.

#### Nicolás

- Operación 10

Esta operación, a diferencia de las otras dos este suma el valor de x en bucle hasta alcanzarse un límite de valor `acumulado ≥ 20` o hasta que se active la señal `parar`.

Consta de 4 estados:

- Estado 0: espera `start = 1` y `x > 0`, además limpia el `acumulado = 0` y avanza al siguiente estado.
- Estado 1: estado de transición de 1 ciclo que pasa automáticamente al estado 2.
- Estado 2: aquí se suma `x` repetidamente a `acumulado` hasta que se activa `parar = 1` o el total llega a `≥ 20`, psando al estado 3.
- Estado 3: Activa `done = 1` y congela el resultado final hasta que `star = 0` y `parar = 0`. 

Cada uno es un archivo separado, que se van a llamar desde uno solo: [Superior](codigos/punto2/Superior.v).

En ese archivo se van agregar un selector de operación (`operacion`), en el cual el usuario puede elegir entre alguno de los 3 acumuladores. 


El código está en la parte de abajo y el la carpeta códigos.


## Punto 3


## Conclusiones

El primer problema se presentó durante la fase de instalación de Icarus Verilog. El software de protección detectó la versión más reciente del instalador como una falsa alerta de virus. Por lo que se optó por descargar  una versión anterior. 

La práctica permitió refrescar y profundizar conocimientos clave en el desarrollo de hardware con Verilog, además de la implementación y modelado de Máquinas de Estados Finitos (FSM) y ASM (Algorithmic State Machine).

Como ejercicio analítico complementario, se abordó el diseño clásico mediante el desarrollo manual de las tablas de transición para validar la lógica del circuito a nivel matemático antes de su codificación.

Se evidenció el rol del testbench en el diseño. Gracias a la simulación, se logró identificar a tiempo un error de lógica en el conteo de estados del primer punto: inicialmente, el contador se programó para iterar de 0 a 5, lo que introducía un ciclo de reloj excedente no deseado. La verificación de las formas de onda permitió corregirlo.

Recordar agregar el error del stop.

## Código punto 1
```verilog
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

    always @(posedge CLK, posedge reset) begin
        if (reset) begin
            estado <= 2'd0;
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
                    estado <= 2'd3;
                    cuenta <= 3'd0;
                end else cuenta <= cuenta + 3'd1;
                2'd3: if (cuenta == 3'd1) begin
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
            3'd3: Amarillo = 1'b1;
            default: begin
                Verde = 1'b1;
                Amarillo = 1'b0;
                Rojo = 1'b0;
            end
        endcase
    end
endmodule
```

## Código punto 2

```
// Módulo que controla al resto: Selector de Operación / Acumuladores
//Multiplexación/Demultiplexación de submódulos

module Superior (
    input  wire       CLK,        // Reloj 
    input  wire       reset,      // Reset global
    input  wire       start,      // Señal de inicio multiplexada
    input  wire [3:0] x,          // Valor de entrada de 4 bits
    input  wire       parar,      // Parada de emergencia
    input  wire [1:0] operacion,  // Selector de submódulo (0, 1, 2)

    output reg  [5:0] acumulado,  // Resultado acumulado multiplexado
    output reg        done        // Bandera de finalización multiplexada
);

    // Habilitación individual de inicio
    reg  [3:0] conection;

    // Buses internos para capturar las salidas de los submódulos
    wire [5:0] acumulado0, acumulado1, acumulado2;
    wire       done0, done1, done2;

    
    //Demux de 'start' y Mux de salidas
    
    always @(*) begin
        conection = 4'd0;        // Valor por defecto
        case (operacion)
            // Operación 0 (y 3 por omisión): Activa 'Acc3' (acumulador_secuencial)
            2'd0, 2'd3: begin
                conection[0] = start;
                acumulado    = acumulado0;
                done         = done0;
            end

            // Operación 1: Activa 'Acc4' (Top2A)
            2'd1: begin
                conection[1] = start;
                acumulado    = acumulado1;
                done         = done1;
            end

            // Operación 2: Activa 'Acc20' (Top2 - límite 20)
            2'd2: begin
                conection[2] = start;
                acumulado    = acumulado2;
                done         = done2;
            end

            // Estado por defecto de seguridad
            default: begin
                conection = 4'd0;
                acumulado = 6'd0;
                done      = 1'b0;
            end
        endcase
    end

    // submódulos instanciados

    // Submódulo 0: Suma fija de 3 iteraciones
    acumulador_secuencial Acc3 (
        .clk   (CLK),
        .rst   (reset),
        .start (conection[0]),
        .x     (x),
        .acc   (acumulado0),
        .done  (done0),
        .stop  (parar)
    );

    // Submódulo 1: Acumulador variante A
    Top2A Acc4 (
        .CLK   (CLK),
        .start (conection[1]),
        .reset (reset),
        .stop  (parar),
        .x     (x),
        .sum   (acumulado1),
        .done  (done1)
    );

    // Submódulo 2: Acumulador por tope (>= 20)
    Top2 Acc20 (
        .CLK       (CLK),
        .reset     (reset),
        .start     (conection[2]),
        .parar     (parar),
        .x         (x),
        .acumulado (acumulado2),
        .done      (done2)
    );

endmodule
```
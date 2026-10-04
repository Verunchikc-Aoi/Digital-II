# Laboratorio 01 FPGA Zybo Z7 Vivado Vitis y Validación de Hardware

<hr style="height: 4 px; border: none; background-color: #c0f0f4;">

### Integrantes 2026 - 2

**Grupo 4**

- Ana Lucía Molina López - 1061697969
- Nicolás Ramírez González - 1023371323
- Diana Margarita Castillo - 1011201869
  
## Índice

  - Actividad 1: Verificación del entorno en FPGA (Smoke Test)
      - Explicación del funcionamiento del código de prueba
      - Montaje y ejecución del código
      - Demostración
  - Actividad 2: Prueba Funcional Personalizado (Diseño libre con criterios obligatorios)
      - Explicación del funcionamiento del código creado
      - Demostración ( GTKwave y video )
      - Conclusiones

## Actividad 1: Verificación del entorno en FPGA (Smoke Test)

### 1.1 Explicación del funcionamiento del código de prueba:

El diseño del código propuesto se basa en la creación de un semáforo cíclico simple. Esta máquina de estados finitos tipo Moore cuenta con cuatro estados que gestionan las transiciones de las luces (Verde, Amarillo, Rojo, y nuevamente Amarillo) en lapsos de tiempo sincronizados por un reloj. 
Cada cambio de transición entre estados cuenta con un tiempo definido. Para el primer cambio de transición (verde-amarillo) el contador debe cumplir con un total de 5 ciclos de reloj, mientras que las transiciones posteriores deben cumplir 2 y 4 ciclos de reloj respectivamente.

### 1.2 Montaje y ejecución del código:

Para la implementación del diseño en la tarjeta FPGA Zybo Z7, primero se importó el archivo fuente .v del semáforo en el entorno AMD Vivado 2025.2. Posteriormente, se añadió el archivo de restricciones (.xdc) correspondiente a la placa Zybo Z7 para realizar la asignación de pines y LEDs necesarios (En este caaso el led designado fue el RGB 6), permitiendo así la validación física del funcionamiento del código. 
En este caso 

### 1.3 Demostración

https://github.com/user-attachments/assets/7f2d008a-319e-461f-b8ce-a855fd1889c5

## Actividad 2: Prueba Funcional Personalizado (Diseño libre con criterios obligatorios)

### 2.1 Explicación del funcionamiento del código creado:

El código propuesto se basa en la creación de una ALU (Unidad Aritmética Lógica) secuencial controlada a través de una máquina de estados finitos (FSM). Esta cumple la función de registrar dos números de cuatro bits ($A$ y $B$), ejecutar una operación aritmética (suma) o lógica (AND, OR, XOR), y desplegar el resultado a través de cuatro LEDs principales. Asimismo, utiliza un LED RGB para identificar visualmente la operación realizada durante el proceso. 

Este código inicialmente sincroniza las señales de pulso de cada botón con la señal de reloj. Luego, utiliza la compuerta AND y la negación (s1 & ~s1_prev) para que el sistema genere un pulso preciso de un solo ciclo de reloj en el flanco de subida, esto con el fin de evitar lecturas erróneas por rebotes mecánicos.

Posteriormente, la FSM gestiona la captura secuencial de datos a través de ventanas de tiempo (slots). En el estado inicial (IDLE), el sistema lee el operando $A$ desde los conmutadores (switches). Al presionar un botón, la máquina transiciona sucesivamente por los estados del 1 al 5 para almacenar bit a bit el operando $B$ y el código de operación (op). Cada ventana se mantiene activa hasta detectar el pulso del botón esperado o hasta que transcurre el tiempo límite marcado por un contador interno (c), garantizando un tiempo prudencial de espera.  

Finalmente, en el estado de resultado (3'd6), la ALU evalúa la operación seleccionada (op) para enviar el resultado correspondiente a los cuatro LEDs principales. De forma simultánea, activa el LED RGB con un color característico (Rojo para AND, Verde para OR y Azul para XOR) para confirmar visualmente qué cálculo lógico fue procesado.

### 2.2 Demostración ( GTKwave y video )

#### GTKwave: 
Previo a la demostración física de la ALU en la FPGA, se realizó la simulación del código en GTKwave. A continuación se muestran los resultados obtenidos:

Adjuntar captura de imagen


#### Vivado:

Para la implementación física del código propuesto, se tuvo en cuenta las indicaciones previamente realizadas en el código de prueba. De modo que, primero se importó en Vivado el archivo fuente .v del código junto con el archivo de restricciones (constraints .xdc) correspondiente a la placa Zybo Z7. 

Posteriormente se designaron cada unos de los switches, pulsadores y leds necesario para la demostración del diseño en la FPGA. En este caso fue necesario el uso de dos pulsadores externos dado que aunque la tarjeta Zybo Z7 cuenta con 6 botones físicos, 2 de estos Están conectados a los pines MIO (Multiplexed I/O) del procesador ARM. Al estar aislados en la parte del procesador, no tienen conexión física directa con la matriz de la FPGA y no se pueden mapear mediante un archivo .xdc estándar.

https://github.com/user-attachments/assets/db13b22e-9388-4043-9565-2212095b03c2

### Conclusiones

Acorde con las pruebas realizadas en la FPGA Zybo Z7 (Semáforo y ALU) se obtuvieron las siguientes conclusiones:

#### Divisor de frecuencia:
Para llevar a cabo las pruebas físicas del diseño de la ALU, se requirió implementar un divisor de frecuencia. Dado que la tarjeta de desarrollo Zybo Z7 opera con un reloj principal de 125 MHz, la ejecución de las instrucciones ocurría a una velocidad que excedía la capacidad de percepción visual humana, haciendo imposible la correcta verificación de los resultados en la placa sin reducir previamente la frecuencia de trabajo.

#### Tiempo de respuesta


#### Designación de botones físicos
Debido a que la placa FPGA utilizada cuenta con seis botones integrados, de los cuales dos no son de propósito general (no programables), fue necesario implementar dos pulsadores externos. Para garantizar su correcto funcionamiento durante los estados de corto y saturación, estos se configuraron habilitando la resistencia de PULLDOWN dentro del archivo de restricciones .xdc.

#### Diferencia entre la simulación y la implementación física

El desarrollo del proyecto evidenció la diferencia crítica entre la simulación de hardware y su implementación física. Mientras que en entornos de simulación, como el de Vivado, es posible analizar y validar el comportamiento de la ALU a su frecuencia nominal, la implementación en la tarjeta exigió adaptar el diseño al mundo real. El uso de resistencias pull-down para los pulsadores y de divisores de frecuencia para la visualización demuestra que el diseño digital no solo requiere lógica funcional, sino también acondicionamiento de señales para interactuar adecuadamente con el usuario.













 

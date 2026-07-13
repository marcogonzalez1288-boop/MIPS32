# Proyecto Final: Procesador MIPS con Pipeline en Verilog

## 📌 Descripción del Proyecto
Este proyecto consiste en el diseño, implementación y simulación de un procesador con arquitectura MIPS de 32 bits utilizando segmentación de cauce (Pipeline) de 5 etapas (IF, ID, EX, MEM, WB). El procesador fue modelado en Verilog y simulado en ModelSim.

El objetivo práctico del hardware es ejecutar un programa en código ensamblador MIPS capaz de procesar un arreglo de 5 números cargados en la memoria de datos para:
1. Encontrar el **número máximo** del arreglo.
2. Contar la cantidad de **números impares**.

---

## 🛠️ Arquitectura y Componentes
El procesador está compuesto por los módulos clásicos de la ruta de datos MIPS:
* **PC y Sumadores:** Controlan el flujo de las instrucciones.
* **Memoria de Instrucciones:** Almacena el código binario compilado.
* **Banco de Registros:** Con capacidad de reenvío interno para mitigar riesgos.
* **ALU (Unidad Aritmético Lógica):** Encargada de sumas, restas y operaciones lógicas (`AND` para la detección de impares).
* **ARAM (Memoria de Datos):** Inicializada mediante un bloque de código para limpiar arreglos y cargar el archivo `Memoria.txt` utilizando la función de Verilog `$readmemb`.
* **Multiplexores (MUX):** Controlan las rutas de datos dependiendo de las señales de control (implementados con asignación continua lógica condicional).

---

## ⚠️ Manejo de Riesgos (Pipeline Hazards)
Dado que la arquitectura no cuenta con una Unidad de Detección de Riesgos (Hazard Detection Unit) ni Unidad de Reenvío en hardware (Forwarding Unit), los conflictos se resolvieron por **Software** inyectando instrucciones nulas (`nop`):

* **Riesgos de Datos (Data Hazards):** Se insertaron 2 `nop` después de las instrucciones que escriben en registros si la instrucción adyacente requiere ese mismo dato, dando tiempo a que el valor llegue a la etapa de *WriteBack*.
* **Riesgos de Control (Control Hazards):** Se inyectaron 3 `nop` después de cada instrucción de salto (`beq` o `j`) para realizar un vaciado manual (Flush) y evitar la ejecución de instrucciones fantasma que ya habían entrado al pipeline.

---

## 💻 Programa de Prueba y Datos
El archivo `Memoria.txt` fue cargado con los siguientes 5 valores de prueba (en binario de 32 bits):
1. `15` (Impar)
2. `89` (Máximo, Impar)
3. `4` (Par)
4. `23` (Impar)
5. `10` (Par)

**Resultados Esperados:**
* **Valor Máximo:** `89` (Hexadecimal: `59`)
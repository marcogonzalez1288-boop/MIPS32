# Programa de prueba MIPS32 - Búsqueda de Máximo y Conteo de Impares
# Cumple con: Aritméticas, Lógicas, Comparaciones, LW, SW, BEQ y J.

# =========================================================
# INICIALIZACIÓN
# =========================================================
addi $t0, $zero, 0      # $t0 = Direccion base del arreglo (Memoria de datos en 0)
addi $t1, $zero, 5      # $t1 = Tamaño del arreglo (5 elementos a leer)
addi $t2, $zero, 0      # $t2 = Contador del ciclo (i = 0)
addi $s0, $zero, 0      # $s0 = Valor maximo encontrado (Max = 0)
addi $s1, $zero, 0      # $s1 = Contador de numeros impares (Impares = 0)

ciclo:
# =========================================================
# CONDICION DE SALIDA DEL CICLO (i < 5)
# =========================================================
slt  $t3, $t2, $t1      # $t3 = 1 si (i < tamaño), 0 si no
beq  $t3, $zero, fin    # Si $t3 es 0 (llegamos al limite), salta a la etiqueta 'fin'

# =========================================================
# LECTURA DE MEMORIA
# =========================================================
lw   $t4, 0($t0)        # $t4 = Carga en el registro el elemento actual del arreglo

# =========================================================
# OPERACION LOGICA: CONTEO DE IMPARES
# =========================================================
andi $t5, $t4, 1        # $t5 = $t4 AND 1 (Mascara logica para aislar el bit menos significativo)
beq  $t5, $zero, skip   # Si $t5 es 0 (el numero es par), salta y evita el incremento
addi $s1, $s1, 1        # Aritmetica: Si es impar, incrementa el contador de impares ($s1++)

skip:
# =========================================================
# COMPARACION: BUSQUEDA DEL MAXIMO
# =========================================================
slt  $t5, $s0, $t4      # $t5 = 1 si (Maximo < Elemento actual)
beq  $t5, $zero, next   # Si Maximo >= Elemento actual, salta a 'next'
add  $s0, $zero, $t4    # Si el Elemento es mayor, actualizamos: Maximo = Elemento actual

next:
# =========================================================
# MANTENIMIENTO DEL CICLO Y SALTO (JUMP)
# =========================================================
addi $t0, $t0, 4        # Avanza el puntero de memoria a la siguiente palabra (+4 bytes)
addi $t2, $t2, 1        # Incrementa el contador del ciclo (i++)
j    ciclo              # Salto incondicional al inicio de la etiqueta 'ciclo'

fin:
# =========================================================
# GUARDAR RESULTADOS EN MEMORIA
# =========================================================
sw   $s0, 40($zero)     # Guarda el Valor Maximo en la direccion 40 de la RAM
sw   $s1, 44($zero)     # Guarda el Conteo de Impares en la direccion 44 de la RAM
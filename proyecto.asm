.data
# Declaración de variables
NUM_CASILLAS:      .word 12
NUM_CHACALES:      .word 4
NUM_TESOROS:       .word 8
PREMIO_TESORO:     .word 100
TESOROS_GANAR:     .word 4
BUFFER_SIZE:       .word 100

tablero:       .space 12             # Espacio para el tablero de juego
descubiertas:  .space 48             # Espacio para las casillas descubiertas (máximo 12)
numDescubiertas: .word 0             # Número de casillas descubiertas
chacalesEncontrados: .word 0         # Contador de chacales encontrados
tesorosEncontrados: .word 0          # Contador de tesoros encontrados
dineroGanado: .word 0                # Dinero ganado
intentosFallidos: .word 0            # Contador de intentos fallidos
ultimosIntentos: .space 12           # Espacio para los últimos tres intentos
continuarJugando: .word 1            # Flag para continuar jugando
casilla: .word 0                     # Variable para la casilla generada aleatoriamente
opcion: .space 4                     # Espacio para la opción de continuar jugando

# Cadenas de texto
mensaje_dinero: .asciiz "Dinero ganado: $"
mensaje_chacales: .asciiz "Chacales encontrados: "
mensaje_casilla: .asciiz "Número de casilla generado: "
mensaje_tesoro: .asciiz "¡Encontraste un tesoro! Ganaste $"
mensaje_chacal: .asciiz "¡Encontraste un chacal!"
mensaje_continuar: .asciiz "¿Deseas continuar jugando? (1: sí, 2: no): "
mensaje_tesoro4: .asciiz "Has encontrado 4 tesoros. "
mensaje_juego_terminado: .asciiz "Juego terminado.\n"
newline: .asciiz "\n"
space_bracket: .asciiz "[ ]"         # Cadena para una casilla vacía
tablero_format: .asciiz "[ ]"

.text
.globl main

main:
    # Inicialización de la semilla para los números aleatorios
    addi $v0, $zero, 30        # Syscall 30: System Time syscall
    syscall                    # $a0 will contain the 32 LS bits of the system time
    add $t0, $zero, $a0        # Save $a0 value in $t0 

    addi $v0, $zero, 40        # Syscall 40: Random seed
    add $a0, $zero, $zero      # Set RNG ID to 0
    add $a1, $zero, $t0        # Set Random seed to current time
    syscall

loop:
    # Mostrar tablero
    la $t0, tablero
    li $t1, 0
    lw $t2, NUM_CASILLAS       # Cargar el valor de NUM_CASILLAS en $t2
    imprimir_tablero:
        beq $t1, $t2, fin_tablero
        lb $a0, 0($t0)
        beqz $a0, casilla_vacia
        li $v0, 4
        syscall
        j siguiente_casilla
    casilla_vacia:
        la $a0, space_bracket
        li $v0, 4
        syscall
    siguiente_casilla:
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        j imprimir_tablero
    fin_tablero:
        la $a0, newline
        li $v0, 4
        syscall

    # Mostrar estado del juego
    la $a0, mensaje_dinero
    li $v0, 4
    syscall
    lw $a0, dineroGanado
    li $v0, 1
    syscall

    la $a0, newline       # Añadir un salto de línea
    li $v0, 4
    syscall

    la $a0, mensaje_chacales
    li $v0, 4
    syscall
    lw $a0, chacalesEncontrados
    li $v0, 1
    syscall

    la $a0, newline       # Añadir un salto de línea
    li $v0, 4
    syscall

    # Generar número de casilla aleatorio
    addi $v0, $zero, 42        # Syscall 42: Random int range
    add $a0, $zero, $zero      # Set RNG ID to 0
    addi $a1, $zero, 12        # Set upper bound to 12 (exclusive)
    syscall                    # Generate a random number and put it in $a0
    add $t0, $zero, $a0        # Copy the random number to $t0
    addi $t0, $t0, 1           # Ajustar al rango 1-12
    sw $t0, casilla
    
    # Mostrar número de casilla generado
    la $a0, mensaje_casilla
    li $v0, 4
    syscall
    lw $a0, casilla
    li $v0, 1
    syscall

    la $a0, newline       # Añadir un salto de línea
    li $v0, 4
    syscall
    
    # Verificar si la casilla está descubierta
    lw $t0, casilla
    subi $t0, $t0, 1       # Ajustar a índice 0
    lw $t1, numDescubiertas
    sll $t2, $t0, 2
    lw $t3, descubiertas($t2)
    beq $t3, $t0, casilla_descubierta
    
    # Actualizar la lista de casillas descubiertas
    sll $t4, $t1, 2
    sw $t0, descubiertas($t4)
    addi $t1, $t1, 1
    sw $t1, numDescubiertas
    
    # Casilla no descubierta, procesar contenido
    lb $t5, tablero($t0)
    beq $t5, 'C', es_chacal
    beq $t5, 'T', es_tesoro
    j continuar_juego

casilla_descubierta:
    # Incrementar contador de intentos fallidos
    lw $t6, intentosFallidos
    addi $t6, $t6, 1
    sw $t6, intentosFallidos
    j continuar_juego

es_chacal:
    # Encontrar un chacal
    lw $t7, chacalesEncontrados
    addi $t7, $t7, 1
    sw $t7, chacalesEncontrados
    la $a0, mensaje_chacal
    li $v0, 4
    syscall
    j continuar_juego

es_tesoro:
    # Encontrar un tesoro
    lw $t8, tesorosEncontrados
    addi $t8, $t8, 1
    sw $t8, tesorosEncontrados
    lw $t9, dineroGanado
    addi $t9, $t9, 100
    sw $t9, dineroGanado
    la $a0, mensaje_tesoro
    li $v0, 4
    syscall
    li $a0, 100  # Mostrar el premio del tesoro directamente
    li $v0, 1
    syscall
    j continuar_juego

continuar_juego:
    # Preguntar si desea continuar jugando
    la $a0, mensaje_continuar
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, continuarJugando
    
    # Comprobar si el juego debe continuar
    lw $t1, continuarJugando
    li $t2, 1
    beq $t1, $t2, loop
    
    # Terminar el juego
    la $a0, mensaje_juego_terminado
    li $v0, 4
    syscall
    j end

end:
    li $v0, 10               # Syscall para terminar el programa
    syscall
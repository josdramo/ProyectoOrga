.data
# Declaración de variables
NUM_CASILLAS:      .word 12
NUM_CHACALES:      .word 4
NUM_TESOROS:       .word 8
PREMIO_TESORO:     .word 100
TESOROS_GANAR:     .word 4
BUFFER_SIZE:       .word 100

tablero:           .space 12            # Espacio para el tablero de juego
descubiertas:      .space 48            # Espacio para las casillas descubiertas (máximo 12)
numDescubiertas:   .word 0              # Número de casillas descubiertas
chacalesEncontrados: .word 0            # Contador de chacales encontrados
tesorosEncontrados: .word 0             # Contador de tesoros encontrados
dineroGanado:      .word 0              # Dinero ganado
intentosFallidos:  .word 0              # Contador de intentos fallidos
ultimosIntentos:   .space 12            # Espacio para los últimos tres intentos
continuarJugando:  .word 1              # Flag para continuar jugando
casilla:           .word 0              # Variable para la casilla generada aleatoriamente
opcion:            .space 4             # Espacio para la opción de continuar jugando

# Cadenas de texto
mensaje_dinero:    .asciiz "Dinero ganado: $"
mensaje_chacales:  .asciiz "Chacales encontrados: "
mensaje_casilla:   .asciiz "Número de casilla generado: "
mensaje_tesoro:    .asciiz "¡Encontraste un tesoro! Ganaste $"
mensaje_chacal:    .asciiz "¡Encontraste un chacal!"
mensaje_continuar: .asciiz "¿Deseas continuar jugando? (1: sí, 2: no): "
mensaje_tesoro4:   .asciiz "Has encontrado 4 tesoros. "
mensaje_juego_terminado: .asciiz "Juego terminado.\n"
blanco: .asciiz "[] "

.text
.globl main

main:
    # Inicialización de la semilla para los números aleatorios
    li $v0, 40              
    syscall

loop:
    # Mostrar tablero
    la $t0, tablero
    la $a0, tablero
    li $t1, 0
mostrar_tablero:
    beq $t1, 12, mostrar_estado
    lb $t2, 0($t0)
    beqz $t2, casilla_vacia
    li $v0, 4
    syscall
    j siguiente_casilla
casilla_vacia:
    la $a0, blanco
    li $v0, 4
    syscall
siguiente_casilla:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j mostrar_tablero

# Mostrar estado del juego
mostrar_estado:
    la $a0, mensaje_dinero
    li $v0, 4
    syscall
    lw $a0, dineroGanado
    li $v0, 1
    syscall
    
    la $a0, mensaje_chacales
    li $v0, 4
    syscall
    lw $a0, chacalesEncontrados
    li $v0, 1
    syscall
    
    # Generar número de casilla aleatorio
    li $a0, 1               # Límite inferior (1)
    li $a1, 12              # Límite superior (12)
    li $v0, 42              # Syscall para el número aleatorio
    syscall
    sub $t0, $v0, 1         # Casilla generada (ajustar a índice 0)
    sw $t0, casilla
    
    # Mostrar número de casilla generado
    la $a0, mensaje_casilla
    li $v0, 4
    syscall
    lw $a0, casilla
    li $v0, 1
    syscall
    
    # Verificar si la casilla está descubierta
    lw $t0, casilla
    sll $t1, $t0, 2
    lw $t2, descubiertas($t1)
    beq $t2, $t0, casilla_descubierta
    
    # Casilla no descubierta, procesar contenido
    lb $t3, tablero($t0)
    beq $t3, 'C', es_chacal
    beq $t3, 'T', es_tesoro
    j continuar_juego

casilla_descubierta:
    # Incrementar contador de intentos fallidos
    lw $t4, intentosFallidos
    addi $t4, $t4, 1
    sw $t4, intentosFallidos
    j continuar_juego

es_chacal:
    # Encontrar un chacal
    lw $t5, chacalesEncontrados
    addi $t5, $t5, 1
    sw $t5, chacalesEncontrados
    la $a0, mensaje_chacal
    li $v0, 4
    syscall
    j continuar_juego

es_tesoro:
    # Encontrar un tesoro
    lw $t6, tesorosEncontrados
    addi $t6, $t6, 1
    sw $t6, tesorosEncontrados
    lw $t7, dineroGanado
    addi $t7, $t7, 100
    sw $t7, dineroGanado
    la $a0, mensaje_tesoro
    li $v0, 4
    syscall
    lw $a0, PREMIO_TESORO
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
    move $t8, $v0
    sw $t8, continuarJugando
    
    # Comprobar si el juego debe continuar
    lw $t9, continuarJugando
    li $t9, 1
    beq $t9, $t9, loop
    
    # Terminar el juego
    la $a0, mensaje_juego_terminado
    li $v0, 4
    syscall
    j end

end:
    li $v0, 10               # Syscall para terminar el programa
    syscall

.data

NUM_CASILLAS:      .word 12
NUM_CHACALES:      .word 4
NUM_TESOROS:       .word 8
PREMIO_TESORO:     .word 100
TESOROS_GANAR:     .word 4
BUFFER_SIZE:       .word 100

tablero: .space 12           # Tablero de 12 casillas
descubiertas: .space 12    # 12 casillas para marcar como descubiertas (0: no, 1: sí)
chacalesEncontrados: .word 0          # Número de chacales encontrados
tesorosEncontrados: .word 0           # Número de tesoros encontrados
dineroGanado: .word 0            # Dinero acumulado
intentosFallidos: .word 0     # Contador de repeticiones seguidas del número aleatorio
mensajeInicioJuego: .asciiz "******** JUEGO DE CHACALES Y TESOROS *******\nGana el máximo dinero que puedas pero si te salen los cuatro chacales perderás.\nUna vez hayan conseguido 4 tesoros te puedes retirar con el premio.\nBuena suerte.\nInstrucciones:\nCasilla sin revelar: [ ]\nCasilla con chacal: [C]\nCasilla con tesoro: [T]\n"
strJuegoTerminado: .asciiz "¡Has perdido el juego!\n"
strGanar: .asciiz "¡Has ganado el juego!\n"
strContinuar: .asciiz "\n¿Deseas continuar jugando? (1: Si, 0: No): "
strValidar: .asciiz "La opción ingresada no es válida.\n"
strDinero: .asciiz "Dinero ganado: $"
strChacal: .asciiz "Chacales encontrados: "
strTesoro: .asciiz "Tesoros encontrados: "
strTablero: .asciiz "-------------------------------------\nTablero: \n"
strCasilla: .asciiz "Número de casilla generado: "
formatoTablero: .asciiz "[ ] "
iconoDescubierto: .asciiz "[0] "
chacal: .asciiz "[C] "
tesoro: .asciiz "[T] "
newline: .asciiz "\n"

.text
.globl main

main:
    # Inicializar el juego
    li $v0, 4
    la $a0, mensajeInicioJuego
    syscall

    jal inicioTablero
    
    # Bucle principal del juego
comienzoJuego:
    jal generacionNumeroAleatorio
    
    move $t4, $v0

    # Mostrar el número generado
    li $v0, 4
    la $a0, strCasilla
    syscall

    move $a0, $t4  # Mover el número generado a $a0
    li $v0, 1      # Syscall para imprimir entero
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    move $v0, $t4  # Mover el número generado a $v0

    jal casillaDescubierta

    # Mostrar el tablero actualizado
    jal presentarTablero
    
    # Mostrar el dinero acumulado
    jal presentarDinero
    
    # Verificar condiciones de fin del juego
    jal verificarCondiciones
    
    # Preguntar al jugador si quiere continuar
    jal continuarJuego
    beq $v0, 0, finalizarJuego

    j comienzoJuego

finalizarJuego:
    jal mostrarResultados
    li $v0, 10
    syscall

# Inicializa el tablero con chacales y tesoros distribuidos aleatoriamente
inicioTablero:
    li $t0, 0  # Índice del tablero
    li $t1, 4  # Número de chacales
    li $t2, 8  # Número de tesoros

# Inicializar tablero con 0 (vacío)
inicializarLoop:
    li $t3, 0
    sb $t3, tablero($t0)
    sb $t3, descubiertas($t0)
    addi $t0, $t0, 1
    bne $t0, 12, inicializarLoop

# Colocar chacales en el tablero
colocarChacales:
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall

    move $t4, $a0 # the random number 0-11

    # Verificar si la casilla ya está ocupada
    lb $t5, tablero($t4)
    bnez $t5, colocarChacales

    # Colocar chacal
    li $t5, 1
    sb $t5, tablero($t4)
    subi $t1, $t1, 1
    bnez $t1, colocarChacales

# Colocar tesoros en el tablero
colocarTesoros:
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall

    move $t4, $a0 # the random number 0-11

    # Verificar si la casilla ya está ocupada
    lb $t5, tablero($t4)
    bnez $t5, colocarTesoros

    # Colocar tesoro
    li $t5, 2
    sb $t5, tablero($t4)
    subi $t2, $t2, 1
    bnez $t2, colocarTesoros

    jr $ra

# Mostrar el dinero acumulado
presentarDinero:
    li $v0, 4
    la $a0, strDinero
    syscall
    
    la $t0, dineroGanado
    lw $a0, 0($t0)
    li $v0, 1      # Syscall para imprimir entero
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    jr $ra

# Muestra el estado actual del tablero
presentarTablero:
    li $v0, 4
    la $a0, strTablero
    syscall

    li $t0, 0  # Inicializa el índice del bucle

presentarTableroLoop:
    lb $t2, descubiertas($t0)  # Cargar el estado de descubrimiento de la casilla actual
    beqz $t2, casillaOculta  # Si la casilla no está descubierta, mostrar "?"

    lb $t1, tablero($t0)  # Cargar el contenido de la casilla actual
    beq $t1, 0, casillaVacia
    beq $t1, 1, casillaChacal
    beq $t1, 2, casillaTesoro

casillaOculta:
    li $v0, 4
    la $a0, formatoTablero
    syscall
    j siguienteCasilla

casillaVacia:
    li $v0, 4
    la $a0, iconoDescubierto
    syscall
    j siguienteCasilla

casillaChacal:
    li $v0, 4
    la $a0, chacal
    syscall
    j siguienteCasilla

casillaTesoro:
    li $v0, 4
    la $a0, tesoro
    syscall

siguienteCasilla:
    addi $t0, $t0, 1
    bne $t0, 12, presentarTableroLoop
    jr $ra

# Genera un número aleatorio entre 1 y 12
generacionNumeroAleatorio:
    addi $sp, $sp, -8
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)
    
    li $v0, 42         # syscall code para generar un entero aleatorio
    li $a1, 12         # limite superior exclusivo del entero a generarse 
    syscall            # genera el entero y lo guarda en a0
    
    addi $v0, $a0, 1
    
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 8
    
    jr $ra

# Descubre la casilla seleccionada
casillaDescubierta:
    move $t0, $v0       # $t0 = número de casilla
    subi $t0, $t0, 1    # Convertir de 1-12 a 0-11
    lb $t1, descubiertas($t0)
    bnez $t1, casillaActualDescubierta  # Si la casilla ya está descubierta, ir a la etiqueta correspondiente

    li $t1, 1
    sb $t1, descubiertas($t0)  # Marcar la casilla como descubierta

    lb $t1, tablero($t0)
    beqz $t1, descubrirCasillaVacia
    beq $t1, 1, casillaChacalDescubierta
    beq $t1, 2, casillaTesoroDescubierta
    j finalizarDescubrir

descubrirCasillaVacia:
    li $t1, 0
    sb $t1, tablero($t0)
    j finalizarDescubrir

casillaChacalDescubierta:
    li $t1, 1
    sb $t1, tablero($t0)
    lw $t2, chacalesEncontrados
    addi $t2, $t2, 1
    sw $t2, chacalesEncontrados
    lw $t3, intentosFallidos
    addi $t3, $t3, 1
    sw $t3, intentosFallidos
    j finalizarDescubrir

casillaTesoroDescubierta:
    li $t1, 2
    sb $t1, tablero($t0)
    lw $t2, tesorosEncontrados
    addi $t2, $t2, 1
    sw $t2, tesorosEncontrados
    lw $t3, dineroGanado
    addi $t3, $t3, 100
    sw $t3, dineroGanado
    sw $zero, intentosFallidos
    j finalizarDescubrir

casillaActualDescubierta:
    lw $t4, intentosFallidos
    addi $t4, $t4, 1
    sw $t4, intentosFallidos

finalizarDescubrir:
    jr $ra

# Verifica las condiciones de ganar o perder
verificarCondiciones:
    lw $t0, chacalesEncontrados
    lw $t1, tesorosEncontrados
    lw $t2, intentosFallidos

    # Si se han encontrado 4 chacales, el juego termina en perder
    li $t3, 4
    beq $t0, $t3, perder

    # Si se han encontrado los 4 tesoros necesarios para ganar, el juego termina en ganar
    li $t3, 8
    beq $t1, $t3, ganar

    # Si hay más de 5 intentos fallidos, el juego termina en perder
    li $t3, 5
    bgt $t2, $t3, perder

    jr $ra

perder:
    li $v0, 4
    la $a0, strJuegoTerminado
    syscall
    jal mostrarResultados
    li $v0, 10
    syscall

ganar:
    li $v0, 4
    la $a0, strGanar
    syscall
    jal mostrarResultados
    li $v0, 10
    syscall

# Pregunta al usuario si desea continuar jugando
continuarJuego:
    li $v0, 4
    la $a0, strContinuar
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    # Validar la opción ingresada
    li $t1, 1
    beq $t0, $t1, opcionValida

    li $t1, 0
    beq $t0, $t1, opcionValida

    li $v0, 4
    la $a0, strValidar
    syscall

    j continuarJuego

opcionValida:
    move $v0, $t0
    jr $ra

# Muestra los resultados finales del juego
mostrarResultados:
    li $v0, 4
    la $a0, strDinero
    syscall

    lw $a0, dineroGanado
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, strChacal
    syscall

    lw $a0, chacalesEncontrados
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, strTesoro
    syscall

    lw $a0, tesorosEncontrados
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    jr $ra

# inicializarTablero: Inicializa el tablero con valores iniciales.
.data
    tablero: .space 128  # Reserva espacio para el tablero (32 elementos de 4 bytes)

.text
.globl inicializarTablero
inicializarTablero:
    # Arguments: $a0 = tablero (base address), $a1 = size (size of the board)
    # Clear the board
    li $t0, 0       # Initialize counter t0 to 0
    li $t1, 32      # Constant 32 to be stored
    move $t2, $a1   # Store size in t2

loop_clear:
    bge $t0, $t2, end_clear # If counter >= size, end loop
    sw $t1, 0($a0)          # Store 32 at tablero[t0]
    addi $a0, $a0, 4        # Move to next element
    addi $t0, $t0, 1        # Increment counter
    j loop_clear            # Repeat

end_clear:
    # The board is cleared; continue with random placement
    li $t3, 0               # Initialize another counter for placement

    # Loop to place 'C' 4 times
loop_C:
    li $v0, 42              # System call for rand()
    syscall
    rem $t4, $v0, $a1       # t4 = rand() % size
    sll $t5, $t4, 2         # Convert index to byte offset (multiply by 4)
    add $t5, $t5, $a0       # Address of tablero[t4]
    lb $t6, 0($t5)          # Load byte at tablero[t4]
    beq $t6, 32, place_C    # If byte is 32 (empty), place 'C'
    j loop_C                # Otherwise, try again

place_C:
    li $t7, 67              # ASCII code for 'C'
    sb $t7, 0($t5)          # Place 'C' at tablero[t4]
    addi $t3, $t3, 1        # Increment counter
    blt $t3, 4, loop_C      # Repeat until 4 'C' are placed

    # Loop to place 'T' 8 times
    li $t3, 0               # Reset counter for 'T'

loop_T:
    li $v0, 42              # System call for rand()
    syscall
    rem $t4, $v0, $a1       # t4 = rand() % size
    sll $t5, $t4, 2         # Convert index to byte offset (multiply by 4)
    add $t5, $t5, $a0       # Address of tablero[t4]
    lb $t6, 0($t5)          # Load byte at tablero[t4]
    beq $t6, 32, place_T    # If byte is 32 (empty), place 'T'
    j loop_T                # Otherwise, try again

place_T:
    li $t7, 84              # ASCII code for 'T'
    sb $t7, 0($t5)          # Place 'T' at tablero[t4]
    addi $t3, $t3, 1        # Increment counter
    blt $t3, 8, loop_T      # Repeat until 8 'T' are placed

    jr $ra                  # Return from function


# generarNumeroAleatorio: Genera un número aleatorio en un rango.
.text
.globl generarNumeroAleatorio
generarNumeroAleatorio:
    # Arguments: $a0 = min, $a1 = max
    li $v0, 42              # System call for rand()
    syscall
    sub $t0, $a1, $a0       # t0 = max - min
    addi $t0, $t0, 1        # t0 = (max - min + 1)
    rem $v0, $v0, $t0       # v0 = rand() % (max - min + 1)
    add $v0, $v0, $a0       # v0 = v0 + min
    jr $ra                  # Return the random number


# casillaDescubierta: Verifica si una casilla está descubierta.
.text
.globl casillaDescubierta
casillaDescubierta:
    # Arguments: $a0 = tablero (base address), $a1 = index, $a2 = size
    li $v0, 0               # Default return value is 0 (not found)
    beqz $a2, end_casilla   # If size <= 0, return 0
    subi $a2, $a2, 1        # a2 = size - 1
    sll $t0, $a1, 2         # Convert index to byte offset (multiply by 4)
    add $t1, $a0, $t0       # Address of tablero[index]

casilla_loop:
    lb $t2, 0($t1)          # Load byte at tablero[index]
    beq $t2, $a1, found     # If found, set return value to 1
    addi $t1, $t1, 4        # Move to the next element
    addi $a1, $a1, 1        # Increment index
    bne $a1, $a2, casilla_loop

found:
    li $v0, 1               # Set return value to 1 (found)

end_casilla:
    jr $ra                  # Return from function

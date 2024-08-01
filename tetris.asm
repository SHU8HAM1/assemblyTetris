#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Name, Student Number, UTorID, official email
# Student2: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed) 
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# Hard Features:
# 1. Implemented all tetronimos
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

tetromino_I: .word 0, 0, 0, 0
             .word 0xff0000, 0xff0000, 0xff0000, 0xff0000
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0
 # tetronimo_test: .word 0xff0000, 0x00ff00, 0xff0000, 0xff0000
 # .word 0xff0000, 0x00ff00, 0x00ff00, 0xff0000
 # .word 0xff0000, 0xff0000, 0x00ff00, 0xff0000
 # .word 0xff0000, 0xff0000, 0xff0000, 0xff0000

tetromino_J: .word 0x00eeee, 0, 0, 0
             .word 0x00eeee, 0x00eeee, 0x00eeee, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

tetromino_L: .word 0, 0, 0xf3feb8, 0
             .word 0xf3feb8, 0xf3feb8, 0xf3feb8, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

tetromino_O: .word 0, 0xb4e600, 0xb4e600, 0
             .word 0, 0xb4e600, 0xb4e600, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

tetromino_S: .word 0, 0xff0f7b, 0xff0f7b, 0
             .word 0xff0f7b, 0xff0f7b, 0, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

tetromino_T: .word 0, 0xffbc0a, 0, 0
             .word 0xffbc0a, 0xffbc0a, 0xffbc0a, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

tetromino_Z: .word 0x9381ff, 0x9381ff, 0, 0
             .word 0, 0x9381ff, 0x9381ff, 0
             .word 0, 0, 0, 0
             .word 0, 0, 0, 0

START_POINT: .word 12

OFFSET: .word 8

MAX_X: 192
MAX_Y: 8064


##############################################################################
# Mutable Data
##############################################################################

GRID: .word 0: 200

CURRENT_TETRONIMO: 
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0
            rotate_state: .word 0
            
# Current x and y store the position of the domino in the grid
current_x: .word 0   # Store it in multiples of 4
current_y: .word 0  # Store it in multiples of 4

ROTATED_TETRONIMO:
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0
            .word 0, 0, 0, 0


##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    jal DRAW_WALL
    jal CHECKER_BACKGROUND
    la $t1, tetromino_I
    la $t2, tetromino_J
    la $t3, GRID
    jal LOAD_TETRONIMO
    jal LOAD_GRID
    jal CHECKER_BACKGROUND
    jal DRAW_GRID

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1

    li 		$v0, 32
	li 		$a0, 1
	syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    # li $v0, 32
    # li $a0, 800
    # syscall
    # j down_movement
    
    b game_loop

keyboard_input:                     # A key is pressed
    lw $a3, 4($t0)                  # Load second word from keyboard
    beq $a3, 115, down_movement
    beq $a3, 119, rotate_movement
    beq $a3, 97, left_movement
    beq $a3, 100, right_movement
    beq $a3, 32, drop_block
    
    b game_loop

down_movement: li $a1, 0
    j move
rotate_movement: li $a1, 9
    j rotate
right_movement: li $a1, 1
    j move
left_movement: li $a1, -1
    j move

drop_block:
    li $a1, 0
    jal CHECKER_BACKGROUND
    jal MOVE_FUNCTION
    jal DRAW_GRID

    lw $t9, current_y
    beq $t9, $zero, jump_to_game
    
    li $v0, 32
    li $a0, 50
    syscall
    
    j drop_block

jump_to_game:
    b game_loop


rotate: jal CHECKER_BACKGROUND
    jal ROTATE_TETRONIMO
    jal DRAW_GRID
    b game_loop

move: 
    jal CHECKER_BACKGROUND
    jal MOVE_FUNCTION
    jal DRAW_GRID

    b game_loop


DRAW_WALL:
    li $t1, 0xffffff
    lw $t0, ADDR_DSPL # $t0 = base address for display
    addi $t2, $t0, 88
    addi $t3, $t0, 7680 # The bottom wall begining and index    MAX_Y - 384
    addi $t6, $t0, 7776   #MAX_Y - 384 + 96
    j wall_loop
    
wall_loop:
    sw $t1, 0($t0)
    sw $t1, 0($t2)
    sw $t1, 4($t0)
    sw $t1, 4($t2)
    addi $t0, $t0, 192  # MAX_X
    addi $t2, $t2, 192 # MAX_X
    blt $t0, $t6, wall_loop

bottom_loop:
    sw $t1, 0($t3)
    sw $t1, 192($t3)    # MAX_X
    addi $t3, $t3, 4
    blt $t3, $t6, bottom_loop

wall_exit:
    jr $ra


#   s0 = index for column loop
#   s5 = index for row loop
#   s1 and s2 switch colors and write in the memory
#   s3 = column loop end
#   s4 = row loop end
#   s7 is the index for changing the colors when we go 4 units/ 1 block

CHECKER_BACKGROUND:
    li $t1, 0x6d6e72
    li $t2, 0x231e72
    lw $t0, ADDR_DSPL
    

    addi $t0, $t0, 8 #So that it starts from the first grid in the playable area
    addi $t3, $t0, 80 #Column end
    addi $t4, $t0, 7680 # Row end   # MAX_Y - 384
    addi $t7, $zero, 0
    # Row Index

column_loop:
# Setting s5 to s0 so that it starts at new column
    addi $t5, $t0, 0
    
# Check if s7 is divisible by 4 or 2 to switch the colors
    andi $t8, $t7, 3
    beq $t8, $zero, change_color
    andi $t8, $t7, 1
    beq $t8, $zero, change_again
column_cont:
    addi $t7, $t7, 1
    blt $t0, $t3, row_loop
    jr $ra


change_color:
    li $t1, 0x231f20
    li $t2, 0x6d6e72
    j column_cont

change_again:
    li $t1, 0x6d6e72
    li $t2, 0x231f20
    j column_cont

row_loop:
    sw $t1, 0($t5)
    sw $t1, 192($t5)
    sw $t2, 384($t5)
    sw $t2, 576($t5)
    addi $t5, $t5, 768

    blt $t5, $t4, row_loop
    addi $t0, $t0, 4
    j column_loop
    
    
LOAD_TETRONIMO:
# WE WILL USE s VALUES SINCE WE ARE USING A NESTED FUNCTION CALL TO ROTATE TO RANDOMIZE THE TETRONIMO GENERATION LATER

    la $t0, CURRENT_TETRONIMO # Using s0 to preserve the current_tetronimo since
    # We will randomize it using a function (No need to use function here, but 
    # I have pseudo OCD about stuff)
    
    li $t9, 12 #START POSITION OF THE BLOCK
    sw $t9, current_x
    sw $zero, current_y

    la $t2, tetromino_I

    li $v0, 42
    li $a0, 0
    li $a1, 7
    syscall

    li $t1, 64
    
    mult $a0, $t1
    mflo $t1
    add $t1, $t1, $t2
    
#    la $t1, tetromino_O
    
    li $t2, 16 # Counter end
    li $t3, 0  # t3 is the index, which is why we can use t value
    

loading_loop:
    beq $t3, $t2, tetronimo_load_exit
    lw $t4, 0($t1)
    sw $t4, 0($t0)
    addi $t3, $t3, 1
    addi $t1, $t1, 4
    addi $t0, $t0, 4
    j loading_loop

tetronimo_load_exit:
    jr $ra

LOAD_GRID:
    la $t0, CURRENT_TETRONIMO #tetronimo address

    la $t9, GRID #Grid address to store the word
    lw $t8, current_y
    lw $t7, current_x

# t3 is the current index of the grid
    addi $t2, $zero, 10 # Multiply 10 by t8 to get the current y address in the grid
    mult $t2, $t8
    mflo $t2
    add $t3, $t9, $t2    # Add x to get the exact location
    add $t3, $t3, $t7
    
    li $t4, 0 # t4 is the x position counter
    li $t5, 0 #t5 is the y position counter
    
    addi $t8, $zero, 4 #Column and row end

grid_loop:
    lw $t2, 0($t0)
    beq $t2, $zero, no_block
    sw $t2, 0($t3)

no_block:
    addi $t0, $t0, 4
    addi $t4, $t4, 1
    beq $t4, $t8, next_line
    addi $t3, $t3, 4
    j grid_loop

next_line:
    addi $t5, $t5, 1
    addi $t4, $zero, 0
    addi $t3, $t3, 28
    beq $t5, $t8, grid_exit

    j grid_loop

grid_exit:
    jr $ra

DRAW_GRID:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 8
    la $t1, GRID
    
    li $t2, 10 # Row end
    li $t3, 20 # Grid end
    
    li $t4, 0 # Row index
    li $t5, 0 # Column index
    
outer_loop:    beq $t5, $t3, exit_draw
inner_loop:    beq $t4, $t2, draw_new_line
    lw $t6, 0($t1)
    beqz $t6, go_next
    sw $t6, 0($t0)
    sw $t6, 4($t0)
    sw $t6, 192($t0)
    sw $t6, 196($t0)
    
go_next:
    addi $t4, $t4, 1
    addi $t1, $t1, 4
    addi $t0, $t0, 8
    j inner_loop
    
draw_new_line: 
    addi $t5, $t5, 1
    addi $t0, $t0 , 304
    addi $t4, $zero, 0
    j outer_loop

exit_draw:
    jr $ra

ROTATE_TETRONIMO:
    la $t0, CURRENT_TETRONIMO
    la $t1, ROTATED_TETRONIMO
    
    addi $sp, $sp, -4       # PUSH ra since we will call muttiple functions
    sw $ra, 0($sp)
    
    addi $t0, $t0, 0  # Start reading from 0 in current tetronimo
    addi $t9, $t1, 12    # And start writing it to 4th position in rotated teronimo
    
    li $t2, 16
    li $t3, 0   # x counter(current tetronimo)
    li $t4, 0  # y counter (current tetronimo)
    
outer_rotation:    beq $t4, $t2, check_rotation
inner_rotation:    beq $t3, $t2, next_rotation_line 
    lw $t5, 0($t0)
    sw $t5, 0($t9)
    addi $t0, $t0, 4
    addi $t3, $t3, 4
    addi $t9, $t9, 16
    j inner_rotation

next_rotation_line:
    addi $t9, $t1, 12
    addi $t3, $zero, 0
    addi $t4, $t4, 4
    sub $t9, $t9, $t4
    j outer_rotation
    
check_rotation:

    lw $t6, current_x
    lw $t7, current_y
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    addi $sp, $sp, -4
    sw $t7, 0($sp)
    
    jal CLEAR_TETRONIMO
    
    jal CHECK_COLLISION
    
    lw $t8, 0($sp)
    addi $sp, $sp, 4
    
    bne $t8, $zero, exit_rotation
    
    la $t0, CURRENT_TETRONIMO
    la $t1, ROTATED_TETRONIMO
    li $t2, 0
    li $t3, 64

mapping_loop:
    beq $t3, $t2, exit_rotation
    lw $t4, 0($t1)
    sw $t4, 0($t0)
    addi $t2, $t2, 4
    addi $t1, $t1, 4
    addi $t0, $t0, 4
    j mapping_loop

exit_rotation:
    jal LOAD_GRID
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


CHECK_COLLISION: # return 1 if found collision, else return 0

# POP Y FIRST, THEN POP X, THEN ROTATION
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    la $t3, GRID

    li $t4, 0 # t4 is the x position counter
    li $t5, 0 #t5 is the y position counter
    
    addi $t6, $zero, 10 # Multiply 10 by t8 to get the current y address in the grid
    mult $t2, $t6
    mflo $t6
    add $t6, $t6, $t3    # Add x to get the exact location
    add $t3, $t6, $t1

    # Now we have the tetronimo address in t3
    addi $t7, $zero, 16        # Loop end, checks if the line has ended, or the whole loop has ended

tetronimo_loop: beq $t5, $t7, no_collision
line_loop: beq $t4, $t7, next_collision_line
    
    lw $t8, 0($t0)
    beqz $t8, go_to_next
    add $t9, $t4, $t1
    li $t6, 40    # Checks x out of bounds
    bge $t9, $t6, collision_detected
    bltz $t9, collision_detected
    add $t9, $t5, $t2        # Checks y out of bounds
    addi $t6, $zero, 80
    bge $t9, $t6, collision_detected
    bltz $t9, collision_detected

    lw $t9, 0($t3)       # Check color clash
    bne $t9, $zero, collision_detected

go_to_next: addi $t0, $t0, 4
    addi $t3, $t3, 4
    addi $t4, $t4, 4
    j line_loop 

next_collision_line: li $t4, 0
    addi $t3, $t3, 24
    addi $t5, $t5, 4
    j tetronimo_loop

collision_detected: 
    li $t9, 1
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    j exit_collision
    
no_collision:
    addi $sp, $sp, -4
    sw $zero, 0($sp)

exit_collision:
    jr $ra
    
MOVE_FUNCTION:

    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)

    move $t0, $a1
    la $t9, CURRENT_TETRONIMO
    
    lw $s1, current_x
    lw $s2, current_y
    li $t3, 9
    
    # We will be calling check collision so do it before branching
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    bltz $t0, left_direction 
    beqz $t0, down_direction 
    beq $t0, $t3, up_direction 

# We will use temporary variable t3 to add to current_x, current_y which will be used in check_collision and to load the grid

# PUSH X FIRST ALWAYS

# IT IS RIGHT DIRECTION NOT DOWN DIRECTION, USED IT FOR TESTING
right_direction: addi $s3, $s1, 4
    
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)

    
    jal CLEAR_TETRONIMO
    
    jal CHECK_COLLISION
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $t3, $zero, exit_function
    
    sw $s3, current_x

    j exit_function

left_direction: addi $s3, $s1, -4
    
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)

    
    jal CLEAR_TETRONIMO
    
    jal CHECK_COLLISION
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $t3, $zero, exit_function    
    sw $s3, current_x

    j exit_function

up_direction: addi $s3, $s2, -4
    
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)

    
    jal CLEAR_TETRONIMO
    
    jal CHECK_COLLISION
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $t3, $zero, exit_function

    sw $s3, current_y
    j exit_function

down_direction: addi $s3, $s2, 4
    
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)


    jal CLEAR_TETRONIMO
    jal CHECK_COLLISION
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $t3, $zero, new_tetro
    sw $s3, current_y
    j exit_function
    
    addi  $sp, $sp, -4
    sw $zero, 0($sp)    

new_tetro:
    jal LOAD_GRID
    
    jal CHECK_HORIZ_LINES
    
    jal LOAD_TETRONIMO

exit_function:
    jal LOAD_GRID
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    lw $s3, 0($sp)
    addi $sp, $sp, 4
    lw $s2, 0($sp)
    addi $sp, $sp, 4
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra


CLEAR_TETRONIMO:
    la $t0, CURRENT_TETRONIMO #tetronimo address

    la $t9, GRID #Grid address to store the word
    lw $t8, current_y
    lw $t7, current_x

# t3 is the current index of the grid
    addi $t2, $zero, 10 # Multiply 10 by t8 to get the current y address in the grid
    mult $t2, $t8
    mflo $t2
    add $t3, $t9, $t2    # Add x to get the exact location
    add $t3, $t3, $t7
    
    li $t4, 0 # t4 is the x position counter
    li $t5, 0 #t5 is the y position counter
    
    addi $t8, $zero, 4 #Column and row end

clear_loop:
    lw $t2, 0($t0)
    beq $t2, $zero, clear_next
    sw $zero, 0($t3)

clear_next:
    addi $t0, $t0, 4
    addi $t4, $t4, 1
    beq $t4, $t8, clear_next_line
    addi $t3, $t3, 4
    j clear_loop

clear_next_line:
    addi $t5, $t5, 1
    addi $t4, $zero, 0
    beq $t5, $t8, clear_exit
    addi $t3, $t3, 28

    j clear_loop

clear_exit:
    jr $ra
    
CHECK_HORIZ_LINES:

    addi $sp, $sp, -4   # Push ra onto the stack first since we are using s registers and nested calls
    sw $ra, 0($sp)
    
# Store all the registers in stack
    
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    
###############################################

# Now we loop through the lines and use another function to check and clear

    lw $s0, current_y   # Give $s0 current y value
    
    jal CHECK_HORIZONTAL_LINE
    addi $s0, $s0, 4
    sw $s0, current_y
    
    jal CHECK_HORIZONTAL_LINE
    addi $s0, $s0, 4
    sw $s0, current_y
    
    jal CHECK_HORIZONTAL_LINE
    addi $s0, $s0, 4
    sw $s0, current_y
    
    jal CHECK_HORIZONTAL_LINE
    
    # Now we restore everything back and exit the function since we are done

    lw $s0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
CHECK_HORIZONTAL_LINE:

    lw $t0, current_y
    li $t1, 80
    
    # If current y is greater than or equal to 80
    bge $t0, $t1, exit_check_horizontal
    
    li $t1, 10
    
    mult $t0, $t1
    mflo $t0
    
    la $t1, GRID
    add $t0, $t0, $t1   # Now t0 has the address of the line
    
    # Now we need to loop through line and see if we find any zeroes
    
    li $t1, 0   # Counter that checks if we are done
    li $t2, 10  # End of counter
    
horizontal_loop:
    beq $t2, $t1, horizontal_line_detected
    lw $t3, 0($t0)
    beqz $t3, exit_check_horizontal # Exit as soon as you see a zero
    addi $t1, $t1, 1
    addi $t0, $t0, 4
    j horizontal_loop
    
horizontal_line_detected:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal CLEAR_HORIZONTAL_LINE
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
exit_check_horizontal:
    jr $ra

CLEAR_HORIZONTAL_LINE:
    la  $t0, GRID    
    
    lw $t1, current_y
    li $t2, 10
    
    mult $t1, $t2
    mflo $t1
    add $t1, $t1, $t0    
    
    addi $t2, $t1, -40
    
    add $t3, $t1, $zero # Used in internal loop
    add $t4, $t2, $zero # Used in internal loop
    
    addi $t5, $zero, 40 # End for internal loop
    addi $t6, $zero, 0    # Counter for internal loop
    
external_loop: beq $t1, $t0, finish_first_row
internal_loop: beq $t6, $t5, go_up
    
    lw $t7, 0($t4)
    sw $t7, 0($t3)
    
    addi $t3, $t3, 4
    addi $t4, $t4, 4
    addi $t6, $t6, 4
    
    j internal_loop

go_up:
    addi $t2, $t2, -40
    addi $t1, $t1, -40
    li $t6, 0
    
    add $t3, $t1, $zero
    add $t4, $t2, $zero
    j external_loop

finish_first_row:

    li $t8, 0
    li $t9, 40

last_loop:    
    beq $t8, $t9, exit_clearing
    sw $zero, 0($t0)
    addi $t0, $t0, 4
    addi $t8, $t8, 4
    j last_loop

exit_clearing:  jr $ra
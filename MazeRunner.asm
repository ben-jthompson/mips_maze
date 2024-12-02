# Maze Runner 									
			.data	
maze: 			.word 1,1,1,1,1,1,1,1,1,9,1
			.word 1,0,0,0,1,0,0,0,0,0,1
			.word 1,1,1,0,1,1,1,0,1,1,1
			.word 1,0,0,0,0,0,1,0,1,0,1
			.word 1,0,1,0,1,1,1,0,1,0,1
			.word 1,0,1,0,0,0,0,0,1,0,1
			.word 1,1,1,1,1,0,1,1,1,0,1
			.word 1,0,0,0,0,0,1,0,0,0,1
			.word 1,0,1,0,1,0,1,1,1,0,1
			.word 1,0,1,0,1,0,0,0,0,0,1
			.word 1,1,1,0,1,1,1,0,1,1,1
			.word 0,0,0,0,0,0,1,0,0,0,1
			.word 1,1,1,1,1,1,1,1,1,1,1


num_column: .word 11    # needs to be updated based on maze structure 
num_row:    .word 13    # needs to be updated based on maze structure 

step_counter:	.word 0
mistake_counter: .word 0

pos_row_col:    .word 11, -1  # starting row & column position

invalid_msg: .asciiz "Invalid move! Try again...\n"
wall_msg:  .asciiz "\nYou hit a wall!\n"
exit_msg:  .asciiz "\nCongratulations! You reached the exit.\n"
step_msg: .asciiz "Total number of moves: "
mistake_msg: .asciiz "\nNumber of mistakes: "
inside_wall_msg: .asciiz "\nYou can't go into another wall, go to an open space.\n"

command: .asciiz "Enter f/b/r/l: \n"

.text
.globl main

main:		
	la $s1, mistake_counter  # Initialise $s1 
	la $s0, step_counter     # Initialise $s0 
	
blabla:	#get command from user
	li $v0,4
	la $a0, command
	syscall
while:		
	# read the command
	li $v0,12
	syscall	

	move $t0, $v0 	# load command into t0
	
	#load current position into s registers
	la $t1, pos_row_col
	lw $s2, 0($t1)          # s2 = row
	lw $s3, 4($t1)		# s3 = col	
				
	# check command
	li $t4, 'f'
	beq $t0, $t4, forward
	li $t4, 'b'
	beq $t0, $t4, back
	li $t4, 'r'
	beq $t0, $t4, right
	li $t4, 'l'
	beq $t0, $t4, left
		
	j while

forward: 
	addi $s3, $s3, 1	# col +1
	j check_position
	
back:
	subi $s3, $s3, 1	# col -1
	j check_position

right:
	addi $s2, $s2, 1	# row +1
	j check_position
	
left:
	subi $s2, $s2, 1	# row -1
	j check_position

	# check if current position == 1 or 0
check_position:
	
	# check if out of bounds 
	# check for row 
	la $t0, num_row
	lw $t1, 0($t0)
	bge $s2, $t1, out_bounds
    	bltz $s2, out_bounds	
	
	# check for col
	la $t0, num_column
	lw $t1, 0($t0)
	bge $s3, $t1, out_bounds
    	bltz $s3, out_bounds
	
	la $s5, maze		#load base address of maze
	
	# load and calculate row offset 
	la $t0, num_column
	lw $t1, 0($t0)
	mul $s4, $t1, 4
	
	# pos = base adress + (row_index * num_rows * 4) + (col_index * 4)    each row has X elements; 4*X = 4X bytes 
	mul $t6, $s2, $s4	#row offset 
	add $s5, $s5, $t6	# add row index to base
	mul $t7, $s3, 4		# col offset (always 4)
	add $s5, $s5, $t7	# add col inex to base
	lw  $s7, 0($s5)		# load current pos into s7
	
	# check if 0, turn off in_wall flag, if 1, check for in_wall flag 
	li $t0, 0
	beq $s7, $t0, turn_off_flag
	li $t3, 3		# already in wall (2) + wall pos (1)
	add $t4 , $s7, $s6
	beq $t4, $t3, inside_wall

update_pos:	# update pos_row_col
	la $t1, pos_row_col
	sw $s2, 0($t1)      # Save updated row to pos_row_col
	sw $s3, 4($t1)      # Save updated column to pos_row_col
	
	# step counter += 1
	lw $t9, 0($s0)
	addi $t9, $t9, 1
	sw $t9, 0($s0)
	
	# check if it's a wall (1)
	li $t2, 1
	beq $s7, $t2, hit_wall
	
	#check if exit (9)
	li $t2, 9
	beq $s7, $t2, exit
	
	j while
	
out_bounds: # print invalid_msg
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	# mistake +1
	lw $t9, 0($s1)
	addi $t9, $t9, 1
	sw $t9, 0($s1)
	
	j while 
	
hit_wall:
	# set wall flag to True (2)
	li $s6, 2
	
	# print wall_msg
	li $v0, 4
	la $a0, wall_msg
	syscall 
	
	# mistake counter += 1
	lw $t9, 0($s1)
	addi $t9, $t9, 1
	sw $t9, 0($s1)
	
	j while
	
inside_wall:
	li $v0, 4
	la $a0, inside_wall_msg
	syscall
	
	# mistake counter += 1
	lw $t9, 0($s1)
	addi $t9, $t9, 1
	sw $t9, 0($s1)
	
	j while

turn_off_flag:
	li $s6, 0
	j update_pos

exit:	# print exit_msg
	li $v0, 4
	la $a0, exit_msg
	syscall
	
	# print steps taken string
	li $v0, 4
	la $a0, step_msg
	syscall
	# print steps taken integer
	li $v0, 1
	lw $a0, 0($s0)
	syscall
	
	# print mistake_msg string
	li $v0, 4
	la $a0, mistake_msg
	syscall
	# print mistake_counter integer
	li $v0, 1
	lw $a0, 0($s1)
	syscall
	
	# exit program
	li $v0, 10
	syscall
	
	
	

			.data	
maze: 			.word 1,1,9,1
			.word 1,1,0,1
			.word 0,0,0,1

start:			.word 2,0 	#represented as a 1D array, also the same as the position tracker (row, column)
step_counter:		.word 0
mistake_counter: 	.word 0
wallState:		.word 1
numColumns:		.word 4

command: 		.asciiz "Enter a direction: R for right, L for left, F for forward, B for backward:\n" 		#movement message
invalid:   		.asciiz "Invalid move!Try Again...\n"  								#invalid command message
victory:		.asciiz "Congratualtions! You reached the exit."						#Message on completion

			.text
			.globl main
main:	
					#Initialise the start position of the robot
	la $t0, start   		#the base address of the array which stores the start position
    	lw $t1, 0($t0)  		#loads the row index into $t1 (0 offset meaning it is the first value in the 'start' array. So here the bottom row is selected)
    	lw $t2, 4($t0)  		#loads column index into $t2 (4 offset meaning it is the second value in the 'start array. So here the first column is selected)

					#Initialise variables that will be used for the condition logic in the while loop
	addiu $s0, $0, 1 		#sets the contents of register $s0 to 1
 	addu $s1, $0, $0 		#sets the contents of register $s1 to 0
 	
 					#initialise the wallstate 
 	lw $s5, wallState
 	
	while: beq $s0, $s1, done	#If register $s0 is equal to register $s1 it will branch to the label 'done:' 
					#get prompt from user
	li $v0,4 			#we store the immediate value 4 into register $v0, so that when we run syscall, the computer knows to print our 'command' variable which contains the string "Enter f/b/r/l: \n"
	la $a0,command 			#this puts the address of our command variable into register $a0, so that the syscall knows where to find the string to print 
	syscall 
	
					#read user input (single character)
	li $v0, 12   			#we store the immediate value 12 into register $v0, so that when we run syscall, the computer knows to read the single character the user will input. Will store the character into $v0
	syscall
	
					#store the value
	move $t3, $v0 			#Because we don't want to lose track of the value in $v0 (it is a common register used often) we will move the contents to register $t0. This contains the player's move
	
					#now we need to do a much of if statements in MIPS32 to see what kind of move was inputted
	li $t4, 'f' 			#this will load the value 'f' into the contents of register $t1. 'f' is converted into hex via the ascii table
	beq $t3, $t4 forwardMove 	#this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'forwardMove'
	
	li $t4, 'b'  			#this will load the value 'b' into the contents of register $t1. 'b' is converted into hex via the ascii table           
	beq $t3, $t4, backwardMove 	#this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'backwardMove'

	li $t4, 'r'  			#this will load the value 'r' into the contents of register $t1. 'r' is converted into hex via the ascii table           
	beq $t3, $t4, rightwardMove 	#this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'rightwardMove'

	li $t4, 'l'  			#this will load the value 'l' into the contents of register $t1. 'l' is converted into hex via the ascii table          
	beq $t3, $t4, leftwardMove 	#this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'leftwardMove'
	
					#this will ensure that the user cannot enter any values not specified in the options given (acts as an 'else' statement because this code would never be run if they had enetered the right value, since they would have branched past this)
	li $v0, 4			#lets the system know that when its called it needs to run syscall 4, which is the operation for printing a string
	la $a0, invalid 		# this loads the address of the string, 'invalid', that needs to be printed by the system       
	syscall
	j while      			#this will jump back to the beginning of the while loop
	
	forwardMove:
		add $t2, $t2, 1         # this will increase the column index by 1
		move $s6, $t3           # this will track last move as 'f'
		j checkPosition		# the check if this move is allowed it will jump to the checkPosition function


	backwardMove:
		sub $t2, $t2, 1         # this will decrease the column index by 1
		move $s6, $t3           # this will track last move as 'b'
		j checkPosition


	rightwardMove:
		add $t1, $t1, 1         # this will increase the row index by 1
		move $s6, $t3           # this will track last move as 'r'
		j checkPosition


	leftwardMove:
		sub $t1, $t1, 1         # this will decrease the row index by 1
		move $s6, $t3           # this will track last move as 'l'
		j checkPosition
		
	checkPosition:			#calulating the desired target index position in our maze
					
		lw $t5, numColumns  	#first part of the equation 'index = (rows * numColumns) + columns'
		mul $t6, $t1, $t5   	#index = (rows * numColumns)
		add $t6, $t6, $t2   	# + columns (t6 now stores the index)		
		
					#finding out whether the desired index position is a 1 or 0 by using the address of our index we calculated
		la $s2, maze 		#the formula being used is 'address = baseAddress + (index * 4)
		mul $s3, $t6, 4   	#index * 4
		add $s3, $s3, $s2 	# + baseAddress
		
					
		lw $s4, 0($s3)		#now we need to load the value of the item at the index we want so that we can run comparisons on it
		beq $s4, $s5 inWall	#if the destination value is 1 and equals the wallstate variable then it will branch to the inWall block of code
		beq $s4, 9 exitMaze
		
		j while 		#else it returns to our original while loop for the next move
		
	
	inWall: 			#the idea of this function is to add robustness to the code. If the user enters a wall they will stay their until they enter the correct reverse command.
		li $v0, 4		#Re-promt for the user's input
		la $a0, invalid
		syscall
		
		li $v0, 12		#Retrieves an integer from the user
		syscall
		move $t3, $v0           #stores the current move into $t3 (remember the previous move is stored in $s6)
						
		li $t4, 'f'		#this is load up the value of 'f' into the register (same as before)
		beq $s6, $t4, checkBackward		#if the previous move was forward, it will jump to the checkBackward function to see if the current move is backward (the correct reverse move in this scenario)
		li $t4, 'b'
		beq $s6, $t4, checkForward		#if the previous move was backward, it will jump to the checkForward function to see if the current move is forward (the correct reverse move in this scenario)
		li $t4, 'r'
		beq $s6, $t4, checkLeftward		#if the previous move was rightward, it will jump to the checkLeftward function to see if the current move is leftward (the correct reverse move in this scenario)
		li $t4, 'l'
		beq $s6, $t4, checkRightward		#if the previous move was leftward, it will jump to the checkRightward function to see if the current move is rightward (the correct reverse move in this scenario)				  
		
		j inWall		#if none of the inputs are correct, the code will jump back to the beginning of the inWall function and re ask promts unil the user selects the correct reversal move
		
	checkBackward:
		bne $t3, 'b', inWall  	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		sub $t2, $t2, 1       	#carries out the backward move
		j while	
	
	checkForward:
		bne $t3, 'f', inWall  	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		add $t2, $t2, 1       	#carries out the forward move
		j while

	checkLeftward:
		bne $t3, 'l', inWall  	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		add $t1, $t1, 1       	#carries out the leftward move
		j while

	checkRightward:
		bne $t3, 'r', inWall  	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		sub $t1, $t1, 1       	#carries out the rightward move
		j while	

	exitMaze:
					#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		li $v0, 4
		la $a0, victory
		syscall
		j done

	done:
					# Exit program
		li $v0, 10
		syscall

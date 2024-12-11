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

start:			.word 11, -1 	#represented as a 1D array, also the same as the position tracker (row, column)
step_counter:		.word 0
mistake_counter: 	.word 0
wallState:		.word 1
numColumns:		.word 11
numRows:		.word 13

start_str:		.asciiz "\nWelcome to the MIPS Maze Solver!\nEnter direction: f to move into the maze!"
command: 		.asciiz "\nEnter a direction: r for right, l for left, f for forward, b for backward:\n" 		#movement message
invalid:   		.asciiz "\nInvalid move! Try Again...\n"  								#invalid command message
invalid_wall:		.asciiz "\nInvalid move! Reverse your move to get out.\n"
wall:			.asciiz "\nYou hit a wall! Reverse your move to get out.\n"					
boundary:		.asciiz "\nOut of Bounds! Stay inside the maze.\n"
step:			.asciiz "\nTotal number of moves: "
mistake:		.asciiz "\nNumber of Mistakes: "
victory:		.asciiz "\nCongratulations! You reached the exit."						#Message on completion

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
 	
 	li $v0, 4
 	la $a0, start_str
 	syscall
 	
	while: beq $s0, $s1, done	#If register $s0 is equal to register $s1 it will branch to the label 'done:' 
					#get prompt from user
	li $v0,4 			#we store the immediate value 4 into register $v0, so that when we run syscall, the computer knows to print our 'command' variable which contains the string "Enter f/b/r/l: \n"
	la $a0,command 			#this puts the address of our command variable into register $a0, so that the syscall knows where to find the string to print 
	syscall 
	
					#read user input (single character)
	li $v0, 12   			#we store the immediate value 12 into register $v0, so that when we run syscall, the computer knows to read the single character the user will input. Will store the character into $v0
	syscall
	
					#store the value
	move $t3, $v0 			#Because we don't want to lose track of the value in $v0 (it is a common register used often) we will move the contents to register $t3. This contains the player's move
	
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
		j increaseStepCounter  	# Jump to increaseStepCounter


	backwardMove:
		sub $t2, $t2, 1         # this will decrease the column index by 1
		move $s6, $t3           # this will track last move as 'b'
		j increaseStepCounter


	rightwardMove:
		add $t1, $t1, 1         # this will increase the row index by 1
		move $s6, $t3           # this will track last move as 'r'
		j increaseStepCounter


	leftwardMove:
		sub $t1, $t1, 1         # this will decrease the row index by 1
		move $s6, $t3           # this will track last move as 'l'
		j increaseStepCounter
		
	
	increaseStepCounter:
		lw $t4, step_counter	# loading step_counter into $t4
		addi $t4, $t4, 1 	# increasing the step_counter by 1
		sw $t4, step_counter	# store updated step counter 
		j checkBound		# jump to checkBound
	
	
	
	
	
	
	checkBound:
		bltz $t1, rejectMove 		#If row < 0 jump to rejectmove
		lw $t4, numRows
		bge $t1, $t4, rejectMove 	#If row >= numRows jump to rejectMove
		
		bltz $t2, rejectMove 		#If col < 0 jump to rejectMove
		lw $t4, numColumns
		bge $t2, $t4, rejectMove 	#If col >= numcols jump to rejectmove
		
		j checkPosition			#If within bounds jump to checkPosition
		

	rejectMove: #If on boundary reject last move
		lw $t4, mistake_counter		# loading mistake_counter into $t4
		addi $t4, $t4, 1 		# increase mistake counter by 1
		sw $t4, mistake_counter 	# store updated mistake counter
		
		
		li $v0, 4
		la $a0, boundary		#print boundary message
		syscall
		
		beq $s6, 'f', rejectForward	
		beq $s6, 'b', rejectBack
		beq $s6, 'r', rejectRight
		beq $s6, 'l', rejectLeft
		
		j while   			# jump to main loop
		
	rejectForward: #Undo forward move
		sub $t2, $t2, 1
		j while	
		
	rejectBack: #Undo back move
		addi $t2, $t2, 1
		j while	
	
	rejectRight: #Undo right  move
		sub $t1, $t1, 1
		j while					
																																										
	rejectLeft: #Undo left move
		addi $t1, $t1, 1
		j while	
	
	checkPosition:			#calulating the desired target index position in our maze
					
		lw $t5, numColumns  	#first part of the equation 'index = (rows * numColumns) + columns'
		mul $t6, $t1, $t5   	#index = (rows * numColumns)
		add $t6, $t6, $t2   	# + columns (t6 now stores the index)		
		
					#finding out whether the desired index position is a 1 or 0 by using the address of our index we calculated
		la $s2, maze 		#the formula being used is 'address = baseAddress + (index * 4)
		mul $s3, $t6, 4   	#index * 4
		add $s3, $s3, $s2 	# + baseAddress
		
					
		lw $s4, 0($s3)		#now we need to load the value of the item at the index we want so that we can run comparisons on it
		beq $s4, $s5 inWallStr	#if the destination value is 1 and equals the wallstate variable then it will branch to the inWall block of code
		beq $s4, 9 exitMaze
		
		j while 		#else it returns to our original while loop for the next move
		
	
	inWallStr:
		li $v0, 4		#Re-promt for the user's input
		la $a0, wall
		syscall
		j inWall
	
	invalidStr:
		lw $t4, step_counter	# loading step_counter into $t4
		addi $t4, $t4, 1 	# increasing the step_counter by 1
		sw $t4, step_counter	# store updated step counter 
		li $v0, 4
		la $a0 invalid_wall
		syscall
		j inWall
	
	inWall: 			#the idea of this function is to add robustness to the code. If the user enters a wall they will stay their until they enter the correct reverse command.
		lw $t4, mistake_counter		# loading mistake_counter into $t4
		addi $t4, $t4, 1 		# increase mistake counter by 1
		sw $t4, mistake_counter 	# store updated mistake counter
		
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
		bne $t3, 'b', invalidStr	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		sub $t2, $t2, 1       	#carries out the backward move
		j while	
	
	checkForward:
		bne $t3, 'f', invalidStr 	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		add $t2, $t2, 1       	#carries out the forward move
		j while

	checkLeftward:
		bne $t3, 'l', invalidStr 	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		sub $t1, $t1, 1       	#carries out the leftward move
		j while

	checkRightward:
		bne $t3, 'r', invalidStr 	#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		add $t1, $t1, 1       	#carries out the rightward move
		j while	
	
	exitMaze:
					#checks to see if the current input is equal to what the correct reversal command is, if it isn't it will run the 'inWall' loop until it is satisfied
		li $v0, 4
		la $a0, victory
		syscall
		
		li $v0, 4		#printing mistake message
		la $a0, mistake
		syscall
		
		lw $a0, mistake_counter	#printing number of mistakes
		li $v0, 1
		syscall
		
		li $v0, 4		#printing step message
		la $a0, step
		syscall
		
		lw $a0, step_counter	#printing number of steps
		li $v0, 1
		syscall
		
		j done


	done:
					# Exit program
		li $v0, 10
		syscall

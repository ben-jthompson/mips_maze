			.data	
maze: 			.word 1,1,9,1
			.word 1,1,0,1
			.word 0,0,0,1

start:			.word 2,0 #represented as a 1D array, also the same as the position tracker
step_counter:		.word 0
mistake_counter: 	.word 0

command: 		.asciiz "Enter f/b/r/l: \n" #movement message
invalid:   		.asciiz "Invalid command!\n"  # Invalid command message
wall_hit:   		.asciiz "You hit a wall!\n"   # Wall collision message
exit_msg:   		.asciiz "You found the exit!\n" # Exit message
			.text
			.globl main
main:	
	#Initialise the start position of the robot
	la $t0, start   #the base address of the array which stores the start position
    	lw $t1, 0($t0)  #loads the row index into $t1 (0 offset meaning it is the first value in the 'start' array. So here the bottom row is selected)
    	lw $t2, 4($t0)  #loads column index into $t2 (4 offset meaning it is the second value in the 'start array. So here the first column is selected)

	#Initialise variables that will be used for the condition logic in the while loop
	addiu $s0, $0, 1 #sets the contents of register $s0 to 1
 	addu $s1, $0, $0 #sets the contents of register $s1 to 0
 	
	while: beq $s0, $s1, done #If register $s0 is equal to register $s1 it will branch to the label 'done:' 
	#get prompt from user
	li $v0,4 #we store the immediate value 4 into register $v0, so that when we run syscall, the computer knows to print our 'command' variable which contains the string "Enter f/b/r/l: \n"
	la $a0,command #this puts the address of our command variable into register $a0, so that the syscall knows where to find the string to print 
	syscall 
	
	#read user input (single character)
	li $v0, 12   #we store the immediate value 12 into register $v0, so that when we run syscall, the computer knows to read the single character the user will input. Will store the character into $v0
	syscall
	
	#store the value
	move $t3, $v0 #Because we don't want to lose track of the value in $v0 (it is a common register used often) we will move the contents to register $t0
	
	#now we need to do a much of if statements in MIPS32 to see what kind of move was inputted
	li $t4, 'f' #this will load the value 'f' into the contents of register $t1. 'f' is converted into hex via the ascii table
	beq $t3, $t4 forwardMove #this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'forwardMove'
	
	li $t4, 'b'  #this will load the value 'b' into the contents of register $t1. 'b' is converted into hex via the ascii table           
	beq $t3, $t4, backwardMove #this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'backwardMove'

	li $t4, 'r'  #this will load the value 'r' into the contents of register $t1. 'r' is converted into hex via the ascii table           
	beq $t3, $t4, rightwardMove #this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'rightwardMove'

	li $t4, 'l'  #this will load the value 'l' into the contents of register $t1. 'l' is converted into hex via the ascii table          
	beq $t3, $t4, leftwardMove #this will compare the values of the move that the user inputted ($t3) with what the value should be in ($t4). If they are equal, we know that the user wants to move forward, so it will branch to the label 'leftwardMove'
	
	#this will ensure that the user cannot enter any values not specified in the options given (acts as an 'else' statement because this code would never be run if they had enetered the right value, since they would have branched past this)
	li $v0, 4 #lets the system know that when its called it needs to run syscall 4, which is the operation for printing a string
	la $a0, invalid # this loads the address of the string, 'invalid', that needs to be printed by the system       
	
	syscall
	j while      #this will jump back to the beginning of the while loop
	
	forwardMove:
		
	backwardMove:
		
	rightwardMove:
		add $t2, $t2, 1 #this will increase the column index by 1
		j done #this is temporary just so i can check if the registers contain the appropiate values. in the final code this would have some further logic to check if the move is valid by checking the maze and then looping back to 'while:'
	leftwardMove:
		sub $t2, $t2, 1 #this will increase the column index by 1
		j done #this is temporary just so i can check if the registers contain the appropiate values. in the final code this would have some further logic to check if the move is valid by checking the maze and then looping back to 'while:'
	done:
	# Exit program
	li $v0, 10              # Syscall 10: Exit
	syscall

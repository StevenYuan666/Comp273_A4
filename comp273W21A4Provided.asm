# TODO: PUT YOUR NAME AND STUDENT NUMBER HERE!!!
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE

.data
TestNumber:	.word 0		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD1		# Procedure used by test 2, set to MADD1 or MADD2		
				
Size:		.word 64		# matrix size (MUST match size of matrix loaded for test 0 and 1)

Afname: 		.asciiz "A64.bin"
Bfname: 		.asciiz "B64.bin"
Cfname:		.asciiz "C64.bin"
Dfname:	 	.asciiz "D64.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:		la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
        		syscall	

compareMatrix:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check
		
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

testFromFile:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		move $a0, $s0	# A
		move $a1, $s1	# B
		move $a2, $s2	# C
		move $a3, $s7	# n
		
		la $ra ReturnHere
		la $t0 Proc	# function pointer
		lw $t0 ($t0)	
		jr $t0		# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	move $a0 $s2	# C
		move $a1 $s3	# D
		move $a2 $s7	# n
		jal check	# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
	        	syscall         	# call operating system to exit	

compareMADD:	la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

###############################################################
# mallocMatrix( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0	
mallocMatrix: 	mul  $a0, $a0, $a0	# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall			# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  	# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
		# $v0 contains number of characters read (0 if end-of-file, negative if error).
                	# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0 $a3	# start address
		add $t1 $a3 $a2  	# end address
loadloop:	lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16	# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	li $v0 43
		syscall		# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	sw $zero 0($a0)	# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra



######################################################
# TODO: void subtract( float* A, float* B, float* C, int N )  C = A - B 
subtract: 	jr $ra

#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm: 	jr $ra

#################################################
# TODO: void check ( float* C, float* D, int N )
# Print the forbeneous norm of the difference of C and D
check: 		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )
MADD1: 		jr $ra

#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 		jr   $ra

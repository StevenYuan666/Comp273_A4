# TODO: Ye Yuan 260921269
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
subtract: 	mul $a3 $a3 $a3 #compute n * n as the total steps needed to iterate
subHelp:	lwc1 $f4,($a0) #load the entry of A
		lwc1 $f6,($a1) #load the entry of B
		sub.s $f4 $f4 $f6 #substract corresponding entry
		swc1 $f4,($a2) #store the difference in C
		addi $a0 $a0 4 #move to the next entry
		addi $a1 $a1 4 #move to the next entry
		addi $a2 $a2 4 #move to the next entry
		addi $a3 $a3 -1 #sub one step
		bgt $a3 $zero subHelp #if not meet the total steps, iterate again
		jr $ra #jump back
#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm: mul $a1 $a1 $a1 #compute n * n as the total steps needed to iterate
		li $t0 0 #initialize the sum as zero
		mtc1 $t0 $f6
froHelp:	lwc1 $f4,($a0) #load current entry of A
		mul.s $f4 $f4 $f4 #calculate the square
		add.s $f6 $f6 $f4 #add to the sum
		addi $a0 $a0 4 #move to the next entry
		addi $a1 $a1 -1 #sub one step
		bgt $a1 $zero froHelp #iterate again
		sqrt.s $f0 $f6 #take square root of the sum
		jr $ra
#################################################
# TODO: void check ( float* C, float* D, int N )
# Print the forbeneous norm of the difference of C and D
check: 		sw $ra,-4($sp) #store the address to jump back to the stack first
		move $s4 $a0 #store the passed in arguments
		move $s5 $a1
		move $s6 $a2
		move $a0 $s4
		move $a1 $s5 #initialize the arguments
		move $a2 $s4
		move $a3 $s6
		jal subtract #call the function
		move $a0 $s4 #initialize the arguments
		move $a1 $s6
		jal frobeneousNorm #call the function
		li $t0 0
		mtc1 $t0 $f12
		add.s $f12 $f12 $f0 #move the square root returned to the register f12
		li $v0 2
		syscall #print out
		lw $ra,-4($sp) #load the address to jump back
		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )
MADD1: 		li $t0 0 #initialize i
iLoop:		li $t1 0 #initialize j
jLoop:		li $t2 0 #initialize k
kLoop:		la $t3 ($a0) #A
		la $t4 ($a1) #B
		la $t5 ($a2) #C
		li $t6 4
		mul $t6 $t0 $t6 # i * 4 * n
		mul $t6 $t6 $a3
		li $t7 4
		mul $t7 $t1 $t7 # j * 4
		add $t6 $t6 $t7 #offset of c
		add $t5 $t5 $t6 #get c[i][j]
		li $t6 4
		mul $t6 $t0 $t6 # i * 4 * n
		mul $t6 $t6 $a3
		li $t7 4
		mul $t7 $t2 $t7 # k * 4
		add $t6 $t6 $t7 #offset of a
		add $t3 $t3 $t6 #get a[i][k]
		li $t6 4
		mul $t6 $t2 $t6 # k * 4 * n
		mul $t6 $t6 $a3
		li $t7 4
		mul $t7 $t1 $t7 # j * 4
		add $t6 $t6 $t7 #offset of b
		add $t4 $t4 $t6 #get b[k][j]
		lwc1 $f4 ($t3) #load A
		lwc1 $f6 ($t4) #load B
		lwc1 $f8 ($t5) #load C
		mul.s $f4 $f4 $f6
		add.s $f8 $f8 $f4
 		swc1 $f8 ($t5) #store to C
		addi $t2 $t2 1
		blt $t2 $a3 kLoop
		addi $t1 $t1 1
		blt $t1  $a3 jLoop
		addi $t0 $t0 1
		blt $t0 $a3 iLoop
		jr $ra

#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 		li $t0 0 #initialize jj
jjLoop:		li $t1 0 #initialize kk
kkLoop:		li $t2 0 #initialize i
iLoop2:		move $t3 $t0 #initialize j
jLoop2:		li $t8 0
		mtc1 $t8 $f4 #initialize the sum
		move $t4 $t1 #initialize k
kLoop2:		la $t5 ($a0) #A
		la $t6 ($a1) #B
		li $t8 4
		mul $t8 $t2 $t8 # i * 4 * n
		mul $t8 $t8 $a3
		li $t9 4
		mul $t9 $t4 $t9 # k * 4
		add $t8 $t8 $t9 #offset of a
		add $t5 $t5 $t8 #get a[i][k]
		li $t8 4
		mul $t8 $t4 $t8 # k * 4 * n
		mul $t8 $t8 $a3
		li $t9 4
		mul $t9 $t3 $t9 # j * 4
		add $t8 $t8 $t9 #offset of b
		add $t6 $t6 $t8 #get b[k][j]
		lwc1 $f6 ($t5) #load A
		lwc1 $f8 ($t6) #load B
		mul.s $f6 $f6 $f8 #get product
		add.s $f4 $f4 $f6 #add to the sum
		addi $t4 $t4 1
		li $t8 0
		addi $t8 $t1 4 #kk + bsize
		blt $a3 $t8 loadN1
		j loadKKB
loadN1:		move $t8 $a3
loadKKB:	blt $t4 $t8 kLoop2
		la $t7 ($a2) #C
		li $t8 4
		mul $t8 $t2 $t8 # i * 4 * n
		mul $t8 $t8 $a3
		li $t9 4
		mul $t9 $t3 $t9 # k * 4
		add $t8 $t8 $t9 #offset of a
		add $t7 $t7 $t8 #get c[i][j]
		lwc1 $f6 ($t7)
		add.s $f6 $f6 $f4 # c[i][j] += sum
		swc1 $f6 ($t7)
		addi $t3 $t3 1
		li $t8 0
		addi $t8 $t0 4 #jj + bsize
		blt $a3 $t8 loadN2
		j loadJJB
loadN2:		move $t8 $a3
loadJJB:	blt $t3 $t8 jLoop2 #j < min (jj + bsize, n)
		addi $t2 $t2 1 #i ++
		blt $t2 $a3 iLoop2 #i < n
		addi $t1 $t1 4 # kk += bsize
		blt $t1 $a3 kkLoop #kk < n
		addi $t0 $t0 4 # jj += bsize
		blt $t0 $a3 jjLoop #jj < n
		jr   $ra

################# Data segment #####################
.data
messReq:		.asciiz "Please enter a string up to 30 chars of integers between 00-77 seperated by $\n"	
numOfPairs:	.asciiz "\nThe number of pairs is: "
notValid:		.asciiz "Wrong input/n"
messArrSort:	.asciiz "The array after the sort is: "
printNUM: 	.asciiz "\nPrinting NUM array: "
printSortarray:	.asciiz "\nPrinting sortarray: "
printcoma:	.asciiz ", "

stringocta: .byte 0:31
NUM: .space 10
sortarray: .space 10
sllby2: .space 10
# $s0=stringocta
# $s1=NUM
# $s2=sortarray
# $s3=number of pairs
################## macro ######################################
.macro printString( %str)
	la $a0, %str	# string to print
	li $v0, 4		# print string code
	syscall
.end_macro 

.macro printInt(%int)
	move $a0,%int
	li $v0,1
	syscall
.end_macro
################## Code segment #####################
.text
.globl main

main:
	la $s0, stringocta
	la $s1, NUM
	la $s2, sortarray
	li $s5, 0 			#counter
	
	printString messReq		
	
	move $a0, $s0	
	li $a1, 31			# $a1=31
	li $v0, 8			# print stringocta
	syscall			# read input srting fron keyboard
	
	move $t0, $s0
	li $v0, 0			# $v0=0, the number of pairs 
	j is_valid
	
is_valid: # checks if input is legal. if legal returns in $vo=number of pairs in stringocta. if not $vo=0.	
	lbu $t1, 0($t0)				# load $t0 into $t1
	beq $t1, '\n', exit_is_valid		# if \n, we are done
	bge $t1, '8', invalid_input 		# if $t1>=8
	addiu $t0, $t0, 1 			# $t0+=1
	lbu $t1, 0($t0)				# load $t0 into $t1
	bge $t1, '8', invalid_input 		# if $t1>=8
	addiu $t0, $t0, 1 			# $t0+=1
	lbu $t1, 0($t0)				# load $t0 into $t1
	bne $t1, '$', invalid_input 		# if $t1!= $ , then => go to invalidInput
	addiu $t0, $t0, 1			# $t0+=1
	addiu $v0, $v0, 1			# $v0+=1
	j is_valid
	
invalid_input: 
	printString notValid
	li $v0, 0
	j main

exit_is_valid:
	move $s3, $v0 
	printString numOfPairs
	move $a0, $s3
	li $v0, 1
	syscall	
	j convert
	
convert: # convert pairs into NUM in decimal value
	move $t0, $s0		# $t0=stringocta, 
	move $t1, $s1		# $t1=NUM
	move $t2, $s3 		# $t2=num of pairs
	li $t3, 10			# $t3=10
	j pairIntoDec
	
pairIntoDec:	
	lbu $t4, 0($t0)		# $t4=current char value
	subiu $t4, $t4, 48	# $t4-=48
	mul $t5, $t4, $t3	# $t5=$t4*10
	addiu $t0, $t0, 1 	# $t0=next char
	lbu $t4, 0($t0)		# $t4=current char value
	subiu $t4, $t4, 48	# $t4-=48
	addu $t6, $t5, $t4	# $t6=$t5+$t4
	addiu $t0, $t0, 2 	# $t0=next next  char
	sb $t6, 0($t1)		# NUM[$a3-$t3]=$t6
	addiu $t1, $t1, 1
	subiu $t2, $t2, 1	# $t3-=1
	beqz $t2, print		# if $t3=0, then => go to print
	j pairIntoDec

print: 
	printString printNUM
	move $t0, $s1
	li $t2, 0
	j printArray

 printArray: 
	lbu $t1, 0($t0)
	printInt $t1
	printString printcoma
	addiu $t2, $t2, 1
	addiu $t0, $t0, 1
	bne $t2, $s3, printArray
	j copy_array
	
copy_array:
	move $t0, $s1		# $t0=NUM
	move $t1, $s2 		# $t1=sortarray
	li $t3, 0 		
loop:
	lbu $t4, 0($t0)
	sb $t4, 0($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	addiu $t3, $t3, 1
	beq $t3, $s3, sort
	j loop
	

bubble_sort: # iloop:
	addiu $t1, $t1, 1	# i++
	move $t2, $t1		# j=i		
	blt $t1, $s3, jloop
	li $t2, 0
	move $t0, $s2
	printString printSortarray
	j printSortedArray
		
swap:
	subiu $t0, $t0, 1
	sb $a1, 0($t0)
	addiu $t0, $t0, 1
	sb $a0, 0($t0)
	
jloop:		
	addiu $t2, $t2, 1			# j++
	beq $t2, $s3, bubble_sort		# if j==n
	lbu $a0, 0($t0)
	addiu $t0, $t0, 1
	lbu $a1, 0($t0)
	bgt  $a0, $a1, swap
	j jloop
		
		
sort:
	move $t0, $s2 		# $t0=sortarray
	li $t1, 0			# $t1=i
	li $t2, 0			# $t2=j
	#addiu $t4, $t4, 1
	#bne $t4, $s3, bubble_sort
	j bubble_sort

		
 printSortedArray:
	lbu $t1, 0($t0)
	printInt $t1
	printString printcoma
	addiu $t2, $t2, 1
	addiu $t0, $t0, 1
	bne $t2, $s3, printSortedArray
		
Exit:	
	li $v0, 10	# Exit program
	syscall






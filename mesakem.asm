################# Data segment #####################
.data
messReq:			.asciiz "Enter max 10 pairs of integers between 00-77 seperated by $:\n"	
notValid:			.asciiz "Wrong input/n"
numOfPairs:		.asciiz "\nNumber of pairs: "
printNUM: 		.asciiz "\nPrinting NUM array: "
printSortarrayBefor:	.asciiz "\nSortarray before sorting: "
printSortedArray:	.asciiz "\nThe array after the sort is: "
printBye:			.asciiz "\nbye bye..."
printcoma:		.asciiz ", "
stringocta:		.byte 0:31
NUM:			.space 10
sortarray:			.space 10
sllby2:			.space 10

################## macro ######################################
.macro printStr( %str)
	la $a0, %str		# string to print
	li $v0, 4			# print string code
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
	la $s0, stringocta	# $s0=stringocta
	la $s1, NUM		# $s1=NUM
	la $s2, sortarray	# $s2=sortarray
	li $s3, 0			# $s3=number of pairs
	
	printStr messReq			
	move $a0, $s0		# $a0=stringocta
	li $a1, 31			# $a1=31 (max number of bits)
	li $v0, 8			# print stringocta
	syscall			# read input srting from keyboard into $a0=stringocta
	
	move $t0, $s0		# $t0=stringocta
	li $v0, 0			# $v0=0, the number of pairs 
	jal is_valid
	
	move $t0, $s0		# $t0=stringocta, 
	move $t1, $s1		# $t1=NUM
	move $t2, $s3 		# $t2=num of pairs
	li $t3, 10			# $t3=10
	jal convert
	
	printStr printNUM
	move $t0, $s1		# $t0=NUM
	li $t2, 0			# $t2=counter
	jal print
	
	move $t0, $s1		# $t0=NUM
	move $t1, $s2 		# $t1=sortarray
	li $t2, 0 			# $t2=counte
	jal copy_array
	
	printStr printSortarrayBefor
	move $t0, $s2		# $t0=sortarray
	li $t2, 0			# $t2=counter
	jal print
	
	#move $t0, $s2 		# $t0=sortarray
	li $t1, 0			# $t1=i, $t2=j
	jal sort 
	
	printStr printSortedArray
	move $t0, $s2
	li $t2, 0
	jal print
	
	j Exit
	
	
is_valid:					# checks if input is legal; if legal $vo=numOfPairs; else $vo=0.	
	lbu $t1, 0($t0)			# load $t0 into $t1
	beq $t1, '\n', valid		# if \n, we are done
	bge $t1, '8', invalid 		# if $t1=>8
	addiu $t0, $t0, 1 		# $t0+=1
	lbu $t1, 0($t0)			# load $t0 into $t1
	bge $t1, '8', invalid 		# if $t1=>8
	addiu $t0, $t0, 1 		# $t0+=1
	lbu $t1, 0($t0)			# load $t0 into $t1
	bne $t1, '$', invalid 		# if $t1!= $ , then => go to invalidInput
	addiu $t0, $t0, 1		# $t0+=1
	addiu $v0, $v0, 1		# $v0+=1
	j is_valid
	
invalid: 
	printStr notValid
	li $v0, 0
	j main

valid:
	move $s3, $v0 				# $s3=number of pairs
	printStr numOfPairs
	move $a0, $s3
	li $v0, 1
	syscall	
	jr $ra
	
	
convert: 					# convert pairs into NUM in decimal value	
	lbu $t4, 0($t0)			# $t4=current char value
	subiu $t4, $t4, 48		# $t4-=48
	mul $t5, $t4, $t3		# $t5=$t4*10
	addiu $t0, $t0, 1 		# $t0=next char
	lbu $t4, 0($t0)			# $t4=current char value
	subiu $t4, $t4, 48		# $t4-=48
	addu $t6, $t5, $t4		# $t6=$t5+$t4
	addiu $t0, $t0, 2 		# $t0=next next  char
	sb $t6, 0($t1)			# NUM[$a3-$t3]=$t6
	addiu $t1, $t1, 1		# $t1+=1
	subiu $t2, $t2, 1		# $t2-=1
	bgt $t2, $zero, convert	# if $t2>0, then => go to convert
	jr $ra


print: 					# print arrays
	lbu $t1, 0($t0)
	printInt $t1
	printStr printcoma
	addiu $t2, $t2, 1
	addiu $t0, $t0, 1
	bne $t2, $s3, print
	jr $ra
			
	
copy_array:
	lbu $t4, 0($t0)
	sb $t4, 0($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	addiu $t2, $t2, 1
	blt $t2, $s3, copy_array
	jr $ra
	

sort: 						# main bubble sort loop
	move $t0, $s2 			# $t0=sortarray
	move $t2, $t1			# j=i	
	addiu $t1, $t1, 1		# i++	
	blt $t1, $s3, sort_loop
	jr $ra
			
swap:
	subiu $t0, $t0, 1
	sb $a1, 0($t0)
	addiu $t0, $t0, 1
	sb $a0, 0($t0)
	
sort_loop:					# nested bubble sort loop		
	addiu $t2, $t2, 1		# j++
	beq $t2, $s3, sort		# if j==n
	lbu $a0, 0($t0)
	addiu $t0, $t0, 1
	lbu $a1, 0($t0)
	bgt  $a0, $a1, swap
	j sort_loop
				

Exit:						# Exit program
	printStr printBye
	li $v0, 10	
	syscall
	
	
	

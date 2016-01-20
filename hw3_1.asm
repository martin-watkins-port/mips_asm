#################################################################
# Homework 3 - Part 1  						#
# Author:            					        #
# 	Martin Watkins 						#
#      						#
# Goal:                						#
#	Compute four different values from a root integer	#
#	given by the user of the program.			#
# Date:								#
#	10/25/15						#
#################################################################
.data 
	prompt: .asciiz "Enter a positive integer, any positive integer: "
	prompt2: .asciiz "The number of 0's in the right half: "
	prompt3: .asciiz "The number of 1's in the left half: "
	prompt4: .asciiz "The highest power of 4 that evenly divides the integer: "
	prompt5: .asciiz "The value of the of the smallest decimal digit: "
	newline: .asciiz "\n"
.text
	main:
	
	#Display prompt
	li $v0, 4
	la $a0, prompt
	syscall
	
	#Store integer
	li $v0, 5
	syscall
	
	#move result to the stack
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	
	#display the number of 0's in the right half of the 32-bit representation of the integer
	jal rightHalf 
	li $v0, 4
	la $a0, prompt2
	syscall
	li $v0, 1
	la $a0, 0($a3)
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#display the number of 1's in the left halfs of the 32-bit representation of the integer
	jal leftHalf 
	li $v0, 4
	la $a0, prompt3
	syscall
	li $v0, 1
	la $a0, 0($a3)
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#display highest power of four that divides the given integer
	jal power4
	li $v0, 4
	la $a0, prompt4
	syscall
	li $v0, 1
	la $a0, 0($a3)
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#display the smallest digit in the the decimal representation of the integer
	jal small
	li $v0, 4
	la $a0, prompt5
	syscall
	li $v0, 1
	la $a0, 0($a3)
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#end of program
	li $v0, 10
	syscall
	
	#function to count number of zeros in right half
	rightHalf:
	
		addi $s0, $zero, 0 #i = 0
		lw $a2, 0($sp) #load integer from stack
		addi $sp, $sp, 4 #replace stack vals
		addi $a3, $zero, 0 #initialize zero count to 0
		addi $s1, $a2, 0 #store pre-bit-manip integer for later functions
		
		loop: 
		addi $sp, $sp, -4 #save return address
		sw $ra, 0($sp)
		
		beq $s0, 16, exit #if i < 16, get out
		andi $t7, $a2, 0x00000001 #check if first bit is 1 or 0
		beq $t7, 0, inc #if the last bit = 0, increment zero counter and i
		bne $t7, 0, n1	#if the last bit != 0, increment just i and advance loop
		
		inc: addi $a3, $a3, 1
		srl $a2, $a2, 1
		addi $s0, $s0, 1 #i++
		b loop
		
		n1:
		srl $a2, $a2, 1
		addi $s0, $s0, 1 #i++
		b loop
		
		exit:
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		jr $ra
		
	#function to compute the number of one's in the left half
	leftHalf:
		li $s0, 0 #i = 0
		addi $a2, $s1, 0 #load integer from s1
		addi $s2, $s1, 0 #store pre-bit-manip integer for later functions
		li $a3, 0 #initialize count to 0
		
		loop1: 
		addi $sp, $sp, -4 #save return address
		sw $ra, 0($sp)
		
		beq $s0, 16, exit1 #if i < 16, get out
		andi $t6, $a2, 0x80000000 #check if last bit is 1 or 0
		bne $t6, 0, incr #if the last bit = 1, increment one's count and i
		beq $t6, 0, n2	 #if the last bit !=1, increment only i and advance loop
		
		incr: addi $a3, $a3, 1
		sll $a2, $a2, 1
		addi $s0, $s0, 1 #i++
		b loop1
		
		n2: 
		sll $a2, $a2, 1
		addi $s0, $s0, 1 #i++
		b loop1
		
		exit1:
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		jr $ra
	
	#function to compute the highest power of 4 that evenly divides the given integer
	power4:
		li $a2, 0 #clear register
		addi $a2, $s2, 0 #load $a2 with integer
		addi $s3, $s2, 0 #store pre-bit-manip integer for later functions
		li $a3, 0 #initialize count to 0
		
		loop2:
		addi $sp, $sp, -4 #save return address
		sw $ra, 0($sp)
		
		andi $t6, $a2, 0x0000003 #check if last two bits are both zero
		beq $t6, 0, incr1 #if the last bits = 00, increment counter
		bne $t6, 0, exit2 #if not, then we have reached the end of the loop!
		
		incr1: addi $a3, $a3, 1
		srl $a2, $a2, 2 #shifting right by 2, since we are measuring the powers of four
		b loop2
		
		exit2: 
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		jr $ra
	
	#function to compute the smallest digit in the decimal representation of the given integer
	small:
		li $t1, 10
		li $a2, 0 #clear register
		addi $a2, $s3, 0 #load $a2 with integer
		li $a3, 0 #smallest digit = 0
		
		div $a2, $t1
		mfhi $s2 #remainder --- aka the decimal digits when divided by 10 ---
		mflo $a2 #set a2 to quotient
		addi $a3, $s2, 0 #initialize the smallest digit
		
		loop3:
		addi $sp, $sp, -4 #save return address
		sw $ra, 0($sp)
		
		beq $a2, 0, exit3 #if quotient = 0, we exit the loop
		div $a2, $t1
		mfhi $s2 #remainder --- aka the decimal digits when divided by 10 ---
		mflo $a2#set a2 to quotient
		slt $t0, $s2, $a3 #if remainder < saved smallest digit, $t0 = 1
		beq $t0, 1, small_help #if remainder < saved smallest digit, saved smallest digit = remainder
		beq $t0, 0, loop3 #else continue looping
		
		small_help:
		li $a3, 0
		addi $a3, $s2, 0 
		b loop3
		
		exit3:
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		jr $ra
		

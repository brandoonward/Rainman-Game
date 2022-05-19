#############################################################################################
#
# Montek Singh
# COMP 541 Final Projects
# 4/1/2022
#
# This is a MIPS program that tests the MIPS processor, and the full set of I/O devices:
# VGA display, keyboard, acelerometer, sound and LED lights, using a very simple animation.
#
# This program assumes the memory-IO map introduced in class specifically for the final
# projects.  In MARS, please select:  Settings ==> Memory Configuration ==> Default.
#
#############################################################################################
#
# This program is suitable for board deployment, NOT for Vivado simulation (because there is
# no tester provided that can model the keyboard, accelerometer, etc.).
#
#############################################################################################
startAgain:
.data 0x10010000            # Start of data memory
a_sqr:  .space 4
a:  .word 3
.eqv display_addr 0x10000000
.text 0x00400000                # Start of instruction memory
.globl main

main:
    lui     $sp, 0x1001         # Initialize stack pointer to the 1024th location above start of data
    ori     $sp, $sp, 0x1000    # top of the stack will be one word below
                                #   because $sp is decremented first.
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame
    
mainGame:                      # ($s1, $s2) hold the current (X, Y) coordinates
    li  $s1, 20         # initialize to middle screen col (X=20)
    li  $s2, 29         # initialize to middle screen row (Y=15)
    li $t4, 0		 # initialize score to 0
    li $t5, 0		# initialize counter to 0
    li $t6, 0		#initialize lights to 0
    li $s4, 0		# initialize seed to 0 for gen5
    li $s5, 0		# initialize seed to 0 for gen39
    li $a0, 1
    move $a1, $s1       # put X in argument $a1
    move $a2, $s2       # put Y in argument $a2
    jal putChar_atXY    # $a0 is char, $a1 is X, $a2 is Y
    
startLoop:
    li  $a0, 15         # pause for 0.15 second
    jal pause_and_getkey # and read key during the pause
    beq $v0, 1, animate_loop
    beq $v0, 2, animate_loop
    j startLoop

animate_loop:   
    move $t8, $a1	#store old X value
    move $t9, $a2	#store old Y value
    addi, $t5, $t5, 1 #add one to the counter
    
    beq $t5, 2, genRandom5	#if the counter reaches 10, it spawns an item using gen5
check:
    li $s7, 0 # initialize screen counter to 0 before checking and moving
    beq $t5, 5, checkAndMove #check all characters on the screen for rain/lightning and move them accordingly
    
getNextPlayerSpot:

    li $a0, 0	#grass character replacement
    move $a1, $t8	#old X load in
    move $a2, $t9	#old Y load in
    jal putChar_atXY	#put old character in place of where player moved from
    
    
    li  $a0, 1		# put character code 1 in argument $a0
    move $a1, $s1       # put X in argument $a1
    move $a2, $s2       # put Y in argument $a2
    jal putChar_atXY    # put player at new XY
    	
    move $a0, $t4
    jal display
    
    #jal get_accelX      # get front to back board tilt angle
    #sll $a0, $v0, 12    # multiply by 2^12
    #jal put_sound       # create sound with that as period
    
    #jal get_accelY      # get left to right tilt angle
    #srl $v0, $v0, 5     # keep leftmost 4 bits out of 9
    #li  $a0, 1
    #sllv $a0, $a0, $v0  # calculate 2^v0 (one hot pattern, 2^0 to 2^15)
    #jal put_leds        # one LED will be lit
    
    li  $a0, 15         # pause for 0.15 second
    jal pause_and_getkey # and read key during the pause
    move $s0, $v0       # save key read in $s0
    
    #jal sound_off       # turn sound off (previous note has played during the pause)
    
    beq $s0, $0, animate_loop   # start over if no valid key is returned
    
key1:
    bne $s0, 1, key2
    addi    $s1, $s1, -1        # move left
    slt $1, $s1, $0     # make sure X >= 0
    beq $1, $0, animate_loop
    li  $s1, 0          # else, set X to 0
    j   animate_loop

key2:
    bne $s0, 2, animate_loop
    addi    $s1, $s1, 1         # move right
    slti    $1, $s1, 40     # make sure X < 40
    bne $1, $0, animate_loop
    li  $s1, 39         # else, set X to 39
    j   animate_loop

            
genRandom5:
	add $t2, $s4, 3
	slti $1, $t2, 6		#check if less than 6
	beq $1, $0, subTime5	#if larger go subtract
	bne $1, $0, returnNum5	#if not return value in $v0
returnGen5:
	move $s4, $v0		#store previous value for next use

genRandom39:
	
	add $t2, $s5, 29
	slti $1, $t2, 41	#check if less than 41
	beq $1, $0, subTime39	#if larger go subtract
	bne $1, $0, returnNum39 #if smaller just return number in $v0
returnGen39:
	move $s5, $v1		#move value into $s5 so it is used next time.


spawnItem:
	beq $v0, 5, spawnLightning

spawnRain:
	
	#generate random location 0-39
	li $a0, 2
	move $a1, $v1	# put random X
	li $a2, 3	# static number for spawn item ceiling
	jal putChar_atXY
	
	j check
	
spawnLightning:
	
	#generate random location 0-39 in $v1
	li $a0, 3
	move $a1, $v1	#random X
	li $a2, 3	# static number for spawn item ceiling
	jal putChar_atXY
	
	j check

checkAndMove:
	li $t5, 0		#reset counter to 0 when checking
	li $s7, 30
	
yLoop:
	li $s6, 0		#reset X to 0
	addi $s7, $s7, -1	#add 1 to Y
	slti $1, $s7, 3		#if Y is less than 3
	bne $1, $0, getNextPlayerSpot	#if greater than 3, continue
xLoop:
	move $a2, $s7		#else, get new character at xy location
	move $a1, $s6
	jal getChar_atXY	#get character at XY
	
	bne $v0, 0, swapDown
swapLoop:
	addi $s6, $s6, 1
	slti $1, $s6, 40
	beq $1, $0, yLoop
	bne $1, $0, xLoop
	
	


swapDown:
	beq $a2, 29, swapLast
	move $a0, $v0
	addi $a2, $a2, 1
	jal getChar_atXY	#get character below anon sprite
	beq $v0, 1, score	#if that character is the player jump to score
	jal putChar_atXY	#else just do normal stuff
grassPlace:	#place grass
	li $a0, 0
	addi $a2, $a2, -1
	jal putChar_atXY
	
	j swapLoop
swapLast:
	beq $v0, 1, swapLoop
	li $a0, 0
	jal putChar_atXY	#else just do normal stuff
	
	j swapLoop
score:
	beq $a0, 3, die		#if lightning character, die
	addi $t4, $t4, 1	#else add 1 to score
	li $a0, 286344
	jal put_sound
	li $a0, 25
	jal pause
	li $a0, 186344
	jal put_sound
	li $a0, 15
	jal pause
	li $a0, 0
	jal put_sound
	j grassPlace

die:
	li $a0, 6 	#load in death sprite
	jal putChar_atXY
	slti $1, $t4, 4
	beq $1, 1, subLess
	addi $t4, $t4, -3
backDie:
	li $a0, 422219
	jal put_sound
	li $a0, 25
	li $a0, 382219
	jal put_sound
	li $a0, 100
	jal pause
	jal pause
	li $a0, 0
	jal put_sound


deathloop:
	li $a0, 15
	jal pause_and_getkey
	beq $v0, 0, deathloop
	beq $v0, 1, animate_loop
	beq $v0, 2, animate_loop

	
	
subTime39:
	addi $t2, $t2, -41
	move $v1, $t2
	j returnGen39
	
subTime5:
	addi $t2, $t2, -5
	move $v0, $t2
	j returnGen5
returnNum5:
	move $v0, $t2
	j returnGen5
returnNum39:
	move $v1, $t2
	j returnGen39
                         
resetGame:
	li $s7, 0
	li $s6, 0
	li $a0, 5
resetLoop:
	move $a1, $s6
	move $a2, $s7
	jal putChar_atXY
	addi $s6, $s6, 1
	beq $s6, 40, secondRow
	j resetLoop
secondRow:
	li $s7, 1
	li $s6, 0
secondLoop:
	move $a1, $s6
	move $a2, $s7
	jal putChar_atXY
	addi $s6, $s6, 1
	beq $s6, 40, bCloudRow
	j secondLoop
	
bCloudRow:
	li $a0, 4
	li $s7, 2
	li $s6, 0
thirdLoop:
	move $a1, $s6
	move $a2, $s7
	jal putChar_atXY
	addi $s6, $s6, 1
	beq $s6, 40, fillGrass
	j thirdLoop

fillGrass:
	li $a0, 0
	li $s7, 2

lastLoop:
	li $s6, 0
	addi $s7, $s7, 1
	slti $1, $s7, 30
	bne $1, 1, resetReg
actualLoop:
	move $a1, $s6
	move $a2, $s7
	jal putChar_atXY
	addi $s6, $s6, 1
	beq $s6, 40, lastLoop
	j actualLoop
subLess:
	li $t4, 0
	j backDie
resetReg:
	li $v0, 0
	li $v1, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0,
	li $t8, 0
	li $t9, 0

	
	j main
	
display:
     sw $a0, display_addr($0)
     jr $ra
    ###############################
    # END using infinite loop     #
    ###############################
  
                # program won't reach here, but have it for safety
end:
    j   end             # infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################



.include "procs_board.asm"

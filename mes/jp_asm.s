@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                    @DATA SECTION@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Data section - initialized values
.data
.align 3 @ This alignment is critical - to access our "huge" value, it must
@ be 64 bit aligned

huge: .octa 0xAABBCCDDDDCCBBAA
big: .word 0xAAAABBBB
num: .byte 0xAB
str2: .asciz "Hallo Welt!"
count: .word 0                      @ This is an initialized 32 bit value
game_time: .word 0                  @holds game time for A4
game_delay: .word 0                 @holds game delay for A4
game_light: .word 0                 @holds game target for A4
mili_secs: .word 1000               @holds multiplication value for game time
actual_delay: .word 0               @holds the user entered delay

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Assignments & Labs From Here @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global jp_led_demo_a4 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type jp_led_demo_a4, %function @ Declares that the symbol is a function (not strictly required)

@constants
.equ Delay, 0xFFFFFF                            @just to make a delay for the win loops

@ Function Declaration : int jp_led_demo_a4(int delay, int target_light, int game_time)
@ Function Description : This function is the main function for the Assignment 4. This Function gets the values from the user,
@ or the default values and performs the game.
@ Input: delay, target, game_time
@ Returns: r0 ~ Means Success
@ Here is the actual jp_led_demo_a4 function

jp_led_demo_a4:

push {r4-r10, lr}

mov r10, r0                                     @holds delay, moved to r10
ldr r6, =actual_delay                           @r6 will hold the address of the actual_delay Variable
str r10, [r6]                                   @copying value of delay to the global variable

ldr r9, =game_light                             @holds the address of the global var: game_light
str r1, [r9]                                    @moves the value of target light to global variable

ldr r8, =game_time                              @r8 will hold the address of game_time 
ldr r7, =mili_secs                              @r7 will hold the address of mili_secs
ldr r1, [r7]                                    @getting value from the address
mul r2, r2, r1                                  @multiplying it with the entered game_time
str r2, [r8]                                    @storing the multiplied value to the global variable

mov r9, #7                                      @Stores the led's index
led_on_check_loop_A4:                           @used to turn off all leds on start/Restart
        mov r0, r9                  
        bl BSP_LED_Off                          @Turns off selected led
        subs r9, r9, #1                         @decrements the led counter
        bge led_on_check_loop_A4                @loops back until greater than equal to zero

A4_start_game:                                  @start of the game
    check_game_time:                
        ldr r8, =game_time                      @loads the address of game_time
        ldr r4, [r8]                            @getting the value from the address
        cmp r4, #0                              @comparing it with 0
        beq A4_lose_game                        @if 0 branches to lose
        
        logic_loop:
            ldr r9, =game_light                 @loads the address of the game_light variable
            ldr r4, [r9]                        @loads the value from the address
            
            bl A4_get_accel_values              @reads the accelerometer, led value is returned
            
            cmp r0, r4                          @compares the value with the target led
            beq continue_game                   @if equal branches to continue the game

            b reset_the_delay                   @else resets the delay and counter and checks again for the led.

            continue_game:
                ldr r6, =count                  @loads the count address
                ldr r0, [r6]                    @loads the count value
                cmp r0, #0                      @compares it with 0
                bne check_delay                 @if !=0 branches to check the delay = 0, else loads the delay

                ldr r4, =game_delay             @loads the delay address
                ldr r10, =actual_delay          @loads the actual delay address
                ldr r0, [r10]                   @loads the actual delay value
                str r0, [r4]                    @loads delay to start counting delay

                ldr r6, =count                  @loads the count address
                mov r0, #1                      @moves the value #1 to r0
                str r0, [r6]                    @updates the count value to 1
                
                check_delay:                    @checks for delay = 0
                    ldr r5, =game_delay         @loads the game_delay address
                    ldr r4, [r5]                @gets the value from the address
                
                    cmp r4, #0                  @compares if == 0
                    
                    beq A4_win_game             @if equal, win or loops again

        b A4_start_game

A4_lose_game:                                   @this makes the target light on after losing
ldr r4, =game_light                             @loads the address of game_light
ldr r0, [r4]                                    @gets the value from the address
bl BSP_LED_On                                   @Turns the target led on for lose
b a4_End                                        @branches to the end

reset_the_delay:                                
ldr r4, =game_delay                             @loads the address of game_delay
mov r0, #0                                      @sets r0 to 0
str r0, [r4]                                    @resets delay

ldr r6, =count                                  @gets the address of count 
mov r0, #0                                      @moves 0 to r0
str r0, [r6]                                    @resets count
b A4_start_game                                 @branches back to the game loop

A4_win_game:
mov r10, #2                                     @counter for win lights blink twice
win_loop_A4:
    mov r9, #7                                  @led counter
    led_on_toggle_loop_A4:                      @this loop toggles led on until all led's are on
        mov r0, r9
        bl BSP_LED_On                           @toggles selected led
        subs r9, r9, #1                         @decrements the counter
        bge led_on_toggle_loop_A4               @checks if it greater than equal to zero

    mov r0, #Delay                              @add delay to register 0 from r4
    bl busy_delay                               @calls busy_delay for delay
    
    mov r9, #7                                  @led counter
    led_off_toggle_loop_A4:                     @turns all leds off
        mov r0, r9                      
        bl BSP_LED_Off                          @selected led off from r0
        subs r9, r9, #1                         @decrements the counter
        bge led_off_toggle_loop_A4              @loops until r9>=0

    mov r0, #Delay                              @add delay to register 0 from r4
    bl busy_delay                               @calls busy_delay

subs r10, r10, #1                               @decrements the cycle count.
bgt win_loop_A4                                 @it loops until r10 is greater than 0
b a4_End                                        @branches to the end

a4_End:                                         @defines end of the function
ldr r6, =count                                  @resetting the count at the end
mov r0, #0  
str r0, [r6]
mov r0, #0                                      @denotes Success
pop {r4-r10, lr}
bx lr

.size jp_led_demo_a4, .-jp_led_demo_a4 @@ - symbol size (not strictly required, but makes the debugger happy)


@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global A4_get_accel_values @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type A4_get_accel_values, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int A4_get_accel_values(void)
@ Function Description : This function gets the X High and Y High Values and Converts it into desired led, returns the led to calling function.
@ Input: void
@ Returns: selected led value
@ Here is the actual A4_get_accel_values function

@ constants are declared here:
.equ I2C_add, 0x32 
.equ X_Lo, 0x28
.equ X_Hi, 0x29
.equ Y_Lo, 0x2A
.equ Y_Hi, 0x2B 
.equ read_delay, 0xFFFFFF

A4_get_accel_values:
push {r4, r5, lr}
mov r0, #I2C_add				                @stores I2C address to r0
mov r1, #X_Hi					                @stores x_hi value to r1
bl COMPASSACCELERO_IO_Read		                @calls COMPASSACCELERO_IO_Read to get X_HI value

sxtb r0,r0						                @Converts from 8 bit to 32 bit
mov r4, r0						                @moves r0 to r4

mov r0, #I2C_add				                @stores I2c address to r0
mov r1, #Y_Hi					                @stores y_hi value to r1
bl COMPASSACCELERO_IO_Read		                @calls COMPASSACCELERO_IO_Read to get Y_HI value

sxtb r0, r0						                @coverts into 32 bit
mov r5, r0						                @stores it in r5

@ Condition 1: 
@   if(x>-15 && x<15)
@   { 
@      if(y<-30) { Led 0 } 
@      if(y>30) { led 7 } 
@   }

Condition_1:							        @this condition checks and turns on led 0 and 7
    cmp r4, #-15				                @compares r4 with -15
    ble Condition_2					            @if less than equal it goes to Condition 2
    cmp r4, #14					
    bgt Condition_2					            @if greater than equal goes to Condition 2
    body:						                @body of Condition 1
        cmp r5, #-29			                @compares with -29
        bgt next				                @if greater than -29 jumps to next
        mov r0, #0                              @used to turn led 0 on
        bl Turn_Desired_Led_On                  @calling this function to turn the led On
        b End                                   @branches to End
        next:					                @another condition
            cmp r5, #30                         @compares with 30			
            ble Condition_2                     @if less than equal branches to next Condition              
            mov r0, #7                          @turns led 7 On
            bl Turn_Desired_Led_On              @this function makes the led On
            b End                               @branches to End

@Condition 2:
@   if(x<-15 && x>-30)
@   { 
@      if(y>-30 && y<-15) { Led 1 } 
@      if(y>15 && y<30) { led 5 } 
@   }

Condition_2:							        @this Condition turns on led 1 and 5
    cmp r4, #-30                                @compares the value with -30
    ble Condition_3					            @if condition does not meets jumps to Condition_3
    cmp r4, #-14                                @compares the value with -14
    bgt Condition_3					            @if condition does not meets jumps to Condition_3
    body_2:						                @condition 2 body
        cmp r5, #-30		                    @compares it with -30
        ble next_2				                @if condition does not meets jumps to next_2
        cmp r5, #-14                            @compares with -14
        bgt next_2				                @if condition does not meets jumps to next_2
        mov r0, #1                              @moves 1 to pass to the function
        bl Turn_Desired_Led_On                  @this function turns the desired led On
        b End                                   @branches to End
        next_2:					                @another condition if first one is not meets
            cmp r5, #15                         @compares it with 15
            ble Condition_3			            @if condition does not meets jumps to Condition_3
            cmp r5, #29                         @compares it with 29
            bgt Condition_3			            @if condition does not meets jumps to Condition_3
            mov r0, #5                          @moves 5 to r0
            bl Turn_Desired_Led_On              @turns Led 5 ON
            b End                               @goes to end

@Condition 3:
@   if(x>15 && x<30)
@   { 
@      if(y<-15 && y>-30) { Led 2 } 
@      if(y>15 && y<30) { led 6 } 
@   }

Condition_3:							        @this Condition turns on led 2 and 6
    cmp r4, #15                                 @compares with 15
    ble Condition_4					            @if condition does not meets jumps to Condition_4	
    cmp r4, #29                                 @compares it with 29
    bgt Condition_4					            @if condition does not meets jumps to Condition_4 
    body_3:						                @condition 3 body
        cmp r5, #-30                            @compares it with -30
        ble next_3				                @if condition does not meets jumps to next_3
        cmp r5, #-14                            @compares with -14
        bgt next_3				                @if condition does not meets jumps to next_3
        mov r0, #2                              @moves 2 to r0
        bl Turn_Desired_Led_On                  @turns Led 2 ON
        b End                                   @branches to End
        next_3:					                @another condition
            cmp r5, #15                         @compares it with 15
            ble Condition_4			            @if condition does not meets jumps to Condition_4
            cmp r5, #29                         @compares it with 29
            bgt Condition_4			            @if condition does not meets jumps to Condition_4
            mov r0, #6                          @moves 6 to r0
            bl Turn_Desired_Led_On              @turns the Led 6 ON
            b End                               @goes to end

@Condition 4:
@   if(y>-15 && y<15)
@   { 
@      if(x<-30) { Led 3 } 
@      if(x>30) { led 4 } 
@   }

Condition_4:						            @this Condition turns on led 3 and 4
    cmp r5, #-15                                @compares it with -15
    ble End					                    @if condition does not meets jumps to end    
    cmp r5, #14                                 @compares it with 14
    bgt End				    	                @if condition does not meets jumps to end
    body_4:					                    @condition body
        cmp r4, #-29                            @compares it with -29
        bgt next_4			                    @if condition does not meets jumps to next condition
        mov r0, #3                              @moves 3 to r0
        bl Turn_Desired_Led_On                  @turns the led 3 ON
        b End                                   @branches to End
        next_4:				                    @another condition
            cmp r4, #30                         @compares with 30
            ble End			                    @if condition does not meets jumps to End
            mov r0, #4                          @moves 4 to r0
            bl Turn_Desired_Led_On              @makes led 4 ON
            b End                               @branches to End

End:							                @end label

pop {r4, r5, lr}
bx lr
.size A4_get_accel_values, .-A4_get_accel_values @@ - symbol size (not strictly required, but makes the debugger happy)


@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global Turn_Desired_Led_On @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type Turn_Desired_Led_On, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int Turn_Desired_Led_On(int)
@ Function Description : This function is used to turn on the selected led and returns the same led number.
@ Input: int
@ Returns: int
@ Here is the actual Turn_Desired_Led_On function

Turn_Desired_Led_On:
push {r4, lr}
mov r4, r0                                      @moves the led value to r4( just preserving )
bl BSP_LED_On                                   @makes desired led on

mov r0, #500                                    @acts as a led refresh rate (makes more brighter)
bl busy_delay                                   @calls busy delay for the same reason

mov r0, r4                                      @gets the led value to r0
bl BSP_LED_Off                                  @turns desired led off

mov r0, r4                                      @sends the led value back for the calling function

pop {r4, lr}
bx lr

.size Turn_Desired_Led_On, .-Turn_Desired_Led_On @@ - symbol size (not strictly required, but makes the debugger happy)


@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global jp_a4_timer_tick @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type jp_a4_timer_tick, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : void jp_a4_timer_tick(void)
@ Function Description : This function performs the timer for Assignment 4. Called from Main.c.
@ Input: void
@ Returns: void
@
@ Here is the actual jp_a4_timer_tick function

jp_a4_timer_tick:

push {r9, lr}

ldr r9, =game_time                              @loads the address of game_time
Game_timer:                                     
    ldr r0, [r9]                                @loads the value from the address
    cmp r0, #0                                  @compares it with r0
    ble end_game_timer                          @if less than equals ends
    game_count:                                 
        subs r0, r0, #1                         @subtracts the value from the r0
        str r0, [r9]                            @stores the value back to the address
        cmp r0, #0                              @compares if less than equal to 0
        ble end_game_timer                      @branches to end

end_game_timer:                                 @defines end of game timer
pop {r9, lr}
bx lr

.size jp_a4_timer_tick, .-jp_a4_timer_tick @@ - symbol size (not strictly required, but makes the debugger happy)



@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global jp_a4_delay_tick @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type jp_a4_delay_tick, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : void jp_a4_delay_tick(void)
@ Function Description : This function performs the delay timer for Assignment 4. Called from Main.c.
@ Input: void
@ Returns: void
@
@ Here is the actual jp_a4_delay_tick function

jp_a4_delay_tick:

push {r9, lr}

ldr r9, =game_delay                             @loads the address of game_delay
Game_delay: 
    ldr r0, [r9]                                @loads the value from the address
    cmp r0, #0                                  @compares it with 0
    ble end_game_delay                          @if <=0 ends
    game_delay_count:
        subs r0, r0, #1                         @decrements the timer count
        str r0, [r9]                            @stores the value back to the address
        cmp r0, #0                              @compares it with 0
        ble end_game_delay                      @if <=0 ends

end_game_delay:
pop {r9, lr}
bx lr

.size jp_a4_delay_tick, .-jp_a4_delay_tick @@ - symbol size (not strictly required, but makes the debugger happy)




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Past Assignments & Labs @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ assembly language instructions - Code section (text -> ROM)



@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global jp_led_demo_a3 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type jp_led_demo_a3, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int jp_led_demo_a3(int delay, char* pattern, int target)
@
@ Input: delay, pattern, target
@ Returns: r0
@
@ Here is the actual jp_led_demo_a3 function

jp_led_demo_a3:
push {r4-r10, lr}                  @ I am using registers r4-r10 for this assignment

mov r4, r0                         @ Stores the delay
mov r5, r1                         @ Stores the pattern
mov r6, r2                         @ Stores the target light
mov r7, #0                         @ Used for the offset index

mov r9, #7                          @Stores the led's index
    led_on_check_loop_A3:           @used to turn off all leds on start/Restart
        mov r0, r9                  
        bl BSP_LED_Off              @Turns off selected led
        subs r9, r9, #1             @decrements the led counter
        bge led_on_check_loop_A3    @loops back until greater than equal to zero

start_game:
    ldrb r8, [r5, r7]               @loading first number for light on, the offset is increased gradually
    
    mov r1, r8                      @mov operation because cbz requires low register
    cbz r1, Loop_again               @loses if it is zero it means end of pattern

    sub r8, r8, #48                 @if not zero converts to decimal from ascii

    mov r0, r8                      @r8 to r0 for led on
    bl BSP_LED_On                   @turns selected led on

    mov r0, r4                      @stores busy delay to r0
    bl busy_delay                   @performs busy delay

    check_user_btn_press:           @checks for user button press
        bl BSP_PB_GetState          @gets the value if button is pressed or not
        
        cmp r0, #1                  @compares with return value if it's 0 not pressed, 1 means pressed
        bne continue_check          @if not pressed gets out of the loop

        cmp r8, r6                  @if the button is pressed it compares for the target led
        bne lose_game               @if equal the win lights are turned on
        b win_game
    
    continue_check:
        mov r0, r8                      @r8 to r0 for led off
        bl BSP_LED_Off                  @turns selected led off

        mov r0, r4                      @moves busy delay to r0
        bl busy_delay                   @performs busy delay

        add r7, r7, #1                  @adds 1 to offset index
        b start_game                    @loops until finished

Loop_again:
    mov r7, #0
    b start_game

lose_game:                              @for lose lights
    mov r0, r8                          @to turn selected led off
    bl BSP_LED_Off                      @selected led off

    mov r0, r6                          @sets the target light to r0
    bl BSP_LED_On                       @makes the target light on if lose
    
    b exit_A3                           @and exits

win_game:
    mov r0, r8                                     @r8 to r0 for led off
    bl BSP_LED_Off                                 @turns selected led off

    mov r10, #2                                    @counter for win lights blink twice
    win_loop_A3:
        mov r9, #7                                 @led counter
        led_on_toggle_loop_A3:                     @this loop toggles led on until all led's are on
            mov r0, r9
            bl BSP_LED_On                          @toggles selected led
            subs r9, r9, #1                        @decrements the counter
            bge led_on_toggle_loop_A3              @checks if it greater than equal to zero

        mov r0, r4                                 @add delay to register 0 from r4
        bl busy_delay                              @calls busy_delay for delay
        
        mov r9, #7                                 @led counter
        led_off_toggle_loop_A3:                    @turns all leds off
            mov r0, r9                      
            bl BSP_LED_Off                         @selected led off from r0
            subs r9, r9, #1                        @decrements the counter
            bge led_off_toggle_loop_A3             @loops until r9>=0

        mov r0, r4                                 @adds delay to register 0 from r4
        bl busy_delay                              @calls busy_delay

    subs r10, r10, #1                              @decrements the cycle count.
    bgt win_loop_A3                                @it loops until r10 is greater than 0
    b exit_A3                                      @exits

exit_A3:                                           @exit label

mov r0, #0                                         @moves 0 to r0 to return success
pop {r4-r10, lr}                                   @pops all used registers
bx lr
.size jp_led_demo_a3, .-jp_led_demo_a3 @@ - symbol size (not strictly required, but makes the debugger happy)




@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global jp_led_demo_a2 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB 

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type jp_led_demo_a2, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int jp_led_demo_a2(int count, int delay)
@
@ Input: r0, r1
@ Returns: r0
@
@ Here is the actual jp_led_demo_a2 function

jp_led_demo_a2:
push {r5, r6, r7, lr}
mov r5, r0       @saves count in register r5
mov r6, r1       @saves delay in register r6

toggle_loop:   

    mov r7, #7                              @setting r7 to 7 to decrement count for led.
    led_on_toggle_loop:                     @this loop toggles led on until all led's are on
		mov r0, r7
		bl BSP_LED_Toggle                   @toggles selected led
		subs r7, r7, #1                     @decrements the counter
		bge led_on_toggle_loop              @checks if it greater than equal to zero

    mov r0, r6                              @add delay to register 0 from r6
    bl busy_delay                           @calls busy_delay for delay
    
    mov r7, #7                              @sets r7 with 7 to decrement count for led
    led_off_toggle_loop:                    @turns all leds off
		mov r0, r7                      
		bl BSP_LED_Toggle                   @toggles selected led from r0
		subs r7, r7, #1                     @decrements the counter
		bge led_off_toggle_loop             @loops until r7 = -1

    mov r0, r6                              @adds delay to register 0 from r6
    bl busy_delay                           @calls busy_delay

subs r5, r5, #1                             @decrements the count entered by user or default - 2.
bgt toggle_loop                             @it loops until r5 is greater than 0

mov  r0, #0                                 @returns 0 if success

pop {r5, r6, r7, lr}
bx lr
.size jp_led_demo_a2, .-jp_led_demo_a2 @@ - symbol size (not strictly required, but makes the debugger happy)



@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global add_test @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type add_test, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int add_test(int x, int y)
@
@ Input: r0, r1 (i.e. r0 holds x, r1 holds y)
@ Returns: r0
@
@ Here is the actual add_test function
add_test:
push {lr}
add r0, r0, r1
mov r0, #0

bl BSP_LED_Toggle
mov r0, #1
bl BSP_LED_Toggle
mov r0, #2
bl BSP_LED_Toggle
mov r0, #3
bl BSP_LED_Toggle
mov r0, #4
bl BSP_LED_Toggle
mov r0, #5
bl BSP_LED_Toggle
mov r0, #6
bl BSP_LED_Toggle
mov r0, #7
bl BSP_LED_Toggle

mov r0, r2
bl busy_delay

mov r0, #0
bl BSP_LED_Toggle
mov r0, #1
bl BSP_LED_Toggle
mov r0, #2
bl BSP_LED_Toggle
mov r0, #3
bl BSP_LED_Toggle
mov r0, #4
bl BSP_LED_Toggle
mov r0, #5
bl BSP_LED_Toggle
mov r0, #6
bl BSP_LED_Toggle
mov r0, #7
bl BSP_LED_Toggle

pop {lr}
bx lr @ Return (Branch eXchange) to the address in the link register (lr)
.size add_test, .-add_test @@ - symbol size (not strictly required, but makes the debugger happy)

@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global busy_delay @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB

@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type busy_delay, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0
@
@ Here is the actual function. DO NOT MODIFY THIS FUNCTION.
busy_delay:
push {r5}
mov r5, r0
delay_1oop:
subs r5, r5, #1
bge delay_1oop
mov r0, #0 @ Return zero (success)
pop {r5}
bx lr @ Return (Branch eXchange) to the address in the link register (lr)
.size busy_delay, .-busy_delay @@ - symbol size (not strictly required, but makes the debugger happy)

@ Assembly file ended by single .end directive on its own line
.end
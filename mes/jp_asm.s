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
count: .word 12345 @ This is an initialized 32 bit value

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Assignments & Labs From Here @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


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
push {r4-r10, lr}

mov r4, r0
mov r5, r1
mov r6, r2
mov r7, #0

start_game:
    ldrb r8, [r5, r7] @loading first number for light on
    
    mov r1, r8                      @cbz requires low register
    cbz r1, lose_game               @loses if it is zero

    sub r8, r8, #48                 @if not zero converts to decimal from ascii

    mov r0, r8                      @r8 to r0 for led on
    bl BSP_LED_On                   @turns selected led on

    mov r0, r4
    bl busy_delay

    check_user_btn_press:
        bl BSP_PB_GetState
        
        cmp r0, #1
        beq win_game
    
    mov r0, r8                      @r8 to r0 for led off
    bl BSP_LED_Off               @turns selected led off

    mov r0, r4
    bl busy_delay

    add r7, r7, #1                  @adds 1 to offset index
    b start_game                    @loops until finished

lose_game:
    mov r0, r6
    bl BSP_LED_On
    b exit_A3

win_game:
    mov r0, r8                      @r8 to r0 for led off
    bl BSP_LED_Off               @turns selected led off

    mov r10, #2
    win_loop_A3:
        mov r9, #7
        led_on_toggle_loop_A3:                     @this loop toggles led on until all led's are on
            mov r0, r9
            bl BSP_LED_On                   @toggles selected led
            subs r9, r9, #1                     @decrements the counter
            bge led_on_toggle_loop_A3              @checks if it greater than equal to zero

        mov r0, r4                              @add delay to register 0 from r6
        bl busy_delay                           @calls busy_delay for delay
        
        mov r9, #7                              @sets r7 with 7 to decrement count for led
        led_off_toggle_loop_A3:                    @turns all leds off
            mov r0, r9                      
            bl BSP_LED_Off                   @toggles selected led from r0
            subs r9, r9, #1                     @decrements the counter
            bge led_off_toggle_loop_A3             @loops until r7 = -1

        mov r0, r4                              @adds delay to register 0 from r6
        bl busy_delay                           @calls busy_delay

    subs r10, r10, #1                           @decrements the count entered by user or default - 2.
    bgt win_loop_A3                                @it loops until r5 is greater than 0
    b exit_A3

exit_A3:                                        @exit label

mov r0, #0
pop {r4-r10, lr}
bx lr
.size jp_led_demo_a3, .-jp_led_demo_a3 @@ - symbol size (not strictly required, but makes the debugger happy)


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Past Assignments & Labs @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ assembly language instructions - Code section (text -> ROM)

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
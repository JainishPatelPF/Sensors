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
@ Function Declaration : int jp_led_demo_a2(int x, int y)
@
@ Input: r0, r1 (i.e. r0 holds x, r1 holds y)
@ Returns: r0
@
@ Here is the actual jp_led_demo_a2 function
jp_led_demo_a2:

push {r0, r1, r5, r6, lr}
mov r5, r0       @count
mov r6, r1       @delay

toggle_loop:    
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

    mov r0, r6
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

    mov r0, r6
    bl busy_delay

subs r5, r5, #1
bgt toggle_loop

pop {r0, r1, r5, r6, lr}
bx lr
.size jp_led_demo_a2, .-jp_led_demo_a2 @@ - symbol size (not strictly required, but makes the debugger happy)






@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Past Assignments & Labs @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

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
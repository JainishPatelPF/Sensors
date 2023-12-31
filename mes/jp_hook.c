/*
* C to assembler menu hook
*
*/
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "common.h"
#include <string.h>

int add_test(int x, int y, int del);

int jp_led_demo_a2(int count, int delay);       //function declaration for assignment 2 defined in asm file.

int jp_led_demo_a3(int delay, char* pattern, int target); //function declaration for assignment 3

int jp_led_demo_a4(int delay, int target_light, int game_time); //function declaration for assignment 4


// Funtion Name: _jp_A4(int)
// Function Parameters: action
// Function Description: This is the function used for Assignment 4 and This function gets three parameters from UI and sends it to the asm file.
// Fetch_uint32_arg gets three parameters : delay, target, and game_time

void _jp_A4(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Assignment 4\n\n" "This command is used for Assignment 4.\n");
return;
}
 uint32_t user_input_delay;                                                  //User Input block for Delay
 int fetch_status_delay;
 fetch_status_delay = fetch_uint32_arg(&user_input_delay);
 if(fetch_status_delay) {
 // Use a default value
 user_input_delay = 500;                                        //default is 500ms
 } 

 uint32_t user_input_target;                                                   //User Input block for target_light
 int fetch_status_target;
 fetch_status_target = fetch_uint32_arg(&user_input_target);
 if(fetch_status_target) {
 // Use a default value
 user_input_target = 5;                                         //default target light is 5
 } 
 
 uint32_t user_input_target_game_time;                                                   //User Input block for target game_time
 int fetch_status_target_game_time;
 fetch_status_target_game_time = fetch_uint32_arg(&user_input_target_game_time);
 if(fetch_status_target_game_time) {
 // Use a default value
 user_input_target_game_time = 30;                                         //default target game_time is 30
 } 

printf("A4 Returned: %d\n", jp_led_demo_a4(user_input_delay, user_input_target, user_input_target_game_time));  //Prints return value from this function defined in asm file.
}
ADD_CMD("jpTilt", _jp_A4, "\tA04 - BLINKING LIGHTS AND SENSORS") //macro command for Assignment 4. Called by : "jpTilt delay target Game_time"


////////////////////////////////////////// Past Assignments & Labs ////////////////////////////////////////

// Funtion Name: _jp_A3(int)
// Function Parameters: action
// Function Description: This is the function used for Assignment 3 and This function gets three parameters from UI and sends it to the asm file.
// Fetch_uint32_arg gets two parameters : delay and target, fetch_string_arg gets one parameter: pattern

void _jp_A3(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Assignment 3\n\n" "This command is used for Assignment 3.\n");
return;
}
 uint32_t user_input_delay;                                                  //User Input block for Delay
 int fetch_status_delay;
 fetch_status_delay = fetch_uint32_arg(&user_input_delay);
 if(fetch_status_delay) {
 // Use a default value
 user_input_delay = 500;                                        //default is 500ms
 } 

int fetch_status_pattern;                                                   //User Input block for pattern
char *destptr_pattern;
fetch_status_pattern = fetch_string_arg(&destptr_pattern);
if(fetch_status_pattern) {
// Default logic here
destptr_pattern = "43567011";                                   //default is "43567011"
}


 uint32_t user_input_target;                                                   //User Input block for target
 int fetch_status_target;
 fetch_status_target = fetch_uint32_arg(&user_input_target);
 if(fetch_status_target) {
 // Use a default value
 user_input_target = 5;                                         //default target light is 5
 } 
 
 //scaling delay 
 int final_delay = 0;                           //stores final delay
 final_delay = user_input_delay * 1.67;         //delay conversion ratio multiplied with delay
 final_delay = final_delay * 10000;             //and finally multiplying with 10000 to get actual delay

printf("A3 Returned: %d\n", jp_led_demo_a3(final_delay, destptr_pattern, user_input_target));  //Prints return value from this function defined in asm file.
}
ADD_CMD("jpGame", _jp_A3, "\tA03 - Calling Functions") //macro command for Assignment 3. Called by : "jpGame delay pattern target"





void AddTest(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Addition Test\n\n" "This command tests new addition function\n");
return;
}
uint32_t delay;
int fetch_status;
fetch_status = fetch_uint32_arg(&delay);
if(fetch_status) {
// Use a default delay value
delay = 0xFFFFFF;
}
// When we call our function, pass the delay value.
// printf(“<<< here is where we call add_test – can you add a third parameter? >>>”);
printf("add_test returned: %d\n", add_test(99, 87, delay));
}
ADD_CMD("add", AddTest,"Test the new add function")


// Funtion Name: _jp_A2(int)
// Function Parameters: action
// Function Description: This is the function used for Assignment 2 and This function gets two parameters from UI and sends it to the asm file.
// Fetch_uint32_arg gets two parameters : count and delay


void _jp_A2(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Addition Test\n\n" "This command tests new addition function\n");
return;
}
uint32_t user_input1;                                                   //User Input block 1 for Count
 int fetch_status1;
 fetch_status1 = fetch_uint32_arg(&user_input1);
 if(fetch_status1) {
 // Use a default value
 user_input1 = 2;
 } 

 uint32_t user_input2;                                                  //User Input block 1 for Delay
 int fetch_status2;
 fetch_status2 = fetch_uint32_arg(&user_input2);
 if(fetch_status2) {
 // Use a default value
 user_input2 = 0xFFFFFF;
 } 
 

printf("A2 Returned: %d\n", jp_led_demo_a2(user_input1, user_input2));  //Prints return value from this function defined in asm file.
}
ADD_CMD("A2", _jp_A2, "\tA02 - Calling Functions") //macro command for Assignment 2. Called by : "A2 parameter1 parameter2"
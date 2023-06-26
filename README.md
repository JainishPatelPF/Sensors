# (Assembly) Blinking Lights & Sensors
Implemented a simple game that uses the lights and accelerometer on the board.
Given the command below (where xx is your initials)
xxTilt delay target game_time
The board will turn on the light(s) according to the X and Y accelerometer values retrieved via the I2C interface.
See the appropriate lab for details of retrieving these values.
When the target light has been kept on for the target time, you win, and the board flashes all lights twice.
If you do not manage to turn on the lights in the allotted game time (specified in seconds) you lose, and the single
target light will be turned on.
Example:
jpGame 500 5 30
This would run the game with a target of light 5 being on for 500ms to win. The game will run for 30 seconds in this
case before it would end with a loss
This game will have to use the timer interrupt triggered by the System Tick Timer to function. Y

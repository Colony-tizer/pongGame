# pongGame
PongGame created using CS50's game dev lecture.
Lecture 0 link: https://youtu.be/GfwpRU0cT10
This implementation has significantly better collision detection. 

PongGame — local multiplayer game of Pong.

# Features
* Ball accelerates each time when touches a pad<br />
* Player's pad shrinks a bit each time when touches a ball<br />
* To accelerate the ball players should move their pads in direction of the ball vertical direction at the moment of touch<br />
* Players can adjust ball speed by moving their pads down or up at the moment of touch<br />
* If the ball reaches critial max speed a special line appears which indicates future location of the ball<br />
* The first to score 5 wins!
# How to launch
There is no executable file (yet!). So you have to manually compile the project. <br />
You have to have installed framework LÖVE 11 or above. <br />
* Open the terminal 
* Head to the folder where the project is located
* To launch the game type ```love .```
# Controls
## Left pad
Up — W<br />
Down — S
## Right pad
Up — ARROW_UP<br />
Down — ARROW_DOWN
## General
ENTER to start<br />
ESC to quit

# Source code
// TODO: describe functions here
## Main.lua 
Contains the whole game loop, processing players input, handling physics, sounds, etc.
### Global Properties
```DEBUG``` — flag enabling debug features <br />
```PAD_SIZE``` — initial size of the player pads <br />
```TRACE_LINES_LIMIT``` — the limit of lines drawing ball's trajectory
```MAX_SCORE``` — the win condition<br />
```PLAYERS_SCORE``` — table with the following stucture containing player scores: ```{ @Number, @Number }```<br />
```WINDOWS_SIZE``` — table with info about windows size. Has the following structure:<br />
```
WINDOWS_SIZE = { 
    ["width"] = 1280, 
    ["height"] = 720, 
    ["virtual"] = {
        ["width"] = 432,
        ["height"] = 243
    }
}
```
```GAME_STATES``` — table containing states of the game. Possible states:<br />
* start — welcome screen <br />
* game — main state, ball moves <br />
* pause — ball stops <br />
* finish — one player hit MAX_SCORE <br />
* serve — one player hit a score <br />

```HELP_TEXT``` — const string with the info about controls<br />
## Ball.lua
Class defining ball proprties, render funtions<br />
// TODO: replace random numbers with const variables
## Paddle.lua 
Class defining paddle proprties, render, update functions<br />
# Debug features
To enable debug features set the property ```DEBUG``` to ```true``` in the ```main.lua``` file
```
DEBUG = true
```
## Positions and size info
Info about the positions of all interaction objects will appear near them. <br />
Info about size of pads will appear near them.
## Pause
If the game in the ```'game'``` state press ```SPACE_BAR``` button to pause the game. The game will freeze.
## Ball manipulation
Use ```LEFT_CLICK``` mouse button to set the ball's positions.
## Collision info
The word ```true``` or ```false``` will appear near pads whether the ball is colliding or not. 
## Ball tracing
To enable feature set property ```SUPER_SPEED``` to ```0``` in the ```Ball.lua``` file: <br />
```
SUPER_SPEED = 0
```

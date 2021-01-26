The Gorton Maze Test is a cognitive test designed to test short term memory and spatial reasoning. The lab I worked for the previous two summers administers
it to Traumatic Brain Injury patients. To make the test more accessible to these patients (its currently only available on certain computers) and the general public, I decided to 
implement this test in flutter for my final project (with the permission of the lab and the creators of the task). 

For the task, the subject must click on tiles one-by-one to make a path from the start tile (top left) to the finish tile (bottom right).
There is pathway hidden below these 100 possible locations. Right now, there is one path that is hard coded but in the future the app 
will be able to automatically generate new paths whenever the user wants to try a different maze. There are four rules that the subject must follow: the subject 
cannot move diagonally (only up, down, left, or right), they cannot click the same square twice, they cannot move backwards on the path, 
and they can only move one square at a time (can't skip squares). If the user clicks a square that is legal and on the path, it turns green and displays a checkmark. 
Otherwise, the square will turn red and display an X. If an incorrect tile choice is revealed, the subject must click on the last correct tile they chose before they click on another tile 
to try to advance to the end of the maze. 

To implement this, the first thing I did was create a gameButton class. Each button is a gameButton type. The gameButton class has an id property (so that individual squares can be referred to), 
a color property (indicating which color that square should be), and a onPath property (indicating if that particular square is on the path). Additionally, the class has a testIfLegal function which 
checks if that particular square is a legal move (ie the user's last move was one square vertically or horizontally away from it). Finally, the class has a moveCheck function that uses the testIfLegal function 
and returns true only if the move the user makes is legal AND on the path. 

Next, I created a Maze class that consists of 100 gameButtons. The gridview widget is utilized to display these 100 buttons in a 10x10 grid. 
Additionally, there is an updateButton function defined within the MazeState class that allows the colors of the buttons to be changed individually.
This works by wrapping the each button within a notificationListener so each listens for a color change event. 

The bulk of the logic for the game was written within the buttonPress function. This function is called each time a button is pressed. First, 
it sets timeOut to true so that the user cannot make moves during this time (otherwise game can be overwhelmed). Then, it uses the moveCheck function 
to determine whether the move made is correct. If it is, the square changes to green and displays a check mark for 100 ms. If not, the square
changes to red and displays an X for 100 ms. This is acomplished using the Timer class native to flutter. After the 100 ms ends, the square turns purple to
visually show the user what their last move was. Then, if the move was correct, the function checks if the id of the button pressed 
is 99 (the last square in the maze). If it is, the function displays a message indicating the end of the maze has been successfully reached. 
This is acomplished using the Alert Dialog class. Then, the resetGame function is called to reset the game if the user wants to play again.
If the last move was incorrect, the mercyRule() function. If the user has made 3 consecutive errors, the mercyRule function shows them 
the next square on the path. 

Finally, the last thing I wrote was a function in gameButtonState that dynamically generates .json files. To write this function, this youtube video was
utilized as a guide (https://www.youtube.com/watch?v=jVVCHzkI8as). Note: as of right now if you want a json file to be 
generated on your device with the relevant infromation (times, moves, and errors), you must manually grant the app 
external storage permission in settings. Once the user succesfully reaches the end of the maze, the writeToFile function is utilized to 
generate a .json file on their device with all of the information about their run. 

In the future, the app will be able to dynamically generate new mazes whenever the user wants. I didn't get a chance to write that function 
and so, as of now, there is only one simple path that is hard-coded into the app. 




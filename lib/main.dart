//import necessary packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
//initialize new maze
maze maze1= new maze();
Color color1 = Colors.grey;
int lastMove = 0; //records last CORRECT move of user
bool lastMoveIncorrect = true; //true if user's last move was correct, false otherwise
var icon = Icons.check;
var image="assets/greencheck.jpg";
Stopwatch clock = new Stopwatch(); //initialize new stopwatch that will be used to record times of user's moves
List moves = [];
List correctMoves = [];
List<dynamic> times=[];
List errors = [];
//temporary test path - going to change to make dynamically generated
List<dynamic> path=[0,10,20,30,40,50,60,70,80,90,91,92,93,94,95,96,97,98,99];
bool timeOut = false; //when true, user is prohibited from entering new moves (so as not to overwhelm game)
var dateTime = DateTime.now();
int attemptNum = 1;
int consecErrors = 0;
int recentMove; //records last move of user regardless of corectness

void main() {
  runApp(MyApp());
  //manually fill in maze
  for(var i=0; i<19; i++)
    {
      maze1.button_grid[path[i]].onPath=1;
    }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class gameButton extends StatefulWidget {
  int id;
  //id represents id of button (top left button is 0 bottom right button is 99)
  Color color;
  bool displayImage;
  int onPath=0;
  //1 if square is on the path, 0 otherwise
  bool testOnPath() {
    if(this.onPath==1)
      {
        return true;
      }
    else
      {
        return false;
      }
  }

  bool testIfLegal(lastMove)
  {
    return (((this.id - lastMove).abs() == 1) ^
    ((this.id - lastMove).abs() == 10));
  }
  //tests if move is legal
  bool moveCheck()
  {
    if(lastMoveIncorrect)
      {
        if(this.id == lastMove)
          {
            lastMoveIncorrect = false;
            return true;
          }
        else
          {
          return false;
          }
      }
    else
      {
        if(this.testIfLegal(lastMove) & this.testOnPath() & !(correctMoves.contains(this.id)))
          {
            lastMove = this.id;
            return true;
          }
        else
          {
            lastMoveIncorrect=true;
            return false;
          }
      }
  }
  //function above returns true if move user makes is correct (both a legal move and a square that is on the path) and false otherwise
  @override
  gameButton(this.id, this.color, this.displayImage);
  //initialize state
  gameButtonState createState() => gameButtonState(color);

}

class gameButtonState extends State<gameButton> {

  //code below used to dynamically generate json files of the user's moves
  File jsonFile;
  Directory dir;
  String fileName = "Maze task attempt $attemptNum - $dateTime";
  bool fileExists = false;
  Map<String, dynamic> fileContent;

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) this.setState(() =>
      fileContent = json.decode(jsonFile.readAsStringSync()));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  //if file doesn't exist need to create new json file
  void createFile(Map<String, dynamic> content, Directory dir,
      String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  //if file w/t same name exists, need to edit file instead of creating new one
  void writeToFile(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    if (fileExists) {
      Map<String, dynamic> jsonFileContent = json.decode(
          jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
  }

  Color color;

  //initialize color state of buttons
  gameButtonState(this.color);

  //after user clicks next square the previous square should turn back to grey
  void turnGrey() {
    if (moves.length >= 2) {
      if (widget.id == moves[moves.length - 2]) {
        null;
      }

      else {
        PressNotification(id: (moves[moves.length - 2]), color: Colors.grey)
            .dispatch(context);
      }
    }
  }

  //if user makes 3 incorrect moves in a row then game shows the user the next correct move by turning it green
  void mercyRule() {
    if (consecErrors >= 3) {
      timeOut = true;
      PressNotification(id: lastMove, color: Colors.green).dispatch(context);
      Timer(Duration(milliseconds: 100), () {
        PressNotification(id: lastMove, color: Colors.grey).dispatch(context);
      });
    }

    else {
      null;
    }
  }
//once user reaches end of maze, game should be reset
  void resetGame()
  {
    //reinitialize variables to default
    moves = [];
    correctMoves = [];
    times=[];
    errors = [];
    consecErrors = 0;
    lastMove = 0; //records last CORRECT move of user
    lastMoveIncorrect = true;
    clock.reset();
  }

  //function executed when any button pressed
  void buttonPress()
  {
    //first prevent uesr from making new moves during 250 milisecond animation
    timeOut = true;
    times.add(clock.elapsedMilliseconds);
    clock.reset();
    setState(() {
      //check if move is "correct"- if so square should turn green and display checkmark for 100 miliseconds
      if(widget.moveCheck()) {
        consecErrors = 0;
        errors.add("correct");
        maze1.button_grid[widget.id].color = Colors.green;
        maze1.button_grid[widget.id].displayImage = true;
        icon = Icons.check;
        Timer(Duration(milliseconds: 100), () {
          if (this.mounted) {
            setState(() {
              if(widget.id==99)
                {
                  maze1.button_grid[widget.id].color = Colors.grey;
                }
             else
               {
                 maze1.button_grid[widget.id].color = Colors.purple;
               }
              turnGrey();
              maze1.button_grid[widget.id].displayImage = false;
              timeOut = false;
            });
          }
        });
        //ending condition- if move is correct AND the last square on the path then game should display message congratulating them
        if(widget.id==99) {

          //when user reaches end of maze successfully all the information gathered on their run should be written to a json file
          writeToFile("Moves", moves);
          writeToFile("Path", path);
          writeToFile("Times", times);
          writeToFile("Errors", errors);
          attemptNum++;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                //return alert congratulating user if reach end of maze successfully
                return AlertDialog(
                    title: new Text("Success!"),
                    actions: <Widget>[
                      new FlatButton(
                          onPressed: () {
                            resetGame();
                            Navigator.pop(context);
                          },
                          child: new Text("Play Again")
                      )
                    ]
                );
              }
          );

        }
        correctMoves.add(widget.id);
      }
      else //this code runs if move is INCORRECT- if move is incorrect then square turns red and displays an X
      {
        //keep track of how many consecutive erros user has made- if 3 then game should show next correct move
        consecErrors++;
        errors.add("incorrect");
        maze1.button_grid[widget.id].color = Colors.red;
        maze1.button_grid[widget.id].displayImage=true;
        icon = Icons.clear;
        Timer(Duration(milliseconds: 100), () {
          if(this.mounted) {
            setState(() {
              maze1.button_grid[widget.id].color = Colors.purple;
              turnGrey();
              maze1.button_grid[widget.id].displayImage=false;
              mercyRule();
              timeOut=false;
            });
          }
        });
      }

    });
    moves.add(widget.id);
    recentMove=widget.id;
  }
  @override
  //build actual GUI of "gamebutton" - a flatbutton with an icon hidden within it (either check or X)
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: FlatButton(
            color: maze1.button_grid[widget.id].color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              //what happens on buttonPress event- either nothing (if animation is taking place) or buttonPress function (defined above) called
              timeOut?null:buttonPress();
            },
            child: maze1.button_grid[widget.id].displayImage?Column(// Replace with a Row for horizontal icon + text
          children: <Widget>[
            maze1.button_grid[widget.id].displayImage?Icon(icon):null,
          ],
          ):null
    ));
  }
}

//function allows color of buttons to be changed by sending that gameButton a notification
class PressNotification extends Notification {
  final int id;
  final Color color;

  const PressNotification({this.id, this.color});
}
//maze is the collection of all 100 buttons- initialized here
class maze extends StatefulWidget {
  List<gameButton> button_grid  = [
    for (var i = 0; i < 100; i++) new gameButton(i, Colors.grey, false)
  ];

  @override
  mazeState createState() => mazeState(button_grid);

}
//state of maze
class mazeState extends State<maze> {
  List<gameButton> button_grid;
  mazeState(this.button_grid);

  //function utilizes PressNotification class and allows user to change the colors of individual squares on the maze
  bool updateButton(PressNotification notification) {
    setState(() {
      button_grid[notification.id].color = notification.color;
    });
    return true;
  }

 //initialize state + start clock once
  void initState()
  {
    super.initState();
    clock.start();
  }

  @override
  //build and return concrete implemenation of maze class
  Widget build(BuildContext context) {
    //wrapped in notification listener so each square can listen for color change event
    return NotificationListener<PressNotification>(
      onNotification: updateButton,
      child:
      Column(
          children: <Widget>[
            GridView.builder(
               //uniqueKey utilized so buttons that need to change color can dynamically rebuild
                key: UniqueKey(),
                itemCount: 100,
                //squares kept in 10x10 gridview
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return maze1.button_grid[index];

                }
            ),
          ]
      ),
    );
  }
}
//homepage class initialized as class that contains everything
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  //state set- shouldn't need to change much since maze class is thing thats changing
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("GMT")),
        ),
        body: Center(
          child: maze1,
        )
    );
  }
}

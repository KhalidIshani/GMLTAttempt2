import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'json.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

maze maze1= new maze();
Color color1 = Colors.grey;
int lastMove = 0; //records last CORRECT move of user
bool lastMoveIncorrect = true; //was last move of user correct
var icon = Icons.check;
var image="assets/greencheck.jpg";
Stopwatch clock = new Stopwatch();
List moves = [];
List correctMoves = [];
List<dynamic> times=[];
List errors = [];
//temporary test path - going to change to make dynamically generated
List<dynamic> path=[0,10,20,30,40,50,60,70,80,90,91,92,93,94,95,96,97,98,99];
bool timeOut = false;
var dateTime = DateTime.now();
int attemptNum = 1;
int consecErrors = 0;
int recentMove; //records last move of user regardless of corectness

void main() {
  runApp(MyApp());
  maze1.button_grid[0].onPath=1;
  maze1.button_grid[10].onPath=1;
  maze1.button_grid[20].onPath=1;
  maze1.button_grid[30].onPath=1;
  maze1.button_grid[40].onPath=1;
  maze1.button_grid[50].onPath=1;
  maze1.button_grid[60].onPath=1;
  maze1.button_grid[70].onPath=1;
  maze1.button_grid[80].onPath=1;
  maze1.button_grid[90].onPath=1;
  maze1.button_grid[91].onPath=1;
  maze1.button_grid[92].onPath=1;
  maze1.button_grid[93].onPath=1;
  maze1.button_grid[94].onPath=1;
  maze1.button_grid[95].onPath=1;
  maze1.button_grid[96].onPath=1;
  maze1.button_grid[97].onPath=1;
  maze1.button_grid[98].onPath=1;
  maze1.button_grid[99].onPath=1;
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
  Color color;
  bool displayImage;
  int onPath=0;
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
  @override
  gameButton(this.id, this.color, this.displayImage);
  gameButtonState createState() => gameButtonState(color);

}

class gameButtonState extends State<gameButton> {

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

  void createFile(Map<String, dynamic> content, Directory dir,
      String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void writeToFile(String key, dynamic value) {
    print("Writing to file!");
    Map<String, dynamic> content = {key: value};
    if (fileExists) {
      print("File exists");
      Map<String, dynamic> jsonFileContent = json.decode(
          jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
  }

  Color color;

  gameButtonState(this.color);

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

  void buttonPress()
  {
    timeOut = true;
    times.add(clock.elapsedMilliseconds);
    clock.reset();
    setState(() {
      if(widget.moveCheck()) {
        consecErrors = 0;
        errors.add("correct");
        maze1.button_grid[widget.id].color = Colors.green;
        maze1.button_grid[widget.id].displayImage = true;
        icon = Icons.check;
        Timer(Duration(milliseconds: 100), () {
          if (this.mounted) {
            setState(() {
              maze1.button_grid[widget.id].color = Colors.purple;
              turnGrey();
              maze1.button_grid[widget.id].displayImage = false;
              timeOut = false;
            });
          }
        });
        //ending condition
        if(widget.id==99) {
          Timer(Duration(milliseconds: 100), () {
           maze1.button_grid[99].color=Colors.grey;
          });
          attemptNum++;
          showDialog(
              context: context,
              builder: (BuildContext context) {
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
          writeToFile("Moves", moves);
          writeToFile("Path", path);
          writeToFile("Times", times);
          writeToFile("Errors", errors);

        }
        correctMoves.add(widget.id);
      }
      else
      {
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
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: FlatButton(
            color: maze1.button_grid[widget.id].color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
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

class PressNotification extends Notification {
  final int id;
  final Color color;

  const PressNotification({this.id, this.color});
}
class maze extends StatefulWidget {
  List<gameButton> button_grid  = [
    for (var i = 0; i < 100; i++) new gameButton(i, Colors.grey, false)
  ];

  @override
  mazeState createState() => mazeState(button_grid);

}

class mazeState extends State<maze> {
  List<gameButton> button_grid;
  mazeState(this.button_grid);

  bool updateButton(PressNotification notification) {
    setState(() {
      button_grid[notification.id].color = notification.color;
    });
    return true;
  }

  void initState()
  {
    super.initState();
    clock.start();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PressNotification>(
      onNotification: updateButton,
      child:
      Column(
          children: <Widget>[
            GridView.builder(
                key: UniqueKey(),
                itemCount: 100,
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
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

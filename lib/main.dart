import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

var url = "http://localhost:3000";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Todo App';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FetchTodoList(),
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class FetchTodoList extends StatefulWidget {
  @override
  _FetchTodoListState createState() => _FetchTodoListState();

  List<TodoList> todoMap = [];
}

class _FetchTodoListState extends State<FetchTodoList> {
  @override
  void initState() {
    super.initState();
    fetchTodoMap();
  }

  Future<void> fetchTodoMap() async {
    var response = await http.get(Uri.parse(url + '/fetch_todo_list'));
    Map<String, dynamic> map = json.decode(response.body);
    List<TodoList> initTodo =
        map.entries.map((e) => TodoList.fromJson(e.value)).toList();
    setState(() {
      widget.todoMap = List.from(initTodo.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 740) {
          return MyBigBody(todoMap: widget.todoMap);
        } else {
          return MySmallBody(todoMap: widget.todoMap);
        }
      },
    );
  }
}

// ignore: must_be_immutable
class MyBigBody extends StatefulWidget {
  List<TodoList> todoMap;

  MyBigBody({required this.todoMap});

  @override
  _MyBodyState createState() => _MyBodyState();
}

class TodoList {
  String name = '';
  bool completed = false;
  String registerdTime = '';
  String? dueDate;

  TodoList(
      {required this.name,
      required this.registerdTime,
      this.dueDate,
      completed});

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
        name: json['name'],
        completed: json['completed'],
        registerdTime: json['registerd_time'],
        dueDate: json['due_date']);
  }
}

class _MyBodyState extends State<MyBigBody> {
  TextEditingController _controller = TextEditingController();
  DateTime? _selectedTime;

  onPress({name, registeredTime, dueDate}) async {
    print(dueDate);
    if (name == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Warning"),
            content: new Text("Write Something!!"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('back'))
            ],
          );
        },
      );
      return;
    }

    TodoList todo =
        TodoList(name: name, registerdTime: registeredTime, dueDate: dueDate);

    // post todo
    var response = await http.post(
      Uri.parse(url + '/post_todo'),
      body: {
        "name": name,
        "registered_time": registeredTime.toString(),
        "due_date": dueDate.toString()
      },
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    print(response.body);

    setState(() {
      widget.todoMap.insert(0, todo);
    });

    this._controller.text = '';
    this._selectedTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12, 48, 12, 12),
              child: Container(
                width: 500,
                height: 100,
                child: Form(
                  child: TextFormField(
                    decoration: InputDecoration(hintText: 'Write Some Todo'),
                    autofocus: true,
                    controller: _controller,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Container(
                constraints: BoxConstraints(maxWidth: 150),
                child: ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('picking D-Day'),
                  ),
                  onPressed: bringDatePicker,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 100),
              child: ElevatedButton(
                  onPressed: () => {
                        onPress(
                            name: _controller.text,
                            registeredTime: DateTime.now().toString(),
                            dueDate: _selectedTime)
                      },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('submit'),
                  )),
            ),
          ],
        ),
        ShowList(todoMap: widget.todoMap),
      ]),
    );
  }

  void bringDatePicker() {
    Future<DateTime?> selectedDate = showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 20),
        builder: (context, child) {
          return Theme(data: ThemeData.dark(), child: child!);
        });
    selectedDate.then((dateTime) {
      setState(() {
        this._selectedTime = dateTime;
      });
    });
  }
}

class MySmallBody extends StatefulWidget {
  final List<TodoList> todoMap;
  MySmallBody({required this.todoMap});
  @override
  _MySmallBodyState createState() => _MySmallBodyState();
}

class _MySmallBodyState extends State<MySmallBody> {
  TextEditingController _controller = TextEditingController();
  DateTime? _selectedTime;

  onPress({name, registeredTime, dueDate}) async {
    print(dueDate);
    if (name == '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Warning"),
            content: new Text("Write Something!!"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('back'))
            ],
          );
        },
      );
      return;
    }

    TodoList todo =
        TodoList(name: name, registerdTime: registeredTime, dueDate: dueDate);

    // post todo
    var response = await http.post(
      Uri.parse(url + '/post_todo'),
      body: {
        "name": name,
        "registered_time": registeredTime.toString(),
        "due_date": dueDate.toString()
      },
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    print(response.body);

    setState(() {
      widget.todoMap.insert(0, todo);
    });

    this._controller.text = '';
    this._selectedTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 48, 12, 0),
          child: Container(
            width: 500,
            height: 60,
            child: Form(
              child: TextFormField(
                decoration: InputDecoration(hintText: 'Write Some Todo'),
                autofocus: true,
                controller: _controller,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('picking D-Day'),
                    ),
                    onPressed: bringDatePicker,
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: ElevatedButton(
                    onPressed: () => {
                          onPress(
                              name: _controller.text,
                              registeredTime: DateTime.now().toString(),
                              dueDate: _selectedTime)
                        },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('submit'),
                    )),
              ),
            ],
          ),
        ),
        ShowList(todoMap: widget.todoMap),
      ]),
    );
  }

  void bringDatePicker() {
    Future<DateTime?> selectedDate = showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 20),
        builder: (context, child) {
          return Theme(data: ThemeData.dark(), child: child!);
        });
    selectedDate.then((dateTime) {
      setState(() {
        this._selectedTime = dateTime;
      });
    });
  }
}

class ShowList extends StatefulWidget {
  final List<TodoList>? todoMap;

  ShowList({required this.todoMap});

  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: SizedBox(
                  width: 100,
                  child: Text(
                    'Work',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 100,
                  child: Text('Completed',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Center(
                child: SizedBox(
                    width: 100,
                    child: Text('Due Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
              Center(
                child: SizedBox(
                    width: 100,
                    child: Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(50, 12, 50, 12),
            child: Container(
              height: 1,
              color: Colors.black38,
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: list().toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Iterable<Row> list() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.black;
    }

    Iterable<Row> map = widget.todoMap!.map((element) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: SizedBox(width: 100, child: Text(element.name)),
          ),
          Center(
            child: SizedBox(
              width: 50,
              child: Checkbox(
                value: element.completed,
                onChanged: (bool? value) {
                  setState(() {
                    element.completed = value!;
                  });
                },
                splashRadius: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
              ),
            ),
          ),
          showDueDate(element.dueDate),
          Center(
            child: SizedBox(
              width: 100,
              child: ElevatedButton(
                  onPressed: () => {
                        setState(() {
                          widget.todoMap!.removeWhere(
                              (e) => e.registerdTime == element.registerdTime);
                          deleteTodohttp(element);
                        })
                      },
                  child: Text('DELETE')),
            ),
          )
        ],
      );
    });
    return map;
  }

  void onCheckBoxChanged(bool? value) {
    print(!value!);
    setState(() {
      value = !value!;
    });
  }

  showDueDate(String? dueDate) {
    if (dueDate == null) {
      return SizedBox(
        child: Center(child: Text('undecided')),
        width: 100,
      );
    } else {
      return SizedBox(
        child: Center(child: Text(dueDate.toString().split(' ')[0])),
        width: 100,
      );
    }
  }

  Future<void> deleteTodohttp(TodoList element) async {
    var response = await http.post(Uri.parse(url + '/delete_todo'),
        body: {"registered_time": element.registerdTime});
    print(response.body);
  }
}

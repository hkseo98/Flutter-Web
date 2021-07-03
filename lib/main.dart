import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';

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
      body: MyBody(),
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

class MyBody extends StatefulWidget {
  @override
  _MyBodyState createState() => _MyBodyState();
}

class TodoList {
  String name = '';
  bool completed = false;
  String registerdTime = '';
  String dueDate = '';

  TodoList(
      {required this.name, required this.registerdTime, required this.dueDate});
}

class _MyBodyState extends State<MyBody> {
  TextEditingController _controller = TextEditingController();
  List<TodoList> todoMap = [];

  onPress({name, registeredTime}) {
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
    TodoList todo = TodoList(name: name, registerdTime: registeredTime);
    setState(() {
      todoMap.add(todo);
    });
    print(todoMap);
    _controller.text = '';
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
                    autocorrect: true,
                    controller: _controller,
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () => {
                      onPress(
                          name: _controller.text,
                          registeredTime: DateTime.now().toString())
                    },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('submit'),
                )),
          ],
        ),
        ShowList(todoMap: todoMap),
      ]),
    );
  }
}

class ShowList extends StatefulWidget {
  final List<TodoList> todoMap;

  ShowList({required this.todoMap});

  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Work',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Completed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Registered Time',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Container(
                height: 1,
                constraints: BoxConstraints(minWidth: 300, maxWidth: 700),
                color: Colors.black38,
              ),
            ),
            Expanded(
              child: Container(
                width: 900,
                child: ListView(
                  children: list().toList(),
                ),
              ),
            )
          ],
        ),
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

    Iterable<Row> map = widget.todoMap.map((element) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              constraints: BoxConstraints(maxWidth: 100, minWidth: 100),
              child: Text(element.name),
            ),
          ),
          Checkbox(
            value: element.completed,
            onChanged: (bool? value) {
              setState(() {
                print(element.completed);
                print(value);
                element.completed = value!;
              });
            },
            splashRadius: 15,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(getColor),
          ),
          Text(element.registerdTime),
          ElevatedButton(
              onPressed: () => setState(() {
                    widget.todoMap.removeWhere(
                        (e) => e.registerdTime == element.registerdTime);
                  }),
              child: Text('DELETE'))
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
}

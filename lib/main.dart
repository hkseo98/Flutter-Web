import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Post> fetchPost() async {
  Future<Post> a;
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
  a = Future.delayed(Duration(seconds: 3), () {
    if (response.statusCode == 200) {
      // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
      print(json.decode(response.body)['title']);
      return Post.fromJson(json.decode(response.body));
    } else {
      // 만약 요청이 실패하면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  });
  return a;
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

// json으로 들어올 때의 생성자
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Post>? post;

  @override
  void initState() {
    // react의 useEffect()와 비슷, 혹은 componentDidMount()
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          // 데이터를 화면에 보여주기 위한 목적으로, FutureBuilder 위젯을 사용할 수 있습니다. FutureBuilder 위젯은 Flutter에 기본적으로 제공되는 위젯으로 비동기 데이터 처리를 쉽게 해줍니다.
          child: FutureBuilder<Post>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    snapshot.data!.title + '\n\n' + snapshot.data!.body);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // 기본적으로 로딩 Spinner를 보여줍니다.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future fetchPhotos(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

  // compute 함수를 사용하여 parsePhotos를 별도 isolate에서 수행합니다.
  return compute(parsePhotos, response.body);
}

// 응답 결과를 List<Photo>로 변환하는 함수.
List parsePhotos(String responseBody) {
  final parsed = json.decode(responseBody);

  return parsed.map((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo(
      {required this.albumId,
      required this.id,
      required this.title,
      required this.url,
      required this.thumbnailUrl});

  factory Photo.fromJson(Map json) {
    return Photo(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(
        title: appTitle,
        photo: compute(fetchPhotos, http.Client()),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Future photo;

  MyHomePage({Key? key, required this.title, required this.photo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
        future: photo,
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  final photos;

  PhotosList({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, index) {
        print("url:" + photos[index].thumbnailUrl);
        return Stack(children: [
          FadeInImage(
            width: 100,
            height: 100,
            image: NetworkImage(photos[index].thumbnailUrl),
            placeholder: AssetImage('cool.png'),
          ),
          Text(photos[index].id.toString())
        ]);
      },
    );
  }
}

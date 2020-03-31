import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:nanoid/nanoid.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'comments.dart';

class Post extends StatefulWidget {
  final String name;
  final String postId;
  final String date;
  final String title;
  final String record;
  final String image;
  Post({
    this.postId,
    this.name,
    this.record,
    this.date,
    this.title,
    this.image,
  });
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      name: doc['name'],
      record: doc['record'],
      date: doc['date'],
      title: doc['title'],
      image: doc['image'],
    );
  }

  @override
  _PostState createState() => _PostState(
        name: this.name,
        postId: this.postId,
        date: this.date,
        title: this.title,
        record: this.record,
        image: this.image,
      );
}

class _PostState extends State<Post> {
  final String name;
  final String postId;
  final String date;
  final String title;
  final String record;
  final String image;

  _PostState({
    this.postId,
    this.name,
    this.record,
    this.date,
    this.title,
    this.image,
  });

  var idGenerator = nanoid(8);
  String _playerTxt = '00:00:00';
  double _dbLevel;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  StreamSubscription _dbPeakSubscription;
  FlutterSound flutterSound;
  double slider_current_position = 0.0;
  double max_duration = 1.0;
  Response response;
  Dio dio = new Dio();

  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startPlayer(String url) async {
    Directory tempDir = await getTemporaryDirectory();
    String downloadPath = tempDir.path;
    final File tempFile = File('$downloadPath/$idGenerator.wav');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    print(tempFile.path);
    response = await dio.download(url, tempFile.path);
    String path = await flutterSound.startPlayer(tempFile.path);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          slider_current_position = e.currentPosition;
          max_duration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'pt_BR').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xffFF1744)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Problem from : ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: "Bebas Neue"),
                textAlign: TextAlign.left,
              ),
              Text(
                '$name',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30,
                    fontFamily: "Bebas Neue"),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Text('Title : $title',
              style: TextStyle(
                  color: Colors.white, fontSize: 25, fontFamily: "Bebas Neue"),
              textAlign: TextAlign.left),
          Row(
            children: <Widget>[
              Container(
                width: 45.0,
                height: 45.0,
                margin: EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    startPlayer(record);
                  },
                  icon: Icon(Icons.play_arrow),
                ),
              ),
              Container(
                width: 45.0,
                height: 45.0,
                margin: EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    pausePlayer();
                  },
                  icon: Icon(Icons.pause),
                ),
              ),
              Container(
                width: 45.0,
                height: 45.0,
                margin: EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    stopPlayer();
                  },
                  icon: Icon(Icons.stop),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          SizedBox(
            height: 20,
          ),
          Center(child: Image(image: NetworkImage(image))),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.accessibility_new,
                              size: 32, color: Colors.blue[900]),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Solutions ',
                            style: TextStyle(
                                fontSize: 30, fontFamily: "Bebas Neue"),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Comments(postId: postId, record: record);
                    }));
                  }),
              Text(
                date,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

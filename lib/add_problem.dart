import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';

class AddProblem extends StatefulWidget {
  static final String id = 'AddProblemScreen';
  @override
  _AddProblemState createState() => _AddProblemState();
}

class _AddProblemState extends State<AddProblem> {
  var idGenerator = nanoid(8);
  File sampleImage;
  bool unKnown = false;
  bool addImage = false;
  String problemTitle;
  String name;
  String problemCategory = 'Social Problems';
  String uriPath;
  String recordNameDate = DateFormat("yyyy-MM-dd hh:mm").format(DateTime.now());
  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  StreamSubscription _dbPeakSubscription;
  FlutterSound flutterSound;
  double slider_current_position = 0.0;
  double max_duration = 1.0;
  final _fireStore = Firestore.instance;

  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startRecorder() async {
    try {
      String path = await flutterSound.startRecorder(null);
      uriPath = path;
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'pt_BR').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async {
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void startPlayer() async {
    String path = await flutterSound.startPlayer(uriPath);
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

  void seekToPlayer(int milliSecs) async {
    String result = await flutterSound.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  void dispose() {
    flutterSound.stopRecorder();
    super.dispose();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = image;
    });
  }

  postButton() async {
    try {
      File file = File(uriPath);
      final StorageReference storageRefRecord =
          FirebaseStorage.instance.ref().child('record$idGenerator.wav');
      String postId = idGenerator;
      final StorageUploadTask task1 = storageRefRecord.putFile(file);
      final String recordUrl = await storageRefRecord.getDownloadURL();
      String imageUrl = addImage ? await uploadImage() : 'no Image';

      _fireStore.collection(problemCategory).document(postId).setData({
        'name': unKnown ? 'unKnown' : currentUser.displayName,
        'title': problemTitle,
        'date': recordNameDate,
        'record': recordUrl,
        'postId': postId,
        'image': imageUrl,
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  Future<String> uploadImage() async {
    final StorageReference storageRefImage =
        FirebaseStorage.instance.ref().child('image$idGenerator.jpg');
    final StorageUploadTask imageUploadTask =
        storageRefImage.putFile(sampleImage);
    final String imageUrl = await storageRefImage.getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding:
              const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 30),
          child: ListView(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Text(
                  'Enter your problem details :',
                  style: TextStyle(fontFamily: "Bebas Neue", fontSize: 34),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                style: TextStyle(color: Colors.black, fontSize: 20),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffff7979),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  hintText: 'Title',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                onChanged: (value) {
                  problemTitle = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: Text('post as unknown',
                    style: TextStyle(fontFamily: "Bebas Neue", fontSize: 30)),
                activeColor: Color(0xffff7979),
                secondary: Icon(
                  FontAwesomeIcons.times,
                  size: 30,
                ),
                value: unKnown,
                onChanged: (bool value) {
                  setState(() {
                    unKnown = value;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Say your Problem :',
                  style: TextStyle(fontFamily: "Bebas Neue", fontSize: 35),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 56.0,
                    height: 56.0,
                    margin: EdgeInsets.all(10.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (!this._isRecording) {
                          return this.startRecorder();
                        }
                        this.stopRecorder();
                      },
                      child: this._isRecording
                          ? Icon(Icons.stop)
                          : Icon(Icons.mic),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    child: Text(
                      this._recorderTxt,
                      style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'listen to it again !!',
                  style: TextStyle(fontFamily: "Bebas Neue", fontSize: 35),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 45.0,
                    height: 45.0,
                    margin: EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        startPlayer();
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
              Container(
                  height: 56.0,
                  child: Slider(
                      value: slider_current_position,
                      min: 0.0,
                      max: max_duration,
                      onChanged: (double value) async {
                        await flutterSound.seekToPlayer(value.toInt());
                      },
                      divisions: max_duration.toInt())),
              SizedBox(
                height: 40,
              ),
              SwitchListTile(
                title: Text('Add Image to problem',
                    style: TextStyle(fontFamily: "Bebas Neue", fontSize: 30)),
                activeColor: Color(0xffff7979),
                secondary: Icon(
                  FontAwesomeIcons.plus,
                  size: 30,
                ),
                value: addImage,
                onChanged: (bool value) {
                  setState(() {
                    addImage = value;
                  });
                },
              ),
              SizedBox(
                height: 40,
              ),
              Visibility(
                visible: addImage,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: sampleImage == null
                          ? Text('add images to your problem !')
                          : Image.file(sampleImage),
                    ),
                    FlatButton(
                      onPressed: getImage,
                      child: Icon(
                        Icons.add_a_photo,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Category',
                  style: TextStyle(fontFamily: "Bebas Neue", fontSize: 35),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: problemCategory,
                    items: [
                      DropdownMenuItem(
                          child: Text('Social Problems',
                              style: TextStyle(
                                  fontFamily: "Bebas Neue", fontSize: 20)),
                          value: 'Social Problems'),
                      DropdownMenuItem(
                          child: Text('Health Problems',
                              style: TextStyle(
                                  fontFamily: "Bebas Neue", fontSize: 20)),
                          value: 'Health Problems'),
                      DropdownMenuItem(
                          child: Text('Economic Problems',
                              style: TextStyle(
                                  fontFamily: "Bebas Neue", fontSize: 20)),
                          value: 'Economic Problems'),
                      DropdownMenuItem(
                          child: Text('Technical Problems',
                              style: TextStyle(
                                  fontFamily: "Bebas Neue", fontSize: 20)),
                          value: 'Technical Problems'),
                      DropdownMenuItem(
                          child: Text('Religious inquiries',
                              style: TextStyle(
                                  fontFamily: "Bebas Neue", fontSize: 20)),
                          value: 'Religious inquiries'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        problemCategory = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              FlatButton(
                onPressed: () => postButton(),
                child: Text(
                  'post your problem',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                color: Color(0xfff1c40f),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              )
            ],
          ),
        ),
      ),
    );
  }
}

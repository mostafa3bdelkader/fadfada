import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categories_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/nanoid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'welcome_screen.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:rich_alert/rich_alert.dart';

class SignUP extends StatefulWidget {
  static final String id = "SignUp_Screen";
  @override
  _SignUPState createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  File sampleImage;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String username;
  String email;
  String password;
  var idGenerator = nanoid(8);
  final usersRef = Firestore.instance.collection('users');

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = image;
    });
  }

  Future<String> uploadImage() async {
    final StorageReference storageRefImage =
        FirebaseStorage.instance.ref().child('image$idGenerator.jpg');
    final StorageUploadTask imageUploadTask =
        storageRefImage.putFile(sampleImage);
    final String imageUrl = await storageRefImage.getDownloadURL();
    return imageUrl;
  }

  signUpButton() async {
    if (_formKey.currentState.validate()) {
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        usersRef.document(email).setData({
          'photoUrl': await uploadImage(),
          'displayName': username,
          'id': idGenerator,
        });
        DocumentSnapshot doc = await usersRef.document(email).get();
        currentUser = User.fromDocument(doc);
        if (newUser != null) {
          Navigator.pushNamed(context, CategoriesScreen.id);
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("sign up problem !"),
                alertSubtitle: richSubtitle("you must add your photo!"),
                alertType: RichAlertType.WARNING,
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'Images/Pink Pattern Funeral Invitation Portrait.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Fadfada',
                    style: TextStyle(
                        fontSize: 40,
                        color: Color(0xffff7979),
                        fontFamily: "Acme"),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      ' + Create Account',
                      style: TextStyle(
                          fontSize: 40,
                          fontFamily: "Acme",
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          validator: (val) => val.length < 3
                              ? 'Must be at least 3 character'
                              : null,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'username',
                            labelStyle: TextStyle(fontSize: 20),
                          ),
                          onChanged: (value) {
                            username = value;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (val) => validator.email(val)
                              ? null
                              : 'please enter your mail',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'email',
                            labelStyle: TextStyle(fontSize: 20),
                          ),
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (val) => validator.password(val)
                              ? null
                              : 'Must have length 6 with numbers,capital letter ',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'password',
                            labelStyle: TextStyle(fontSize: 20),
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: sampleImage == null
                              ? Text(
                                  'add your photo ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : Image.file(sampleImage),
                        ),
                        FlatButton(
                          onPressed: getImage,
                          child: Icon(
                            Icons.add_a_photo,
                            size: 40,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        FlatButton(
                          onPressed: () => signUpButton(),
                          child: Text(
                            'sign up',
                            style: TextStyle(fontSize: 30),
                          ),
                          color: Color(0xfff1c40f),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

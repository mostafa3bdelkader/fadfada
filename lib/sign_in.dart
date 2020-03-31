import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categories_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'welcome_screen.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:rich_alert/rich_alert.dart';

class SignIn extends StatelessWidget {
  static final String id = "SignIn_Screen";

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _auth = FirebaseAuth.instance;
    String email;
    String password;
    final usersRef = Firestore.instance.collection('users');
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Fadfada',
                style: TextStyle(
                    fontSize: 50, color: Color(0xffff7979), fontFamily: "Acme"),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Welcome Back !',
                  style: TextStyle(
                      fontSize: 40,
                      fontFamily: "Acme",
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                          : 'Must have length 6 ,capital letter and numbers',
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
                  ],
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      DocumentSnapshot doc =
                          await usersRef.document(email).get();
                      currentUser = User.fromDocument(doc);
                      if (user != null) {
                        Navigator.pushNamed(context, CategoriesScreen.id);
                      }
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RichAlertDialog(
                              //uses the custom alert dialog
                              alertTitle: richTitle("sign in problem !"),
                              alertSubtitle: richSubtitle(
                                  "you have entered wrong email or password"),
                              alertType: RichAlertType.ERROR,
                            );
                          });
                    }
                  }
                },
                color: Color(0xfff1c40f),
                child: Text(
                  'Sign in',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

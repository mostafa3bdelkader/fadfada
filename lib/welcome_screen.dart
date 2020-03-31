import 'package:fadfada/sign_in.dart';
import 'sign_up.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categories_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'https://www.googleapis.com/auth/drive',
  ],
);
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final usersRef = Firestore.instance.collection('users');
User currentUser;

class WelcomeScreen extends StatefulWidget {
  static final String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('Images/space-4660847_1920.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      'Fadfada',
                      style: TextStyle(
                        fontSize: 100,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black,
                        fontFamily: "Acme",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      'Fadfada',
                      style: TextStyle(
                        fontSize: 100,
                        color: Color(0xffff7979),
                        fontFamily: "Acme",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 25.0, height: 100.0),
                    Text(
                      "Be",
                      style: TextStyle(
                          fontSize: 50.0,
                          color: Color(0xffecf0f1),
                          fontFamily: "Bebas Neue"),
                    ),
                    SizedBox(width: 20.0, height: 60.0),
                    RotateAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: ["AWESOME", "OPTIMISTIC", "Motivated"],
                        textStyle: TextStyle(
                            fontSize: 50,
                            color: Color(0xfff1c40f),
                            fontFamily: "Bebas Neue"),
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional
                            .topStart // or Alignment.topLeft
                        ),
                  ],
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Material(
                  elevation: 10,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                  child: MaterialButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    onPressed: () async {
                      final GoogleSignInAccount googleUser =
                          await _googleSignIn.signIn();
                      final GoogleSignInAuthentication googleAuth =
                          await googleUser.authentication;

                      final AuthCredential credential =
                          GoogleAuthProvider.getCredential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );
                      FirebaseUser userDetails =
                          (await _firebaseAuth.signInWithCredential(credential))
                              .user;
                      Navigator.pushNamed(context, CategoriesScreen.id);
                      final GoogleSignInAccount user =
                          _googleSignIn.currentUser;
                      DocumentSnapshot doc =
                          await usersRef.document(user.email).get();
                      if (!doc.exists) {
                        usersRef.document(user.email).setData({
                          'id': user.id,
                          'photoUrl': user.photoUrl,
                          'displayName': user.displayName,
                        });
                        doc = await usersRef.document(user.email).get();
                      }
                      currentUser = User.fromDocument(doc);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.google),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Sign in with google',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Material(
                  elevation: 10,
                  color: Color(0xfff1c40f),
                  borderRadius: BorderRadius.circular(30),
                  child: MaterialButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, SignIn.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.at),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Sign in with Mail',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Material(
                  elevation: 10,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30),
                  child: MaterialButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 85),
                    onPressed: () {
                      Navigator.pushNamed(context, SignUP.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.userPlus),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

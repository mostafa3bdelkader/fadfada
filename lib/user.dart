import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String photoUrl;
  final String displayName;
  User({this.id, this.photoUrl, this.displayName});
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName']);
  }
}

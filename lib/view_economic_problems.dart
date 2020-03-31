import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'post.dart';

class ViewEconomicProblems extends StatefulWidget {
  static final String id = 'viewEconomicProblems';
  @override
  _ViewEconomicProblemsState createState() => _ViewEconomicProblemsState();
}

class _ViewEconomicProblemsState extends State<ViewEconomicProblems> {
  final _fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Economic Problems',
          textAlign: TextAlign.left,
          style: TextStyle(fontFamily: "Bebas Neue", fontSize: 30),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder(
          stream: _fireStore
              .collection('Economic Problems')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            List<Post> posts = [];
            snapshot.data.documents.forEach((doc) {
              posts.add(Post.fromDocument(doc));
            });
            return ListView(
              children: posts,
            );
          }),
    ));
  }
}

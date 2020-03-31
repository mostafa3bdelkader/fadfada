import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:nanoid/nanoid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String record;
  Comments({this.postId, this.record});
  @override
  _CommentsState createState() =>
      _CommentsState(postId: this.postId, record: this.record);
}

class _CommentsState extends State<Comments> {
  final String postId;
  final String record;
  String comm;
  String commentId = nanoid(8);
  int timeCreated = DateTime.now().millisecondsSinceEpoch;
  TextEditingController commentController = TextEditingController();

  _CommentsState({this.postId, this.record});

  buildComments() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('comments')
            .document(postId)
            .collection('comments')
            .orderBy('likes', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComments() async {
    await Firestore.instance
        .collection('comments')
        .document(postId)
        .collection('comments')
        .document(commentId)
        .setData({
      'username': currentUser.displayName,
      'comment': comm,
      'commentId': commentId,
      'postId': postId,
      'timeCreated': timeCreated,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
      'likes': {},
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'Solutions',
              style: TextStyle(
                  fontFamily: "Bebas Neue",
                  fontSize: 35,
                  color: Colors.black87),
            ),
          ),
        ),
        Expanded(child: buildComments()),
        Divider(),
        ListTile(
          title: TextFormField(
            controller: commentController,
            decoration: InputDecoration(labelText: 'write a comment ...'),
            onChanged: (value) {
              comm = value;
            },
          ),
          trailing: OutlineButton(
            onPressed: addComments,
            borderSide: BorderSide.none,
            child: Text('post'),
          ),
        )
      ],
    ));
  }
}

//this second part
class Comment extends StatefulWidget {
  final String username;
  final String userId;
  final String postId;
  final String avatarUrl;
  final String comment;
  final int timeCreated;
  final dynamic likes;
  final String commentId;
  Comment(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timeCreated,
      this.likes,
      this.commentId,
      this.postId});
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      postId: doc['postId'],
      comment: doc['comment'],
      timeCreated: doc['timeCreated'],
      avatarUrl: doc['avatarUrl'],
      likes: doc['likes'],
      commentId: doc['commentId'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _CommentState createState() => _CommentState(
      username: this.username,
      userId: this.userId,
      comment: this.comment,
      timeCreated: this.timeCreated,
      avatarUrl: this.avatarUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes),
      commentId: this.commentId,
      postId: this.postId);
}

class _CommentState extends State<Comment> {
  final String username;
  final String userId;
  final String postId;
  final String avatarUrl;
  final String comment;
  final int timeCreated;
  final String currentUserId = currentUser?.id;
  final String commentId;
  Map likes;
  int likeCount;
  bool isLiked;
  _CommentState(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.likes,
      this.timeCreated,
      this.likeCount,
      this.commentId,
      this.postId});

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.pink,
            ),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '$username  ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        comment ?? 'following',
                        style: TextStyle(fontSize: 18),
                      ),
                      GestureDetector(
                        child: Icon(
                            isLiked
                                ? FontAwesomeIcons.checkDouble
                                : FontAwesomeIcons.check,
                            size: 30,
                            color: Colors.amber),
                        onTap: () {
                          bool _isLiked = (likes[currentUserId] == true);
                          if (_isLiked) {
                            Firestore.instance
                                .collection('comments')
                                .document(postId)
                                .collection('comments')
                                .document(commentId)
                                .updateData({'likes.$currentUserId': false});
                            setState(() {
                              likeCount -= 1;
                              isLiked = false;
                              likes[currentUserId] = false;
                            });
                          } else if (!_isLiked) {
                            Firestore.instance
                                .collection('comments')
                                .document(postId)
                                .collection('comments')
                                .document(commentId)
                                .updateData({'likes.$currentUserId': true});
                            setState(() {
                              likeCount += 1;
                              isLiked = true;
                              likes[currentUserId] = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 28,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      TimeAgo.getTimeAgo(timeCreated),
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w800),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        '$likeCount agree',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

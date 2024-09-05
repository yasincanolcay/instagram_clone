// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String author;
  final List<String> contentUrl;
  final List hastags;
  final bool isComment;
  final bool isDownload;
  final String music;
  final String postId;
  final DateTime publishDate;
  final String type;
  final bool verified;
  final Map location;
  final List<Map> users;
  final String musicName;
  final Map musicData;
  const Post({
    required this.description,
    required this.author,
    required this.contentUrl,
    required this.hastags,
    required this.isComment,
    required this.isDownload,
    required this.music,
    required this.postId,
    required this.publishDate,
    required this.type,
    required this.verified,
    required this.location,
    required this.users,
    required this.musicName,
    required this.musicData,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'author': author,
        'contentUrl': contentUrl,
        'hastags': hastags,
        'isComment': isComment,
        'isDownload': isDownload,
        'music': music,
        'postId': postId,
        'publishDate': publishDate,
        'type': type,
        'verified': verified,
        "location": location,
        "users": users,
        "musicName": musicName,
        "musicData": musicData,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return Post(
      description: snapshot['description'],
      author: snapshot['author'],
      contentUrl: snapshot['contentUrl'],
      hastags: snapshot['hastags'],
      isComment: snapshot['isComment'],
      isDownload: snapshot['isDownload'],
      music: snapshot['music'],
      postId: snapshot['postId'],
      publishDate: snapshot['publishDate'],
      type: snapshot['type'],
      verified: snapshot['verified'],
      location: snapshot["location"],
      users: snapshot["users"],
      musicName: snapshot["musicName"],
      musicData: snapshot["musicData"],
    );
  }
}

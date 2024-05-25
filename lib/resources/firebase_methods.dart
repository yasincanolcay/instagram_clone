import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirebaseMethods {
  final fire = FirebaseFirestore.instance;

  Future<bool> uploadPost(
    String description,
    String author,
    List<String> hastags,
    bool isComment,
    bool isDownload,
    String music,
    String type,
    Map location,
    List<Map> users,
    List<Uint8List> bytes,
  ) async {
    try {
      List<String> contentUrl = [];
      for (var element in bytes) {
        String url =
            await StorageMethods().uploadImageToStorage("posts", element, true);
        contentUrl.add(url);
      }
      String id = Uuid().v1();
      Post post = Post(
        description: description,
        author: author,
        contentUrl: contentUrl,
        hastags: hastags,
        isComment: isComment,
        isDownload: isDownload,
        music: music,
        postId: id,
        publishDate: DateTime.now(),
        type: type,
        verified: true,
        location: location,
        users: users,
      );
      await fire.collection("Posts").doc(id).set(post.toJson());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }
}

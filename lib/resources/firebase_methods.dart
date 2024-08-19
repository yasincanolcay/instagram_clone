import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/answer.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirebaseMethods {
  final fire = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

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
    String musicName,
  ) async {
    try {
      List<String> contentUrl = [];
      for (var element in bytes) {
        String url =
            await StorageMethods().uploadImageToStorage("posts", element, true);
        contentUrl.add(url);
      }
      String id = const Uuid().v1();
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
        musicName: musicName
      );
      await fire.collection("Posts").doc(id).set(post.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> likeOrUnLike(
      String postId, String uid, String author, bool isLike) async {
    try {
      //Eğer begeneceksek!
      if (isLike) {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .set({
          "uid": uid,
        });
      } else {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .delete();
      }

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendComment(
      String postId, String uid, String text, String type) async {
    try {
      String commentId = const Uuid().v1();
      Comment comment = Comment(
          text: text,
          uid: uid,
          commentId: commentId,
          date: DateTime.now(),
          type: type);
      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .set(comment.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendAnswer(String postId, String uid, String text, String type,
      String username, String answerUid, String commentId) async {
    try {
      String answerId = const Uuid().v1();
      Answer comment = Answer(
        text: text,
        uid: uid,
        answerId: answerId,
        date: DateTime.now(),
        type: type,
        answerUid: answerUid,
        username: username,
      );
      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("answers")
          .doc(answerId)
          .set(comment.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> likeComment(
      String postId, String commentId, String uid, bool isLike) async {
    try {
      if (isLike) {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("likes")
            .doc(uid)
            .set({
          "uid": uid,
        });
      } else {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("likes")
            .doc(uid)
            .delete();
      }

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> likeAnswer(String postId, String commentId, String answerId,
      String uid, bool isLike) async {
    try {
      if (isLike) {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("answers")
            .doc(answerId)
            .collection("likes")
            .doc(uid)
            .set({
          "uid": uid,
        });
      } else {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("answers")
            .doc(answerId)
            .collection("likes")
            .doc(uid)
            .delete();
      }

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> savePost(
    String postId,
    String collectionName,
    String thumbnail,
  ) async {
    try {
      await fire
          .collection("users")
          .doc(uid)
          .collection("SavedPosts")
          .doc(postId)
          .set({
        "postId": postId,
        "thumbnail": thumbnail,
        "collectionName": collectionName,
      });
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> unSavePost(String postId) async {
    try {
      await fire
          .collection("users")
          .doc(uid)
          .collection("SavedPosts")
          .doc(postId)
          .delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteAnswer(
      String postId, String commentId, String answerId) async {
    try {
      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("answers")
          .doc(answerId)
          .delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendAnswerComplaints(
    String sender,
    String user,
    String type,
    String answerId,
    String postId,
    String commentId,
  ) async {
    try {
      String id = Uuid().v1();
      await fire.collection("AnswerComplaints").doc(id).set({
        "sender": sender,
        "user": user,
        "type": type,
        "date": DateTime.now(),
        "answerId": answerId,
        "postId": postId,
        "commentId": commentId,
      });
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendCommentComplaints(
    String sender,
    String user,
    String type,
    String commentId,
    String postId,
  ) async {
    try {
      String id = Uuid().v1();
      await fire.collection("CommentComplaints").doc(id).set({
        "sender": sender,
        "user": user,
        "type": type,
        "date": DateTime.now(),
        "postId": postId,
        "commentId": commentId,
      });
      return true;
    } catch (err) {
      return false;
    }
  }
}

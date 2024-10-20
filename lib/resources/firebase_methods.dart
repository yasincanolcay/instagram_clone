import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart' as cloudPublic;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/answer.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/reel.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:cloudinary/cloudinary.dart';

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
    Map musicData,
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
          musicData: musicData,
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
          musicName: musicName);
      await fire.collection("Posts").doc(id).set(post.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> uploadReels(
    String filePath,
    String thumbnail,
    String description,
    String author,
    List hastags,
    bool isComment,
    bool isDownload,
    String music,
    DateTime publishDate,
    String type,
    Map location,
    List<Map> users,
  ) async {
    try {
      final cloudinary = cloudPublic.CloudinaryPublic(
        'dyauibzig',
        'bwyx9qsv',
        cache: false,
      );
      final res = await cloudinary.uploadFileInChunks(
        cloudPublic.CloudinaryFile.fromFile(
          filePath,
          folder: 'public',
        ),
        chunkSize: 10000000,
        onProgress: (count, total) {
          //uploadingPercentage = (count / total) * 100; sonra yüzdeyi alırız.
          //print("Video: ${(count / total) * 100}");
        },
      );
      cloudPublic.CloudinaryResponse response = await cloudinary.uploadFile(
        cloudPublic.CloudinaryFile.fromFile(
          thumbnail,
          resourceType: cloudPublic.CloudinaryResourceType.Image,
        ),
        onProgress: (count, total) {
          //print("Thumbnail: ${(count / total) * 100}");
        },
      );
      if (res!.data.isNotEmpty && response.data.isNotEmpty) {
        String postId = const Uuid().v1();
        Reel post = Reel(
          description: description,
          author: author,
          contentUrl: res.url,
          hastags: hastags,
          isComment: isComment,
          isDownload: isDownload,
          music: music,
          postId: postId,
          publishDate: publishDate,
          type: type,
          verified: true,
          thumbnail: response.secureUrl,
          deleteToken: [res.publicId, response.publicId],
          location: location,
          users: users,
          musicData: {},
          musicName: "",
        );
        await fire.collection('Posts')
          ..doc(postId).set(post.toJson());
        return true;
      } else {
        return false;
      }
    } catch (er) {
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
      String id = const Uuid().v1();
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
      String id = const Uuid().v1();
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

  Future<bool> editPost(Map<String, dynamic> data, String postId) async {
    try {
      await fire.collection("Posts").doc(postId).update(data);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deletePost(Map snap, BuildContext context) async {
    try {
      if (snap["type"] == "photo") {
        for (int i = 0; i < snap["contentUrl"].length; i++) {
          Reference photoRef =
              FirebaseStorage.instance.refFromURL(snap["contentUrl"][i]);
          await photoRef.delete();
        }
      } else {
        final cloudinary = Cloudinary.signedConfig(
          cloudName: "dyauibzig",
          apiKey: "957237589686648",
          apiSecret: "FF7bOxVtNuvQHZsG9y-sz-p4eF4",
        );
        final response = await cloudinary.destroy(
          snap["deleteToken"][0],
          url: snap["contentUrl"],
          resourceType: CloudinaryResourceType.video,
          invalidate: true,
        );
        final thumbResponse = await cloudinary.destroy(
          snap["deleteToken"][1],
          url: snap["thumbnail"],
          resourceType: CloudinaryResourceType.image,
          invalidate: true,
        );
        if (!response.isSuccessful && !thumbResponse.isSuccessful) {
          Utils().showSnackBar(
              "Video içeriği silinemedi", context, backgroundColor);
        }
      }
      await fire.collection("Posts").doc(snap["postId"]).delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> followOrUnFollow(
      String uid, String userUid, bool isFollow) async {
    try {
      if (isFollow) {
        await fire
            .collection("users")
            .doc(uid)
            .collection("followings")
            .doc(userUid)
            .set({
          "uid": userUid,
        });
        await fire
            .collection("users")
            .doc(userUid)
            .collection("following")
            .doc(uid)
            .set({
          "uid": uid,
        });
      } else {
        await fire
            .collection("users")
            .doc(uid)
            .collection("followings")
            .doc(userUid)
            .delete();
        await fire
            .collection("users")
            .doc(userUid)
            .collection("following")
            .doc(uid)
            .delete();
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendPostComplain(
    String postId,
    String complain,
    String author,
    String sender,
  ) async {
    try {
      String id = Uuid().v1();
      await fire.collection("PostComplaints").doc(id).set({
        "postId": postId,
        "complain": complain,
        "sender": sender,
        "author": author,
      });
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> editProfile(String uid, String username, String bio,
      Uint8List? image, String profilePhoto) async {
    try {
      String profilePhotoUrl = profilePhoto;
      if (image != null) {
        profilePhotoUrl = await StorageMethods()
            .uploadImageToStorage("ProfilePhotos", image, false);
      }
      await fire.collection("users").doc(uid).update({
        "username": username,
        "bio": bio,
        "profilePhoto": profilePhotoUrl,
      });
      return true;
    } catch (err) {
      return false;
    }
  }
}

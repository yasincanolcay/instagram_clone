// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/answer.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/more_answer_process.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';

class AnswerCard extends StatefulWidget {
  const AnswerCard({
    super.key,
    required this.snapshot,
    required this.postSnap,
    required this.progressForAnswer,
    required this.commentSnap,
  });
  final Answer snapshot;
  final postSnap;
  final Comment commentSnap;
  final Function(Map data) progressForAnswer;

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  String username = "";
  String profilePhoto = "";
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool verified = false;
  List<String> likesList = [];
  bool showMore = false;
  void getUserData() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snapshot.uid)
        .get();
    username = userSnap.data()!["username"];
    profilePhoto = userSnap.data()!["profilePhoto"];
    verified = userSnap.data()!["verified"];
    setState(() {});
    getLikes();
  }

  void getLikes() async {
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postSnap["postId"])
        .collection("comments")
        .doc(widget.commentSnap.commentId)
        .collection("answers")
        .doc(widget.snapshot.answerId)
        .collection("likes")
        .get()
        .then((value) {
      for (var element in value.docs) {
        likesList.add(element.data()["uid"]);
      }
    });
    setState(() {});
  }

  void likeComment() async {
    bool response = await FirebaseMethods().likeAnswer(
        widget.postSnap["postId"],
        widget.commentSnap.commentId,
        widget.snapshot.answerId,
        uid,
        !likesList.contains(uid));
    if (!response) {
      if (mounted) {
        Utils().showSnackBar("Yanıt begenilemedi!", context, redColor);
      }
    } else {
      if (likesList.contains(uid)) {
        likesList.removeWhere((element) => element == uid);
      } else {
        likesList.add(uid);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                25,
              ),
            ),
          ),
          context: context,
          builder: (context) => MoreAnswerProcess(
            uid: uid,
            postId: widget.postSnap["postId"],
            answerId: widget.snapshot.answerId,
            commentId: widget.commentSnap.commentId,
            isItMineOfUid: uid == widget.snapshot.answerUid,
            answerAuthor: widget.snapshot.answerUid,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePhoto.isNotEmpty
                ? CircleAvatar(
                    radius: 15,
                    backgroundImage: CachedNetworkImageProvider(
                      profilePhoto,
                      cacheManager: GlobalClass.customCacheManager,
                    ),
                  )
                : const CircleAvatar(
                    radius: 15,
                  ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "$username ",
                                    style: const TextStyle(
                                      fontFamily: "poppins1",
                                      color: textColor,
                                    )),
                                WidgetSpan(
                                  child: verified
                                      ? const Icon(Icons.verified, size: 16.0)
                                      : const SizedBox(),
                                ),
                                TextSpan(
                                  text: widget.snapshot.username.isNotEmpty
                                      ? "${widget.snapshot.username} "
                                      : "",
                                  style: const TextStyle(
                                    fontFamily: "poppins1",
                                    color: Colors.blue,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.snapshot.text,
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    color: textColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        DateFormat.yMMMd().add_Hm().format(
                              widget.snapshot.date,
                            ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.progressForAnswer({
                          "answerUid": widget.snapshot.uid,
                          "commentId": widget.commentSnap.commentId,
                          "username": username,
                          "answerCard": true,
                        });
                      },
                      child: const Text("Yanıtla"),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: likeComment,
                  icon: Icon(
                    !likesList.contains(uid)
                        ? CupertinoIcons.heart
                        : CupertinoIcons.heart_fill,
                    color: !likesList.contains(uid) ? null : redColor,
                  ),
                ),
                Text("${likesList.length} Begeni"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

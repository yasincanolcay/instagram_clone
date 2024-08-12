// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/answer.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/answer_card.dart';
import 'package:instagram_clone/screens/comment/more_comment_process.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';
import '../../models/comment.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.snapshot,
    required this.postSnap,
    required this.progressForAnswer,
  });
  final Comment snapshot;
  final postSnap;
  final Function(Map data) progressForAnswer;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late Future future;
  String username = "";
  String profilePhoto = "";
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool verified = false;
  List<String> likesList = [];
  bool showMore = false;
  int answersLength = 0;
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
        .doc(widget.snapshot.commentId)
        .collection("likes")
        .get()
        .then((value) {
      for (var element in value.docs) {
        likesList.add(element.data()["uid"]);
      }
    });
    setState(() {});
    getAnswers();
  }

  void getAnswers() async {
    var snap = await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postSnap["postId"])
        .collection("comments")
        .doc(widget.snapshot.commentId)
        .collection("answers")
        .get();
    setState(() {
      answersLength = snap.docs.length;
    });
  }

  void likeComment() async {
    bool response = await FirebaseMethods().likeComment(
        widget.postSnap["postId"],
        widget.snapshot.commentId,
        uid,
        !likesList.contains(uid));
    if (!response) {
      if (mounted) {
        Utils().showSnackBar("Yorum begenilemedi!", context, redColor);
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
    future = FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postSnap["postId"])
        .collection("comments")
        .doc(widget.snapshot.commentId)
        .collection("answers")
        .get();
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
          builder: (context) => MoreCommentProcess(
            uid: uid,
            postId: widget.postSnap["postId"],
            commentId: widget.snapshot.commentId,
            isItMineOfUid: uid == widget.snapshot.uid,
            commentAuthor:  widget.snapshot.uid,
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
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.progressForAnswer({
                              "answerUid": widget.snapshot.uid,
                              "commentId": widget.snapshot.commentId,
                              "username": username,
                              "answerCard": false,
                            });
                          },
                          child: const Text("Yanıtla"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showMore = !showMore;
                            });
                          },
                          child: Text(
                            !showMore
                                ? "Tüm Yanıtları Gör($answersLength)"
                                : "Yanıtları Gizle",
                          ),
                        ),
                      ],
                    ),
                    //Yanıtlar burada build edilecek
                    //-----
                    showMore
                        ? FutureBuilder(
                            future: future,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                  ),
                                );
                              }
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  Answer answer = Answer.fromSnap(
                                      snapshot.data!.docs[index]);
                                  return AnswerCard(
                                    snapshot: answer,
                                    postSnap: widget.postSnap,
                                    progressForAnswer: widget.progressForAnswer,
                                    commentSnap: widget.snapshot,
                                  );
                                },
                              );
                            },
                          )
                        : const SizedBox(),
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

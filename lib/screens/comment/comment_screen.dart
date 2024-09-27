// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/comment_card.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import '../../models/comment.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    super.key,
    required this.snap, required this.isReelsPage,
  });
  final snap;
  final bool isReelsPage;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Future? future;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _node = FocusNode();
  bool isAnswer = false; //yorum mu/yanıt mı?
  String answerUid = ""; //yanıt verilen kişinin uid'si
  String commentId = ""; //yanıt verilen yorum id
  String username = "";
  bool answerCard = false; //yanıtın yanıtı veya yorumun yanıtı?

  void sendComment() async {
    if (_controller.text.isNotEmpty) {
      bool response = await FirebaseMethods()
          .sendComment(widget.snap["postId"], uid, _controller.text, "text");
      if (!response) {
        if (mounted) {
          Utils().showSnackBar(
              "Yorum yapılamadı, sonra tekrar deneyiniz!", context, redColor);
        }
      } else {
        _controller.clear();
        future = FirebaseFirestore.instance
            .collection("Posts")
            .doc(widget.snap["postId"])
            .collection("comments")
            .get();
            setState(() {
              
            });
      }
    }
  }

  void sendAnswer() async {
    bool response = await FirebaseMethods().sendAnswer(widget.snap["postId"],
        uid, _controller.text, "text", username, answerUid, commentId);
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
            "Yanıt verilemedi, sonra tekrar deneyiniz!", context, redColor);
      }
    } else {
      _controller.clear();
      isAnswer = false;
      future = FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.snap["postId"])
          .collection("comments")
          .get();
      setState(() {});
    }
  }

  void progressForAnswer(Map data) {
    isAnswer = true;
    answerUid = data["answerUid"];
    commentId = data["commentId"];
    answerCard = data["answerCard"];
    username = "@${data["username"]}";
    _node.requestFocus();
    setState(() {});
  }

  @override
  void initState() {
    future = FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.snap["postId"])
        .collection("comments")
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isReelsPage,
        title: const Text("Yorumlar"),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Comment comment = Comment.fromSnap(snapshot.data!.docs[index]);

              return CommentCard(
                snapshot: comment,
                postSnap: widget.snap,
                progressForAnswer: progressForAnswer,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.only(left: 8.0, right: 4.0),
          height: 45,
          decoration: const BoxDecoration(
            color: textFieldColor,
            borderRadius: BorderRadius.all(
              Radius.circular(
                25,
              ),
            ),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _node,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Yorumunuzu girin...",
              suffixIcon: IconButton(
                //burada yanıt verme işlemleride yapılacak!!
                onPressed: !isAnswer ? sendComment : sendAnswer,
                icon: const Icon(
                  Icons.send_rounded,
                ),
              ),
              prefixIcon: isAnswer
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontFamily: "poppins1",
                            color: Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAnswer = false;
                              answerCard = false;
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: textColor,
                          ),
                        )
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

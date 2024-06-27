import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';

import '../../models/comment.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();
  void sendComment() async {
    if (_controller.text.isNotEmpty) {
      bool response = await FirebaseMethods()
          .sendComment(widget.snap["postId"], uid, _controller.text, "text");
      if (!response) {
        if (mounted) {
          Utils().showSnackBar(
              "Yorum yapılamadı, sonra tekrar deneyiniz!", context, redColor);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      appBar: AppBar(
        title: const Text("Yorumlar"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("Posts")
            .doc(widget.snap["postId"])
            .collection("comments")
            .get(),
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
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Yorumunuzu girin...",
              suffixIcon: IconButton(
                //burada yanıt verme işlemleride yapılacak!!
                onPressed: sendComment,
                icon: const Icon(
                  Icons.send_rounded,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.snapshot,
    required this.postSnap,
  });
  final Comment snapshot;
  final postSnap;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String username = "";
  String profilePhoto = "";
  bool verified = false;
  List<String> likesList = [];
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
    setState(() {
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              : CircleAvatar(
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
                                  style: TextStyle(
                                    fontFamily: "poppins1",
                                    color: textColor,
                                  )),
                              WidgetSpan(
                                child: verified
                                    ? Icon(Icons.verified, size: 16.0)
                                    : SizedBox(),
                              ),
                              TextSpan(
                                text: widget.snapshot.text,
                                style: TextStyle(
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
                          onPressed: () {}, child: const Text("Yanıtla")),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Tüm Yanıtları Gör(0)",
                        ),
                      ),
                    ],
                  ),
                  //Yanıtlar burada build edilecek
                  //-----
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.heart,
                ),
              ),
              Text("${likesList.length} Begeni"),
            ],
          ),
        ],
      ),
    );
  }
}

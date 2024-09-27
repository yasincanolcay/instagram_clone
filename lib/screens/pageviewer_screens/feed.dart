import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/widgets/postwidgets/post_card.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final AudioPlayersMethods playerMethods = AudioPlayersMethods();
  final Future future = FirebaseFirestore.instance
      .collection("Posts")
      .where("verified", isEqualTo: true)
      .orderBy("publishDate", descending: true)
      .get();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
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
                  color: Colors.red,
                ),
              );
            }
            return SafeArea(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      index == 0
                          ? Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "İnstagram",
                                    style: TextStyle(
                                        fontFamily: "insta", fontSize: 17),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.favorite_outline_rounded,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      CupertinoIcons.chat_bubble_text_fill,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      index == 0
                          ? Material(
                              color: Colors.white,
                              child: SizedBox(
                                height: 70,
                                child: ListView.builder(
                                  itemCount: 8,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 100,
                                      child: Column(
                                        children: [
                                          CircleAvatar(),
                                          Text("Username"),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : SizedBox(),
                      PostCard(
                        snap: snapshot.data!.docs[index].data(),
                        playerMethods: playerMethods,
                      ),
                    ],
                  );
                },
              ),
            );
          }),
    );
  }
}

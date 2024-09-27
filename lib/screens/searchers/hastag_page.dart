// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/push/post_viewer_page.dart';
import 'package:instagram_clone/utils/colors.dart';

class HashtagPage extends StatefulWidget {
  HashtagPage({
    super.key,
    required this.isPost,
    required this.hashtag,
    required this.isClick,
    required this.isChangedSetter,
  });
  final bool isPost;
  String hashtag;
  bool isClick = false;
  final Function(bool value, String st) isChangedSetter;

  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('Posts');

  Future<List<String>> searchHashtags(String keyword) async {
    List<String> matchingHashtags = [];
    QuerySnapshot querySnapshot = await postsCollection.get();
    for (var document in querySnapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<String> hashtags = List<String>.from(data['hastags']);
      for (var key in hashtags) {
        if (key.startsWith(keyword)) {
          if (!matchingHashtags.contains(key)) {
            matchingHashtags.add(key);
          }
        }
      }
    }
    return matchingHashtags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: widget.isClick
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("Posts")
                  .where("hastags", arrayContains: " ${widget.hashtag}")
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        snapshot.data!.docs[index].data();
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PostViewerPage(
                              snap: data,
                            ),
                          ),
                        );
                      },
                      child: data["type"] == "photo"
                          ? Image.network(
                              data["contentUrl"][0],
                              fit: BoxFit.cover,
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  data["thumbnail"],
                                  fit: BoxFit.cover,
                                ),
                                const Positioned(
                                  bottom: 8.0,
                                  left: 8.0,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Reel",
                                        style: TextStyle(
                                          fontFamily: "poppins1",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: searchHashtags(" ${widget.hashtag}"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          widget.hashtag = snapshot.data![index];
                          widget.isChangedSetter(
                              false, snapshot.data![index].trimLeft());
                        });
                      },
                      leading: const Icon(
                        Icons.tag_rounded,
                        color: textColor,
                      ),
                      title: Text(
                        snapshot.data![index],
                        style: const TextStyle(
                          color: textColor,
                          fontFamily: "poppins1",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

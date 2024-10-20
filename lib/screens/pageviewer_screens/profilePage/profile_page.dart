// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/auth/login_screen.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/components/followers_builder.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/components/following_builder.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/components/sign_out_alert.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/edit_post_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/page_routes.dart';
import 'package:instagram_clone/widgets/post_share_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/post_grid_card.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key, required this.uid});
  String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;

  String username = "";
  String profilePhoto = "";
  bool verified = false;
  String bio = "...";
  List<String> followings = [];
  List<String> followers = [];
  int postLength = 0;
  bool isLoaded = false;
  var userSnap;

  void getFollowing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followings")
        .get()
        .then((value) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        followings.add(element.data()["uid"]);
        setState(() {});
      }
    });
    setState(() {});
    getFollowers();
  }

  void getFollowers() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followers")
        .get()
        .then((value) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        followers.add(element.data()["uid"]);
        setState(() {});
      }
    });
    setState(() {});
    getPost();
  }

  void getPost() async {
    QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection("Posts")
        .where("verified", isEqualTo: true)
        .where("author", isEqualTo: widget.uid)
        .get();
    setState(() {
      postLength = snap.docs.length;
      isLoaded = true;
    });
  }

  void getUserData() async {
    userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get();
    username = userSnap.data()!["username"];
    profilePhoto = userSnap.data()!["profilePhoto"];
    verified = userSnap.data()!["verified"];
    bio = userSnap.data()!["bio"];
    if (mounted) {
      setState(() {});
    }
    getFollowing();
  }

  void followOrUnFollow() async {
    bool response = await FirebaseMethods()
        .followOrUnFollow(myUid, widget.uid, !followers.contains(myUid));
    if (response) {
      if (!followers.contains(myUid)) {
        followers.add(myUid);
      } else {
        followers.removeWhere((element) => element == myUid);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    if (widget.uid.isEmpty) {
      widget.uid = currentUser.uid;
      setState(() {});
    }
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: textWhiteColor,
      appBar: AppBar(
        backgroundColor: textWhiteColor,
        scrolledUnderElevation: 0.0,
        bottomOpacity: 0.0,
        title: Text(
          username,
          style: const TextStyle(color: textColor, fontFamily: "poppins1"),
        ),
        elevation: 0.0,
        actions: [
          widget.uid == myUid
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          builder: (context) {
                            return PostShareSheet();
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.menu_rounded,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: CachedNetworkImageProvider(
                                      profilePhoto,
                                      cacheManager:
                                          GlobalClass.customCacheManager,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontFamily: "poppins1",
                                    ),
                                  ),
                                ],
                              ),
                              buildStatColumn(postLength, "Gönderi"),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowersBuilder(
                                        uid: widget.uid,
                                      ),
                                    ),
                                  );
                                },
                                child: buildStatColumn(
                                    followers.length, "Takipçi"),
                              ),
                              GestureDetector(
                                onTap: (){
                                   Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowingBuilder(
                                        uid: widget.uid,
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    buildStatColumn(followings.length, "Takip"),
                              ),
                            ],
                          ),
                          BioContainer(bio: bio),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (widget.uid == myUid) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditPostScreen(
                                              snap: userSnap!,
                                            ),
                                          ),
                                        );
                                      } else {
                                        followOrUnFollow();
                                      }
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              textWhiteColor),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.blue),
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      widget.uid == myUid
                                          ? "Profili Düzenle"
                                          : (followers.contains(myUid)
                                              ? "Takibi Bırak"
                                              : "Takip Et"),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (widget.uid == myUid) {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const SignOutAlert(),
                                        );
                                      } else {
                                        //chat sayfasını ac
                                      }
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              textWhiteColor),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.blue),
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      widget.uid == myUid
                                          ? "Çıkış Yap"
                                          : "Mesaj Gönder",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              const TabBar(tabs: [
                Tab(
                  icon: Icon(
                    Icons.grid_on_rounded,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.movie_filter_sharp,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.tag_rounded,
                  ),
                ),
              ]),
              Expanded(
                child: TabBarView(
                  children: [
                    isLoaded
                        ? PostBuilder(
                            type: "all",
                            uid: widget.uid,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                    isLoaded
                        ? PostBuilder(
                            type: "reels",
                            uid: widget.uid,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                    isLoaded
                        ? PostBuilder(
                            type: "tag",
                            uid: widget.uid,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BioContainer extends StatefulWidget {
  const BioContainer({
    super.key,
    required this.bio,
  });

  final String bio;

  @override
  State<BioContainer> createState() => _BioContainerState();
}

class _BioContainerState extends State<BioContainer> {
  bool _showMore = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.bio,
          maxLines: !_showMore ? 3 : null,
          overflow: !_showMore ? TextOverflow.ellipsis : TextOverflow.visible,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _showMore = !_showMore;
            });
          },
          child: Text(!_showMore ? "Daha fazla" : "Daha Az"),
        ),
      ],
    );
  }
}

class PostBuilder extends StatefulWidget {
  const PostBuilder({
    super.key,
    required this.type,
    required this.uid,
  });
  final String type;
  final String uid;

  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  Future<List<DocumentSnapshot>> fetchPosts() async {
    List<DocumentSnapshot> filteredPosts = [];

    QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection("Posts")
        .where("verified", isEqualTo: true)
        .get();

    for (var element in snap.docs) {
      List<dynamic> users = List.from(element.data()["users"]);
      for (var user in users) {
        if (user["uid"] == myUid) {
          filteredPosts.add(element);
        }
      }
    }

    return filteredPosts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.type == "all"
            ? FirebaseFirestore.instance
                .collection("Posts")
                .where("author", isEqualTo: widget.uid)
                .where("verified", isEqualTo: true)
                .get()
            : widget.type == "reels"
                ? FirebaseFirestore.instance
                    .collection("Posts")
                    .where("author", isEqualTo: widget.uid)
                    .where("verified", isEqualTo: true)
                    .where("type", isEqualTo: "reels")
                    .get()
                : fetchPosts(),
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
          return GridView.builder(
            itemCount: widget.type == "all" || widget.type == "reels"
                ? (snapshot.data! as dynamic).docs.length
                : (snapshot.data! as dynamic).length,
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
              return PostGridCard(
                data: widget.type == "all" || widget.type == "reels"
                    ? (snapshot.data as dynamic).docs[index].data()
                    : (snapshot.data as dynamic)[index].data(),
              );
            },
          );
        });
  }
}

Column buildStatColumn(int number, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        number.toString(),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      Container(
        margin: const EdgeInsets.only(top: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  );
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/page_routes.dart';

class FollowingBuilder extends StatefulWidget {
  const FollowingBuilder({
    super.key,
    required this.uid,
  });
  final String uid;

  @override
  State<FollowingBuilder> createState() => _FollowingBuilderState();
}

class _FollowingBuilderState extends State<FollowingBuilder> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> following = [];
  List<String> myFollowing = [];
  bool isLoading = false;
  void getUserfollowing() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followings")
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(element.data()["uid"])
            .get()
            .then((value) {
          following.add(value.data()!);
          setState(() {});
        });
      });
    });

    getMyFollowing();
  }

  void getMyFollowing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("followings")
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(element.data()["uid"])
            .get()
            .then((value) {
          myFollowing.add(value.data()!["uid"]);
          setState(() {});
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  void followOrUnFollow(String uid) async {
    bool response = await FirebaseMethods()
        .followOrUnFollow(myUid, uid, !myFollowing.contains(uid));
    if (response) {
      if (!myFollowing.contains(uid)) {
        myFollowing.add(uid);
      } else {
        myFollowing.removeWhere((element) => element == uid);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getUserfollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Takip Edilenler"),
      ),
      body: !isLoading
          ? ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: (){
                     currentUser.uid = following[index]["uid"];
                      currentUser.page = 3;
                      Navigator.pushNamed(
                        context,
                        PageRouteNames.profile,
                      );
                  },
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      following[index]["profilePhoto"],
                      cacheManager: GlobalClass.customCacheManager,
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        following[index]["username"],
                        style: const TextStyle(
                          fontFamily: "poppins1",
                        ),
                      ),
                      following[index]["verified"]
                          ? const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  isThreeLine: false,
                  subtitle: Text(
                    following[index]["bio"],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      if (myUid != following[index]["uid"]) {
                        followOrUnFollow(following[index]["uid"]);
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          const MaterialStatePropertyAll(textWhiteColor),
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.blue),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: myUid != following[index]["uid"]
                        ? Text(
                            !myFollowing.contains(following[index]["uid"])
                                ? "Takip Et"
                                : "Takip",
                          )
                        : Text("Siz"),
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

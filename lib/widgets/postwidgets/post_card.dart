import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/hashtagable.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/comment_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  String profilePhoto = "";
  bool verified = false;
  bool showMore = false;
  double photoCurrentIndex = 0;
  List<String> likedList = [];

  void getUserData() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snap["author"])
        .get();
    username = userSnap.data()!["username"];
    profilePhoto = userSnap.data()!["profilePhoto"];
    verified = userSnap.data()!["verified"];
    setState(() {});
  }

  void likeOrUnLike(bool isLike) async {
    bool response = await FirebaseMethods().likeOrUnLike(
        widget.snap["postId"], uid, widget.snap["author"], isLike);
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
          "Gönderi şuan begenilemiyor, sonra tekrar deneyin!",
          context,
          redColor,
        );
      }
    } else {
      if (isLike) {
        likedList.add(uid);
      } else {
        likedList.removeWhere((element) => element == uid);
      }
      setState(() {});
    }
  }

  void getPostdata() async {
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.snap["postId"])
        .collection("likes")
        .get()
        .then((value) {
      for (var element in List.from(value.docs)) {
        likedList.add(element["uid"]);
      }
    });
    setState(() {});
    getUserData();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    getPostdata();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            leading: profilePhoto != ""
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      profilePhoto,
                      cacheManager: GlobalClass.customCacheManager,
                    ),
                  )
                : const CircleAvatar(),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                  ),
                ),
                verified
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
            subtitle: locationAndMusicChecker(),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert_rounded,
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              _controller.forward();
              if (!likedList.contains(uid)) {
                likeOrUnLike(true);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExpandablePageView(
                  onPageChanged: (value) {
                    setState(() {
                      photoCurrentIndex = value.toDouble();
                    });
                  },
                  children: List.generate(
                    widget.snap["contentUrl"].length,
                    (index) => CachedNetworkImage(
                      cacheManager: GlobalClass.customCacheManager,
                      key: UniqueKey(),
                      memCacheHeight: 800,
                      imageUrl: widget.snap['contentUrl'][index],
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorWidget: (context, error, stackTrace) {
                        return Center(
                          child: Image.asset(
                            'assets/images/error.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        );
                      },
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: ScaleTransition(
                      scale: _animation,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 0.0,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  likeOrUnLike(!likedList.contains(uid));
                },
                icon: Icon(
                  !likedList.contains(uid)
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill,
                  color: !likedList.contains(uid) ? textColor : redColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        snap: widget.snap,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.text_bubble,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Transform.rotate(
                  angle: -0.8,
                  child: const Icon(
                    Icons.send_rounded,
                  ),
                ),
              ),
              const Spacer(),
              SmoothIndicator(
                offset: photoCurrentIndex, //değişim yapıacagız
                count: widget.snap["contentUrl"].length,
                size: const Size(10, 10),
                effect: const ScrollingDotsEffect(
                  activeDotColor: textColor,
                  activeStrokeWidth: 0.5,
                  dotHeight: 8,
                  dotWidth: 8,
                  fixedCenter: true,
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.bookmark,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${likedList.length} Begeni",
              style: const TextStyle(
                fontFamily: "poppins1",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Wrap(
                children: [
                  RichText(
                    softWrap: true,
                    overflow: !showMore
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                    maxLines: !showMore ? 3 : null,
                    text: TextSpan(children: [
                      const TextSpan(
                        text: "Username ",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      getHashTagTextSpan(
                        onTap: (hastag) {
                          print(hastag);
                        },
                        source: widget.snap['description'],
                        decoratedStyle:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                        basicStyle:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMore = !showMore;
                      });
                    },
                    child: Text(!showMore ? " Daha Fazla" : " Daha Az"),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            thickness: 0.0,
          ),
        ],
      ),
    );
  }

  Widget locationAndMusicChecker() {
    Map location = Map.from(widget.snap["location"]);
    String music = widget.snap["music"];
    if (location.isEmpty && music.isEmpty) {
      return SizedBox();
    } else if (location.isNotEmpty && music.isNotEmpty) {
      //animasyonlu yazı döndüreceğiz
      return Text(
          "${widget.snap["location"]["fulladdress"]} - ${widget.snap["music"]}");
    } else if (location.isNotEmpty && music.isEmpty) {
      return Text("${widget.snap["location"]["fulladdress"]}");
    } else {
      return Text(" ${widget.snap["music"]}");
    }
  }
}

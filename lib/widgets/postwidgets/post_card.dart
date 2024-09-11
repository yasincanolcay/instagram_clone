// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/hashtagable.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/comment_screen.dart';
import 'package:instagram_clone/screens/push/searcher_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/postwidgets/post_more_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/save_post_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/tagged_users_sheet.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.snap,
    required this.playerMethods,
  });
  final snap;
  final AudioPlayersMethods playerMethods;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController;
  late AnimationController _controller;
  late Animation<double> _animation;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  String profilePhoto = "";
  bool verified = false;
  bool showMore = false;
  bool isSaved = false;
  double photoCurrentIndex = 0;
  List<String> likedList = [];
  int photoSelectedIndex = 0;

  void getUserData() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snap["author"])
        .get();
    username = userSnap.data()!["username"];
    profilePhoto = userSnap.data()!["profilePhoto"];
    verified = userSnap.data()!["verified"];
    if (mounted) {
      setState(() {});
    }
    getSavedPost(); //kaydedilenler alındı
    //username yazılacak
    //extra: yorum ve yanıt sil işlemi
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
    if (mounted) {
      setState(() {});
    }
    getUserData();
  }

  void getSavedPost() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("SavedPosts")
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["postId"] == widget.snap["postId"]) {
          isSaved = true;
          setState(() {});
        }
      }
    });
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
    if (widget.snap["type"] == "reels") {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.snap["contentUrl"]),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
              ))
            ..initialize().then((value) {
              setState(() {});
              _videoPlayerController!.setLooping(true);
            });
    }
    super.initState();
  }

  void savePost(String collectionName, bool isBack) async {
    bool response = await FirebaseMethods().savePost(
        widget.snap["postId"],
        collectionName,
        widget.snap["type"] == "photo"
            ? widget.snap['contentUrl'][photoSelectedIndex]
            : widget.snap["thumbnail"]);
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
            "Bir hata oluştu lütfen bağlantınızı kontrol edin!",
            context,
            redColor);
      }
    } else {
      setState(() {
        isSaved = true;
      });
      if (!isBack) {
        //bottom sheet göster
        if (mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  25,
                ),
              ),
            ),
            builder: (context) => SavePostSheet(
              savePost: savePost,
              thumbnail: widget.snap["type"] == "photo"
                  ? widget.snap['contentUrl'][photoSelectedIndex]
                  : widget.snap["thumbnail"],
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          Utils().showSnackBar("Gönderi $collectionName koleksiyonuna eklendi",
              context, Colors.white);
        }
      }
    }
  }

  void unSavePost() async {
    //gönderi type değişebilir, videolarda thumbnail alıcaz
    bool response = await FirebaseMethods().unSavePost(widget.snap["postId"]);
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
            "Post kaydedilenlerden kaldırılamadı!", context, redColor);
      }
    } else {
      setState(() {
        isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.playerMethods.stop();
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(widget),
      onVisibilityChanged: (i) async {
        String music = widget.snap["musicName"];
        String url = widget.snap["music"];
        var visiblePercentage = i.visibleFraction * 100;

        if (music.isNotEmpty) {
          print(visiblePercentage);
          if (visiblePercentage == 100.0) {
            if (widget.snap["type"] == "photo") {
              widget.playerMethods.player.setReleaseMode(ReleaseMode.loop);
              widget.playerMethods.playMusic(UrlSource(url));
            }
          } else if (visiblePercentage >= 60.0 && visiblePercentage <= 80.0) {
            if (widget.snap["type"] == "photo") {
              widget.playerMethods.player.stop();
            }
          }
          if (i.visibleFraction == 0 && mounted) {
            if (widget.snap["type"] == "photo") {
              widget.playerMethods.player.stop();
            }
          }
        } else if (widget.snap["type"] == "reels") {
          if (visiblePercentage > 70) {
            if (_videoPlayerController!.value.isInitialized) {
              _videoPlayerController!.play();
            }
          } else {
            if (_videoPlayerController!.value.isInitialized) {
              _videoPlayerController!.pause();
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.snap["type"] == "photo"
                ? ListTile(
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
                    isThreeLine: false,
                    subtitle: locationAndMusicChecker(),
                    trailing: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  25.0,
                                ),
                              ),
                            ),
                            builder: (context) {
                              return PostMoreSheet(snap: widget.snap, uid: uid);
                            });
                      },
                      icon: const Icon(
                        Icons.more_vert_rounded,
                      ),
                    ),
                  )
                : SizedBox(),
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
                  widget.snap["type"] == "photo"
                      ? ExpandablePageView(
                          onPageChanged: (value) {
                            setState(() {
                              photoCurrentIndex = value.toDouble();
                              photoSelectedIndex = value;
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
                        )
                      : SizedBox(
                          child: _videoPlayerController!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController!.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController!),
                                )
                              : SizedBox(),
                        ),
                  widget.snap["type"] == "reels"
                      ? Positioned(
                          top: 8.0,
                          left: 8.0,
                          right: 8.0,
                          child: ListTile(
                            dense: true,
                            leading: profilePhoto != ""
                                ? CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      profilePhoto,
                                      cacheManager:
                                          GlobalClass.customCacheManager,
                                    ),
                                  )
                                : const CircleAvatar(),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontFamily: "poppins1",
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
                            isThreeLine: false,
                            subtitle: locationAndMusicChecker(),
                            trailing: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          25.0,
                                        ),
                                      ),
                                    ),
                                    builder: (context) {
                                      return PostMoreSheet(
                                          snap: widget.snap, uid: uid);
                                    });
                              },
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: textColor,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
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
                  widget.snap["users"].isNotEmpty
                      ? Positioned(
                          bottom: 8.0,
                          left: 8.0,
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      25.0,
                                    ),
                                  ),
                                ),
                                builder: (context) => TaggedUsersSheet(
                                  snap: widget.snap,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.people_alt_rounded,
                              color: textColor,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  widget.snap["type"] == "reels"
                      ? Positioned(
                          right: 8.0,
                          bottom: 8.0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_videoPlayerController!.value.volume >
                                    0.0) {
                                  _videoPlayerController!.setVolume(0.0);
                                } else {
                                  _videoPlayerController!.setVolume(1.0);
                                }
                              });
                            },
                            icon: Icon(
                              _videoPlayerController!.value.volume > 0.0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: textColor,
                            ),
                          ),
                        )
                      : SizedBox(),
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
                  onPressed: () async {
                    await Share.share(
                      widget.snap["type"] == "photo"
                          ? widget.snap['contentUrl'][photoSelectedIndex]
                          : widget.snap['contentUrl'],
                      subject:
                          "İnstagram Klonu uygulamasını indir ve daha fazla keşfet!",
                    );
                  },
                  icon: Transform.rotate(
                    angle: -0.8,
                    child: const Icon(
                      Icons.send_rounded,
                    ),
                  ),
                ),
                const Spacer(),
                widget.snap["type"] == "photo"
                    ? SmoothIndicator(
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
                      )
                    : SizedBox(),
                const Spacer(
                  flex: 2,
                ),
                IconButton(
                  onPressed: () {
                    if (isSaved) {
                      unSavePost();
                    } else {
                      savePost("Kaydedilenler", false);
                    }
                  },
                  icon: Icon(
                    !isSaved
                        ? CupertinoIcons.bookmark
                        : CupertinoIcons.bookmark_fill,
                    color: !isSaved ? textColor : null,
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
                        TextSpan(
                          text: "$username ",
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        getHashTagTextSpan(
                          onTap: (hastag) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SearcherPage(
                                      hashtag: hastag,
                                      isPost: true,
                                    )));
                          },
                          source: widget.snap['description'],
                          decoratedStyle:
                              const TextStyle(fontSize: 14, color: Colors.blue),
                          basicStyle: const TextStyle(
                              fontSize: 14, color: Colors.black),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat.yMMMd().add_EEEE().add_Hm().format(
                      widget.snap['publishDate'].toDate(),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget locationAndMusicChecker() {
    Map location = Map.from(widget.snap["location"]);
    String music = widget.snap["musicName"];
    if (location.isEmpty && music.isEmpty) {
      return const SizedBox();
    } else if (location.isNotEmpty && music.isNotEmpty) {
      //animasyonlu yazı döndüreceğiz
      return AnimatedTextKit(
        isRepeatingAnimation: true,
        repeatForever: true,
        animatedTexts: [
          FlickerAnimatedText(
            location["address"].toString(),
            textStyle: const TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FlickerAnimatedText(music,
              textStyle: const TextStyle(
                overflow: TextOverflow.ellipsis,
              )),
        ],
        onTap: () {
          //eğer konumsa konuma gidecek
        },
      );
    } else if (location.isNotEmpty && music.isEmpty) {
      return Text(
        location["address"].toString(),
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(music);
    }
  }
}

import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/hashtagable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/comment_screen.dart';
import 'package:instagram_clone/screens/push/searcher_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/page_routes.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/post_share_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/post_more_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/save_post_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  double volume = 1.0;
  void setVolume(double value) {
    setState(() {
      volume = value;
    });
  }

  final ImagePicker _picker = ImagePicker();

  void _pickVideo(BuildContext context) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (context.mounted && file != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => VideoEditor(file: File(file.path)),
        ),
      );
    }
  }

  final future = FirebaseFirestore.instance
      .collection("Posts")
      .where("verified", isEqualTo: true)
      .where("type", isEqualTo: "reels")
      .get();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
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
                  return CarouselSlider.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index, realIndel) {
                      return ReelsVideoCard(
                        snap: snapshot.data!.docs[index].data(),
                        setVolume: setVolume,
                        volume: volume,
                      );
                    },
                    options: CarouselOptions(
                      aspectRatio: 9 / 16,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      height: double.infinity,
                      viewportFraction: 1.0,
                      scrollDirection: Axis.vertical,
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "REELS",
                    style: TextStyle(
                      color: textWhiteColor,
                      fontFamily: "poppins1",
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _pickVideo(context);
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: textWhiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReelsVideoCard extends StatefulWidget {
  const ReelsVideoCard({
    super.key,
    required this.snap,
    required this.volume,
    required this.setVolume,
  });
  final snap;
  final double volume;
  final Function(double value) setVolume;

  @override
  State<ReelsVideoCard> createState() => _ReelsVideoCardState();
}

class _ReelsVideoCardState extends State<ReelsVideoCard> {
  VideoPlayerController? _videoPlayerController;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> likedList = [];
  String username = "";
  String profilePhoto = "";
  bool verified = false;
  bool isSaved = false;
  bool isVideoPlayerMuteIcon = false;
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
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

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

  void savePost(String collectionName, bool isBack) async {
    bool response = await FirebaseMethods().savePost(
      widget.snap["postId"],
      collectionName,
      widget.snap["thumbnail"],
    );
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
              thumbnail: widget.snap["thumbnail"],
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
  void initState() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.snap["contentUrl"],
      ),
    )..initialize().then((value) {
        setState(() {
          _videoPlayerController!.setLooping(true);
          _videoPlayerController!.setVolume(widget.volume);
          _videoPlayerController!.play();
        });
      });
    getPostdata();
    super.initState();
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(this),
      onVisibilityChanged: (info) {
        var visiblePercentage = info.visibleFraction * 100;
        print("Görünürlük Yüzdesi: $visiblePercentage");
        if (visiblePercentage != 100) {
          _videoPlayerController!.pause();
        } else {
          if (!_videoPlayerController!.value.isPlaying) {
            _videoPlayerController!.play();
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (isVideoPlayerMuteIcon) {
                setState(() {
                  isVideoPlayerMuteIcon = false;
                });
              }
              if (widget.volume == 1.0) {
                widget.setVolume(0.0);
                _videoPlayerController!.setVolume(0.0);
              } else {
                widget.setVolume(1.0);
                _videoPlayerController!.setVolume(1.0);
              }
              setState(() {
                isVideoPlayerMuteIcon = true;
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    isVideoPlayerMuteIcon = false;
                  });
                });
              });
            },
            onLongPress: () {
              _videoPlayerController!.pause();
            },
            onLongPressUp: () {
              _videoPlayerController!.play();
            },
            child: Container(
              color: textColor,
              child: _videoPlayerController != null &&
                      _videoPlayerController!.value.isInitialized
                  ? VideoPlayer(_videoPlayerController!)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          isVideoPlayerMuteIcon
              ? Center(
                  child: _videoPlayerController!.value.volume == 1.0
                      ? const Icon(
                          Icons.volume_up_rounded,
                          color: textWhiteColor,
                        )
                      : const Icon(
                          Icons.volume_off_rounded,
                          color: textWhiteColor,
                        ),
                )
              : const SizedBox(),
          Positioned(
            bottom: 16.0,
            right: 8.0,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    likeOrUnLike(!likedList.contains(uid));
                  },
                  icon: Icon(
                    !likedList.contains(uid)
                        ? CupertinoIcons.heart
                        : CupertinoIcons.heart_fill,
                    color: !likedList.contains(uid) ? textWhiteColor : redColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${likedList.length} Begeni",
                    style: const TextStyle(
                      fontFamily: "Inter",
                      color: textWhiteColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.8,
                            child: CommentScreen(
                              snap: widget.snap,
                              isReelsPage: false,
                            ),
                          );
                        });
                  },
                  icon: const Icon(
                    CupertinoIcons.text_bubble,
                    color: textWhiteColor,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Share.share(
                      widget.snap['contentUrl'],
                      subject:
                          "İnstagram Klonu uygulamasını indir ve daha fazla keşfet!",
                    );
                  },
                  icon: Transform.rotate(
                    angle: -0.8,
                    child: const Icon(
                      Icons.send_rounded,
                      color: textWhiteColor,
                    ),
                  ),
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
                    color: !isSaved ? textWhiteColor : textColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _videoPlayerController!.pause();
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
                        }).then((value) {
                      _videoPlayerController!.play();
                    });
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: textWhiteColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8.0,
            bottom: 8.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      currentUser.uid = widget.snap["author"];
                      currentUser.page = 3;
                      Navigator.pushNamed(
                        context,
                        PageRouteNames.profile,
                      );
                    },
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
                            fontFamily: "poppins1",
                            color: textColor,
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
                    subtitle: locationAndMusicChecker(widget.snap, username),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      child: Wrap(
                        children: [
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            text: TextSpan(children: [
                              getHashTagTextSpan(
                                onTap: (hastag) {
                                  _videoPlayerController!.pause();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SearcherPage(
                                        hashtag: hastag,
                                        isPost: true,
                                      ),
                                    ),
                                  );
                                },
                                source: widget.snap['description'],
                                decoratedStyle: const TextStyle(
                                    fontSize: 14, color: Colors.blue),
                                basicStyle: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ]),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: textWhiteColor,
                                builder: (context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.8,
                                    child: ReelsPageDescription(
                                      snap: widget.snap,
                                    ),
                                  );
                                },
                              ).then((value) {
                                _videoPlayerController!.play();
                              });
                            },
                            child: const Text(" Daha Fazla"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ReelsPageDescription extends StatelessWidget {
  const ReelsPageDescription({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SheetTouchButton(),
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: Wrap(
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          getHashTagTextSpan(
                            onTap: (hastag) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SearcherPage(
                                    hashtag: hastag,
                                    isPost: true,
                                  ),
                                ),
                              );
                            },
                            source: snap['description'],
                            decoratedStyle: const TextStyle(
                                fontSize: 14, color: Colors.blue),
                            basicStyle: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CommentScreen(snap: snap, isReelsPage: true),
        ),
      ],
    );
  }
}

Widget locationAndMusicChecker(var snap, String username) {
  Map location = Map.from(snap["location"]);
  if (location.isEmpty) {
    return Text(
      "Orjinal Ses - $username",
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
        color: textColor,
      ),
    );
  } else if (location.isNotEmpty) {
    //animasyonlu yazı döndüreceğiz
    return AnimatedTextKit(
      isRepeatingAnimation: true,
      repeatForever: true,
      animatedTexts: [
        FlickerAnimatedText(
          location["address"].toString(),
          textStyle: const TextStyle(
            overflow: TextOverflow.ellipsis,
            color: textColor,
          ),
        ),
        FlickerAnimatedText(
          "Orjinal Ses - $username",
          textStyle: const TextStyle(
            overflow: TextOverflow.ellipsis,
            color: textColor,
          ),
        ),
      ],
      onTap: () {
        //eğer konumsa konuma gidecek
      },
    );
  } else {
    return const SizedBox();
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/posts/location_picker.dart';
import 'package:instagram_clone/screens/posts/users_picker.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:video_player/video_player.dart';

class ReelsDescriptionScreen extends StatefulWidget {
  final videoFile;
  final String thumbnail;
  final snap;
  final bool editMode;
  const ReelsDescriptionScreen({
    super.key,
    required this.videoFile,
    required this.snap,
    required this.editMode,
    required this.thumbnail,
  });

  @override
  State<ReelsDescriptionScreen> createState() => _ReelsDescriptionScreenState();
}

class _ReelsDescriptionScreenState extends State<ReelsDescriptionScreen> {
  late VideoPlayerController _videoPlayerController;
  final TextEditingController _controller = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isComment = false;
  bool isDownload = false;
  bool isUploading = false;
  String currentHastag = "";
  String music = "";
  String musicName = "";
  Map musicData = {};
  List<String> hastags = [];
  List<Map> users = [];
  Map locationMap = {};
  void uploadPost() async {
    setState(() {
      isUploading = true;
    });
    bool response = await FirebaseMethods().uploadReels(
      widget.videoFile.path,
      widget.thumbnail,
      _controller.text,
      uid,
      hastags,
      isComment,
      isDownload,
      music,
      DateTime.now(),
      "reels",
      locationMap,
      users,
    );
    if (response) {
      if (mounted) {
        Utils()
            .showSnackBar("Reels videon yüklendi!", context, backgroundColor);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        Utils().showSnackBar(
            "Reels videon yüklenemedi tekrar dene!", context, redColor);
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void editPost() async {
    setState(() {
      isUploading = true;
    });
    bool response = await FirebaseMethods().editPost(
      {
        "description": _controller.text,
        "hastags": hastags,
        "users": users,
        "location": locationMap,
      },
      widget.snap["postId"],
    );
    if (response) {
      if (mounted) {
        Utils().showSnackBar("Gönderi düzenlendi", context, backgroundColor);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        Utils().showSnackBar("Gönderi düzenlenlenemedi!", context, redColor);
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void addUsers(List<Map> usersList) {
    setState(() {
      users = usersList;
    });
  }

  void setLocation(Map data) {
    setState(() {
      locationMap = data;
    });
  }

  String checkUser() {
    switch (users.length) {
      case == 2:
        return "${users[0]["username"]},${users[1]["username"]}";
      case > 2:
        return "${users[0]["username"]}, ${users[1]["username"]} ve +${users.length - 2}";
      default:
        return "${users[0]["username"]}";
    }
  }

  @override
  void initState() {
    if (widget.editMode) {
      _controller.text = widget.snap["description"];
      hastags = List.from(widget.snap["hastags"]);
      users = List.from(widget.snap["users"]);
      locationMap = Map.from(widget.snap["location"]);
      isDownload = widget.snap["isDownload"];
      isComment = widget.snap["isComment"];
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.snap["contentUrl"]))
            ..initialize().then((value) {
              setState(() {});
            });
    } else {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile)
        ..initialize().then((value) {
          setState(() {});
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text("Yeni Gönderi"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: _videoPlayerController.value.isInitialized
                    ? GestureDetector(
                        onTap: () {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                          } else {
                            _videoPlayerController.play();
                          }
                        },
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      )
                    : const SizedBox(),
              ), //video oynatıcı gelecek
            ),
            const Divider(
              indent: 0.0,
              thickness: 0.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HashTagTextField(
                onDetectionTyped: (value) {
                  currentHastag = value;
                  hastags.removeWhere((element) => element == currentHastag);
                },
                onDetectionFinished: () {
                  hastags.add(currentHastag);
                },
                controller: _controller,
                decoratedStyle:
                    const TextStyle(fontSize: 14, color: Colors.blue),
                basicStyle: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Açıklama Yazın...",
                ),
              ),
            ),
            const Divider(
              thickness: 0.0,
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LocationPicker(
                      locationData: setLocation,
                      data: locationMap,
                    ),
                  ),
                );
              },
              leading: const Icon(
                Icons.location_on,
              ),
              title: Text(
                locationMap.isEmpty
                    ? "Konum Ekle"
                    : "${locationMap["address"]}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              trailing: IconButton(
                onPressed: () {
                  if (locationMap.isNotEmpty) {
                    setState(() {
                      locationMap.clear();
                    });
                  }
                },
                icon: Icon(
                  locationMap.isEmpty
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.cancel_rounded,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UsersPicker(
                      addUsers: addUsers,
                      users: users,
                    ),
                  ),
                );
              },
              leading: const Icon(
                Icons.people_alt_rounded,
              ),
              title: Text(users.isEmpty ? "Kişileri Etiketle" : checkUser()),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ),
            const Divider(),
            SwitchListTile(
              value: isComment,
              onChanged: (value) {
                setState(() {
                  isComment = value;
                });
              },
              title: const Text("Gönderi Yorumları"),
            ),
            SwitchListTile(
              value: isDownload,
              onChanged: (value) {
                setState(() {
                  isDownload = value;
                });
              },
              title: const Text("İndirmeler"),
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () {
            if (widget.editMode) {
              editPost();
            } else {
              uploadPost();
            }
          },
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.blue),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: !isUploading
              ? Text(
                  widget.editMode ? "Gönderiyi Kaydet" : "Reels Paylaş",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )
              : const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ),
      ),
    );
  }
}

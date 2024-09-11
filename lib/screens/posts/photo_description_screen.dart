import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/posts/location_picker.dart';
import 'package:instagram_clone/screens/posts/music_picker.dart';
import 'package:instagram_clone/screens/posts/sub_photo_screen.dart';
import 'package:instagram_clone/screens/posts/users_picker.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class PhotoDescriptionScreen extends StatefulWidget {
  final Stream<InstaAssetsExportDetails>? photoStream;
  final snap;
  final bool editMode;
  const PhotoDescriptionScreen({
    super.key,
    required this.photoStream,
    required this.snap,
    required this.editMode,
  });

  @override
  State<PhotoDescriptionScreen> createState() => _PhotoDescriptionScreenState();
}

class _PhotoDescriptionScreenState extends State<PhotoDescriptionScreen> {
  final AudioPlayersMethods playersMethods = AudioPlayersMethods();
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
  void uploadPost(List<File> croppedFiles) async {
    setState(() {
      isUploading = true;
    });
    List<Uint8List> bytes = [];
    for (var element in croppedFiles) {
      var img = element.readAsBytesSync();
      bytes.add(img);
    }

    bool response = await FirebaseMethods().uploadPost(
      _controller.text,
      uid,
      hastags,
      isComment,
      isDownload,
      music,
      "photo",
      locationMap,
      users,
      bytes,
      musicName,
      musicData,
    );
    if (response) {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      setState(() {
        isUploading = false;
      });
      if (mounted) {
        Utils().showSnackBar(
            "Gönderi paylaşılamadı, daha sonra deneyin!", context, Colors.red);
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
        "music": music,
        "musicName": musicName,
        "musicData": musicData,
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

  void setMusic(String musicId, Map data) {
    setState(() {
      music = musicId;
      musicData = data;
      musicName = "${data["author"]} - ${data["name"]}";
    });
    Navigator.pop(context);
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
      music = widget.snap["music"];
      musicName = widget.snap["musicName"];
      musicData = Map.from(widget.snap["musicData"]);
      isDownload = widget.snap["isDownload"];
      isComment = widget.snap["isComment"];
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    playersMethods.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.editMode
        ? StreamBuilder(
            stream: widget.photoStream,
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
                  child: Icon(Icons.error),
                );
              }
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
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.croppedFiles.length,
                          itemBuilder: (context, index) {
                            var img = snapshot.data!.croppedFiles[index]
                                .readAsBytesSync();
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                height: 300,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SubPhotoScreen(
                                            bytes: img,
                                            editMode: widget.editMode,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.memory(
                                      img,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
                            hastags.removeWhere(
                                (element) => element == currentHastag);
                          },
                          onDetectionFinished: () {
                            hastags.add(currentHastag);
                          },
                          controller: _controller,
                          decoratedStyle:
                              const TextStyle(fontSize: 14, color: Colors.blue),
                          basicStyle: const TextStyle(
                              fontSize: 14, color: Colors.black),
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
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                    25,
                                  ),
                                ),
                              ),
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.9,
                                  child: MusicPicker(
                                    playerMethods: playersMethods,
                                    setMusic: setMusic,
                                  ),
                                );
                              }).then((value) {
                            Future.delayed(const Duration(seconds: 1), () {
                              playersMethods
                                  .playMusic(UrlSource(musicData["url"]));
                            });
                          });
                        },
                        leading: const Icon(
                          Icons.music_note_rounded,
                        ),
                        title: Text(
                          musicData.isEmpty
                              ? "Müzik Ekle"
                              : "${musicData["name"]} - ${musicData["author"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: musicData.isEmpty
                            ? const Icon(
                                Icons.arrow_forward_ios_rounded,
                              )
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    playersMethods.stop();
                                    musicData.clear();
                                    music = "";
                                  });
                                },
                                icon: const Icon(Icons.cancel_rounded),
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
                        title: Text(
                            users.isEmpty ? "Kişileri Etiketle" : checkUser()),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                      Divider(),
                      SwitchListTile(
                        value: isComment,
                        onChanged: (value) {
                          setState(() {
                            isComment = value;
                          });
                        },
                        title: Text("Gönderi Yorumları"),
                      ),
                      SwitchListTile(
                        value: isDownload,
                        onChanged: (value) {
                          setState(() {
                            isDownload = value;
                          });
                        },
                        title: Text("İndirmeler"),
                      ),
                      SizedBox(
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
                      uploadPost(snapshot.data!.croppedFiles);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.blue),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: !isUploading
                        ? const Text(
                            "Gönderiyi Paylaş",
                            style: TextStyle(
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
            })
        : Scaffold(
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.snap["contentUrl"].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: 300,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SubPhotoScreen(
                                        bytes: widget.snap["contentUrl"][index],
                                        editMode: widget.editMode,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  widget.snap["contentUrl"][index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                        hastags
                            .removeWhere((element) => element == currentHastag);
                      },
                      onDetectionFinished: () {
                        hastags.add(currentHastag);
                      },
                      controller: _controller,
                      decoratedStyle:
                          const TextStyle(fontSize: 14, color: Colors.blue),
                      basicStyle:
                          const TextStyle(fontSize: 14, color: Colors.black),
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
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                25,
                              ),
                            ),
                          ),
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: MusicPicker(
                                playerMethods: playersMethods,
                                setMusic: setMusic,
                              ),
                            );
                          }).then((value) {
                        Future.delayed(const Duration(seconds: 1), () {
                          playersMethods.playMusic(UrlSource(musicData["url"]));
                        });
                      });
                    },
                    leading: const Icon(
                      Icons.music_note_rounded,
                    ),
                    title: Text(
                      musicData.isEmpty
                          ? "Müzik Ekle"
                          : "${musicData["name"]} - ${musicData["author"]}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: musicData.isEmpty
                        ? const Icon(
                            Icons.arrow_forward_ios_rounded,
                          )
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                playersMethods.stop();
                                musicData.clear();
                                music = "";
                              });
                            },
                            icon: const Icon(Icons.cancel_rounded),
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
                    title:
                        Text(users.isEmpty ? "Kişileri Etiketle" : checkUser()),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  Divider(),
                  SwitchListTile(
                    value: isComment,
                    onChanged: (value) {
                      setState(() {
                        isComment = value;
                      });
                    },
                    title: Text("Gönderi Yorumları"),
                  ),
                  SwitchListTile(
                    value: isDownload,
                    onChanged: (value) {
                      setState(() {
                        isDownload = value;
                      });
                    },
                    title: Text("İndirmeler"),
                  ),
                  SizedBox(
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
                  editPost();
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
                    ? const Text(
                        "Gönderiyi Kaydet",
                        style: TextStyle(
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

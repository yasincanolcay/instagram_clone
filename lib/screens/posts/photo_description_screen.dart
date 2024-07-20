import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/posts/sub_photo_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class PhotoDescriptionScreen extends StatefulWidget {
  final Stream<InstaAssetsExportDetails> photoStream;
  const PhotoDescriptionScreen({
    super.key,
    required this.photoStream,
  });

  @override
  State<PhotoDescriptionScreen> createState() => _PhotoDescriptionScreenState();
}

class _PhotoDescriptionScreenState extends State<PhotoDescriptionScreen> {
  final TextEditingController _controller = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isComment = false;
  bool isDownload = false;
  bool isUploading = false;
  String currentHastag = "";
  List<String> hastags = [];
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
      "",
      "photo",
      {},
      [],
      bytes,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: 300,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SubPhotoScreen(
                                        bytes: img,
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
                  const ListTile(
                    leading: Icon(
                      Icons.location_on,
                    ),
                    title: Text("Konum Ekle"),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.music_note_rounded,
                    ),
                    title: Text("Müzik Ekle"),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.people_alt_rounded,
                    ),
                    title: Text("Kişileri Etiketle"),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
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
                  backgroundColor: const MaterialStatePropertyAll(Colors.blue),
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
        });
  }
}

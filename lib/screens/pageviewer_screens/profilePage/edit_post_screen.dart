// ignore_for_file: non_constant_identifier_names, body_might_complete_normally_nullable

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/auth/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/utils/utils.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  Uint8List? image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool isLoading = false;

  void selectProfilePhoto(ImageSource source) async {
    String selectedImg = await Utils().pickImage(source);
    if (selectedImg.isNotEmpty) {
      CropImage(selectedImg);
    }
  }

  Future<CroppedFile?> CropImage(String path) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Kırp',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Kırp',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      image = await croppedFile.readAsBytes();
      setState(() {});
    }
  }

  void editProfile() async {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await FirebaseMethods().editProfile(
          myUid,
          _nameController.text,
          _bioController.text,
          image,
          widget.snap["profilePhoto"]);
      if (mounted) {
        if (response) {
          Utils().showSnackBar(
            "Profil Düzenlendi!",
            context,
            backgroundColor,
          );
        } else {
          Utils().showSnackBar(
            "Bir Sorun Oluştur!",
            context,
            redColor,
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      Utils().showSnackBar(
        "Lütfen gerekli alanları doldurunuz, boş alanlar var!",
        context,
        backgroundColor,
      );
    }
  }

  @override
  void initState() {
    _nameController.text = widget.snap["username"];
    _bioController.text = widget.snap["bio"];
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Düzenle"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                const Text(
                  "Profili Düzenle",
                  style: generalStyle,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Stack(
                  children: [
                    image == null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: CachedNetworkImageProvider(
                              widget.snap["profilePhoto"],
                              cacheManager: GlobalClass.customCacheManager,
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(image!),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        selectProfilePhoto(ImageSource.camera);
                                      },
                                      leading: const Icon(Icons.camera),
                                      title: const Text("Fotoğraf Çek"),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        selectProfilePhoto(ImageSource.gallery);
                                      },
                                      leading: const Icon(Icons.photo),
                                      title: const Text("Galeriden Seç"),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Kullanıcı Adı",
                      prefixIcon: Icon(
                        Icons.people_rounded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _bioController,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 150,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Bio",
                      prefixIcon: Icon(
                        Icons.edit,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: editProfile,
                      style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.blue),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: !isLoading
                          ? const Text(
                              "Kaydet",
                              style: style,
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

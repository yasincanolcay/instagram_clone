// ignore_for_file: non_constant_identifier_names, body_might_complete_normally_nullable

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/auth/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Uint8List? image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  void createAndSignIn() async {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await AuthMethods().signInUser(
        context,
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _bioController.text,
        image,
      );
      if (mounted) {
        if (response) {
          Utils().showSnackBar(
            "Hesap oluşturuldu, giriş yapabilirsiniz",
            context,
            backgroundColor,
          );
        } else {
          Utils().showSnackBar(
            "Hesap oluşturulamadı lütfen tekrar deneyin",
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
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
        return await Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16.0,
                  ),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 50,
                    height: 50,
                  ),
                  const Text(
                    "Hesap Oluştur",
                    style: generalStyle,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Stack(
                    children: [
                      image == null
                          ? const CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person),
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
                                          selectProfilePhoto(
                                              ImageSource.camera);
                                        },
                                        leading: const Icon(Icons.camera),
                                        title: const Text("Fotoğraf Çek"),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          selectProfilePhoto(
                                              ImageSource.gallery);
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email Adresi",
                        prefixIcon: Icon(
                          Icons.mail,
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
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Şifreniz",
                        prefixIcon: Icon(
                          Icons.lock,
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
                        onPressed: createAndSignIn,
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
                                "Kayıt Ol",
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
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Zaten Hesabın Var mı? "),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false);
                        },
                        child: const Text("Giriş Yap"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

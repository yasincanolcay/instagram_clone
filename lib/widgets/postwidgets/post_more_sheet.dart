// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/posts/photo_description_screen.dart';
import 'package:instagram_clone/screens/posts/reels_description_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/postwidgets/delete_warning.dart';
import 'package:instagram_clone/widgets/postwidgets/post_complaint_sheet.dart';
import 'package:instagram_clone/widgets/postwidgets/set_access_popup.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';
import 'package:instagram_clone/widgets/postwidgets/user_about_popup.dart';

class PostMoreSheet extends StatefulWidget {
  const PostMoreSheet({
    super.key,
    required this.snap,
    required this.uid,
  });
  final snap;
  final String uid;

  @override
  State<PostMoreSheet> createState() => _PostMoreSheetState();
}

class _PostMoreSheetState extends State<PostMoreSheet> {
  List<String> followings = [];
  Map userSnap = {};
  void deletePost() async {
    bool response = await FirebaseMethods().deletePost(widget.snap, context);
    if (response) {
      if (mounted) {
        Utils().showSnackBar("Bu gönderi silindi!", context, backgroundColor);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

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
    getUserData();
  }

  void followOrUnFollow() async {
    bool response = await FirebaseMethods().followOrUnFollow(widget.uid,
        widget.snap["author"], !followings.contains(widget.snap["author"]));
    if (response) {
      if (!followings.contains(widget.snap["author"])) {
        followings.add(widget.snap["author"]);
      } else {
        followings.removeWhere((element) => element == widget.snap["author"]);
      }
      setState(() {});
    }
  }

  void getUserData() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snap["author"])
        .get();
    userSnap = Map.from(snap.data()!);
    setState(() {});
  }

  @override
  void initState() {
    getFollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.uid == widget.snap["author"]
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetTouchButton(),
              ListTile(
                onTap: () {
                  if (widget.snap["type"] == "photo") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoDescriptionScreen(
                          photoStream: null,
                          snap: widget.snap,
                          editMode: true,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReelsDescriptionScreen(
                          snap: widget.snap,
                          editMode: true,
                          thumbnail: "",
                          videoFile: null,
                        ),
                      ),
                    );
                  }
                },
                leading: const Icon(
                  Icons.edit,
                  color: textColor,
                ),
                title: const Text("Gönderiyi Düzenle"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteWarning(
                      title: "Bu Gönderi Silinsin Mi?",
                      description: "Gönderi kalıcı olarak silinir!",
                      okPress: deletePost,
                      okButtonTitle: "Sil",
                    ),
                  );
                },
                leading: const Icon(
                  Icons.delete,
                  color: textColor,
                ),
                title: const Text("Gönderiyi Sil"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => SetAccessPopup(
                      snap: widget.snap,
                    ),
                  );
                },
                leading: const Icon(
                  Icons.settings_accessibility_rounded,
                  color: textColor,
                ),
                title: const Text("Erişimleri Ayarla"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () => Navigator.pop(context),
                leading: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                ),
                title: const Text("Geri"),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetTouchButton(),
              ListTile(
                onTap: followOrUnFollow,
                leading: const Icon(
                  Icons.add,
                  color: textColor,
                ),
                title: Text(!followings.contains(widget.snap["author"])
                    ? "Takip Et"
                    : "Takibi Bırak"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          25.0,
                        ),
                      ),
                    ),
                    builder: (context) => PostComplaintSheet(
                      snap: widget.snap,
                      uid: widget.uid,
                    ),
                  );
                },
                leading: const Icon(
                  Icons.info_outline_rounded,
                  color: textColor,
                ),
                title: const Text("Gönderiyi Bildir"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () {
                  if (userSnap.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => Material(
                        type: MaterialType.transparency,
                        child: UserAboutPopup(userSnap: userSnap),
                      ),
                    );
                  }
                },
                leading: const Icon(
                  Icons.person,
                  color: textColor,
                ),
                title: const Text("Kullanıcı Hakkında"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () => Navigator.pop(context),
                leading: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                ),
                title: const Text("Geri"),
              ),
            ],
          );
  }
}

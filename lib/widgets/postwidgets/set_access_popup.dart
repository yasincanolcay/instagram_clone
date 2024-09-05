import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class SetAccessPopup extends StatefulWidget {
  const SetAccessPopup({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<SetAccessPopup> createState() => _SetAccessPopupState();
}

class _SetAccessPopupState extends State<SetAccessPopup> {
  bool isComment = false;
  bool isDownload = false;

  void editPost() async {
    bool response = await FirebaseMethods().editPost({
      "isComment": isComment,
      "isDownload": isDownload,
    }, widget.snap["postId"]);
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
            "Erişimler ayarlanamadı, sonra tekrar deneyin!", context, redColor);
      }
    }else{
      widget.snap["isComment"] = isComment;
      widget.snap["isDownload"] = isDownload;
    }
  }

  @override
  void initState() {
    isComment = widget.snap["isComment"];
    isDownload = widget.snap["isDownload"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Gönderi Erişimleri"),
      actions: [
        SwitchListTile(
          value: isComment,
          onChanged: (value) {
            setState(() {
              isComment = value;
            });
            editPost();
          },
          title: Text("Gönderi Yorumları"),
        ),
        SwitchListTile(
          value: isDownload,
          onChanged: (value) {
            setState(() {
              isDownload = value;
            });
            editPost();
          },
          title: Text("İndirmeler"),
        ),
      ],
    );
  }
}

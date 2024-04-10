import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/utils/colors.dart';

class Utils {
  Future<String> pickImage(ImageSource source) async {
    XFile? pick = await ImagePicker().pickImage(source: source);
    if (pick != null) {
      return pick.path;
    } else {
      return "";
    }
  }

  showSnackBar(String content, BuildContext context, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        closeIconColor: textColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 70, left: 4.0, right: 4.0),
        dismissDirection: DismissDirection.vertical,
        content: ListTile(
          dense: false,
          title: Text(
            content,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
                fontFamily: 'Poppins'),
          ),
          leading: const Icon(
            CupertinoIcons.check_mark_circled,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

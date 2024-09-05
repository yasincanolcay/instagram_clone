import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';

class PostComplaintSheet extends StatefulWidget {
  const PostComplaintSheet({
    super.key,
    required this.snap,
    required this.uid,
  });
  final snap;
  final String uid;

  @override
  State<PostComplaintSheet> createState() => _PostComplaintSheetState();
}

class _PostComplaintSheetState extends State<PostComplaintSheet> {
  List<String> types = [
    "Zorbalık Ve Nefret Söylemi",
    "Pornogafi İçeren Gönderiler",
    "Şiddet Ve Korku",
    "Terörü Destekleyici Paylaşımlar",
    "Dolandırıcılık Ve Spam",
    "Diğer Suçlar",
  ];

  void sendCommentComplaints(String complain) async {
    bool response = await FirebaseMethods().sendPostComplain(
        widget.snap["postId"], complain, widget.snap["author"], widget.uid);
    if (response) {
      if (mounted) {
        Utils().showSnackBar(
          "Şikayetinizi aldık, en kısa sürede inceleyeceğiz!",
          context,
          backgroundColor,
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        Utils().showSnackBar(
          "Şikayetinizi şuan alamıyoruz, sonra tekrar deneyin!",
          context,
          redColor,
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetTouchButton(),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Şikayet Nedeni Nedir?"),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: types.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                sendCommentComplaints(types[index]);
              },
              leading: const Icon(Icons.circle),
              title: Text(types[index]),
            );
          },
        )
      ],
    );
  }
}

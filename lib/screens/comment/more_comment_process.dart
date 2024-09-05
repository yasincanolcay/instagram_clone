// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/delete_dialog.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class MoreCommentProcess extends StatelessWidget {
  const MoreCommentProcess({
    super.key,
    required this.uid,
    required this.postId,
    required this.commentId,
    required this.isItMineOfUid,
    required this.commentAuthor,
  });
  final bool isItMineOfUid;
  final String postId;
  final String commentId;
  final String commentAuthor;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 50,
            height: 10,
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        isItMineOfUid
            ? ListTile(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteDialog(
                      title: "Yorum Silinsin Mi?",
                      content: "Yorum kalıcı olarak silinecek",
                      okPress: () async {
                        bool response = await FirebaseMethods()
                            .deleteComment(postId, commentId);
                        if (context.mounted) {
                          if (response) {
                            Utils().showSnackBar(
                                "Yorumunuz silindi!", context, backgroundColor);
                          } else {
                            Utils().showSnackBar(
                                "Yorum silinirken bir sorun oluştu!",
                                context,
                                redColor);
                          }
                        }
                        Navigator.pop(context);
                      },
                      okButtonName: "Sil",
                    ),
                  );
                },
                leading: const Icon(Icons.delete),
                title: const Text("Yorumu Sil"),
                subtitle: const Text("Yorumu kalıcı olarak siler"),
              )
            : ListTile(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteDialog(
                      title: "Yorum Şikayet Edilsin Mi?",
                      content: "Yorum şikayet edilecek",
                      okPress: () async {
                        bool response =
                            await FirebaseMethods().sendCommentComplaints(
                          uid,
                          commentAuthor,
                          "comment",
                          commentId,
                          postId,
                        );
                        if (context.mounted) {
                          if (response) {
                            Utils().showSnackBar(
                                "Yorum instagram ekibine bildirildi, en kısa sürede inceleyeceğiz!",
                                context,
                                backgroundColor);
                          } else {
                            Utils().showSnackBar(
                                "Yorum şikayetinizi alamadık, sonra tekrar deneyin!",
                                context,
                                redColor);
                          }
                        }
                        Navigator.pop(context);
                      },
                      okButtonName: "Bildir",
                    ),
                  );
                },
                leading: const Icon(Icons.delete),
                title: const Text("Yorumu Bildir"),
                subtitle: const Text("Bu yorumu şikayet edin"),
              ),
      ],
    );
  }
}

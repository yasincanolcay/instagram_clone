// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firebase_methods.dart';
import 'package:instagram_clone/screens/comment/delete_dialog.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class MoreAnswerProcess extends StatelessWidget {
  const MoreAnswerProcess({
    super.key,
    required this.uid,
    required this.postId,
    required this.answerId,
    required this.commentId,
    required this.isItMineOfUid,
    required this.answerAuthor,
  });
  final bool isItMineOfUid;
  final String postId;
  final String answerId;
  final String commentId;
  final String answerAuthor;
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
                      title: "Bu Yanıt Silinsin Mi?",
                      content: "Yanıt kalıcı olarak silinecek!",
                      okPress: () async {
                        bool response = await FirebaseMethods()
                            .deleteAnswer(postId, commentId, answerId);
                        if (context.mounted) {
                          if (response) {
                            Utils().showSnackBar(
                                "Yanıtınız silindi!", context, backgroundColor);
                          } else {
                            Utils().showSnackBar(
                                "Yanıt silinirken bir sorun oluştu!",
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
                title: const Text("Yanıtı Sil"),
                subtitle: const Text("Yanıtı kalıcı olarak siler"),
              )
            : ListTile(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteDialog(
                      title: "Bu Yanıt Şikayet Edilsin Mi?",
                      content: "Yanıt şikayet edilecek!",
                      okPress: () async {
                        bool response = await FirebaseMethods()
                            .sendAnswerComplaints(uid, answerAuthor, "answer",
                                answerId, postId, commentId);
                        if (context.mounted) {
                          if (response) {
                            Utils().showSnackBar(
                                "Yanıt instagram ekibine bildirildi, en kısa sürede inceleyeceğiz!",
                                context,
                                backgroundColor);
                          } else {
                            Utils().showSnackBar(
                                "Yanıt şikayetinizi alamadık, sonra tekrar deneyin!",
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
                title: const Text("Yanıtı Bildir"),
                subtitle: const Text("Bu yanıtı şikayet edin"),
              ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:intl/intl.dart';

class UserAboutPopup extends StatefulWidget {
  const UserAboutPopup({
    super.key,
    required this.userSnap,
  });
  final userSnap;

  @override
  State<UserAboutPopup> createState() => _UserAboutPopupState();
}

class _UserAboutPopupState extends State<UserAboutPopup> {
  String formattedDate = "";
  @override
  void initState() {
    Timestamp firebaseTimestamp = widget.userSnap["createDate"];
    DateTime dateTime = firebaseTimestamp.toDate();
    formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 350),
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userSnap["profilePhoto"]),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(widget.userSnap["username"]),
            const Divider(),
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: textFieldColor.withOpacity(0.2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_rounded,
                      ),
                      const Text(
                        "Biyografi",
                        style: TextStyle(fontFamily: "poppins1"),
                      ),
                    ],
                  ),
                  Text(
                    widget.userSnap["bio"],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text(
                "Katılım Tarihi",
                style: TextStyle(fontFamily: "poppins1"),
              ),
              trailing: Text(formattedDate),
            ),
            OutlinedButton(onPressed: ()=>Navigator.pop(context), child: Text("Kapat",),),
          ],
        ),
      ),
    );
  }
}

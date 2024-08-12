import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  final String text;
  final String uid;
  final String answerId;
  final String type;
  final String username;
  final String answerUid;
  final DateTime date;

  Answer({
    required this.text,
    required this.uid,
    required this.answerId,
    required this.date,
    required this.type,
    required this.answerUid,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "uid": uid,
        "answerId": answerId,
        "date": date,
        "type": type,
        "username": username,
        "answerUid": answerUid,
      };

  static Answer fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return Answer(
      text: snapshot["text"],
      uid: snapshot["uid"],
      answerId: snapshot["answerId"].toString(),
      date: snapshot["date"].toDate(),
      type: snapshot["type"],
      answerUid: snapshot["answerUid"],
      username: snapshot["username"],
    );
  }
}

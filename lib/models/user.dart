import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String bio;
  final String email;
  final String profilePhoto;
  final String uid;
  final DateTime createDate;
  final bool verified;

  User({
    required this.username,
    required this.bio,
    required this.email,
    required this.profilePhoto,
    required this.createDate,
    required this.verified,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "bio": bio,
        "email": email,
        "profilePhoto": profilePhoto,
        "createDate": createDate,
        "verified": verified,
        "uid":uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return User(
      username: snapshot["username"],
      bio: snapshot["bio"],
      email: snapshot["email"],
      profilePhoto: snapshot["profilePhoto"],
      createDate: snapshot["createDate"].toDate(),
      verified: snapshot["verified"],
      uid: snapshot["uid"],
    );
  }
}

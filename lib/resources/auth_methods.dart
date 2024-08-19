// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  Future<bool> signInUser(
    BuildContext context,
    String email,
    String password,
    String username,
    String bio,
    Uint8List? profilePhoto,
  ) async {
    try {
      UserCredential _cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String photoUrl = "https://cdn-icons-png.flaticon.com/128/847/847969.png";
      if (profilePhoto != null) {
        photoUrl = await StorageMethods()
            .uploadImageToStorage("ProfilePhotos", profilePhoto, false);
      }

      model.User user = model.User(
        username: username,
        bio: bio,
        email: email,
        profilePhoto: photoUrl,
        createDate: DateTime.now(),
        verified: false,
        uid: _cred.user!.uid,
      );
      await _fire.collection("users").doc(_cred.user!.uid).set(user.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> signOutUser() async {
    try {
      await _auth.signOut();
      return true;
    } catch (err) {
      return false;
    }
  }
}

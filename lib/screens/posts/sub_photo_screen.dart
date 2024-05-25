import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class SubPhotoScreen extends StatelessWidget {
  const SubPhotoScreen({
    super.key,
    required this.bytes,
  });
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Center(
        child: Image.memory(bytes),
      ),
    );
  }
}

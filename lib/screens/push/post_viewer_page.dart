// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/postwidgets/post_card.dart';

class PostViewerPage extends StatefulWidget {
   const PostViewerPage({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<PostViewerPage> createState() => _PostViewerPageState();
}

class _PostViewerPageState extends State<PostViewerPage> {
  final AudioPlayersMethods playerMethods = AudioPlayersMethods();
  @override
  void dispose() {
    playerMethods.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gönderi",
          style: TextStyle(
            color: textColor,
            fontFamily: "poppins1",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(snap: widget.snap,playerMethods: playerMethods),
          ],
        ),
      ),
    );
  }
}

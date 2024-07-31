import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/postwidgets/post_card.dart';

class PostViewerPage extends StatelessWidget {
  const PostViewerPage({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
            PostCard(snap: snap),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/push/post_viewer_page.dart';

class PostGridCard extends StatelessWidget {
  const PostGridCard({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostViewerPage(
              snap: data,
            ),
          ),
        );
      },
      child: data["type"] == "photo"
          ? Image.network(
              data["contentUrl"][0],
              fit: BoxFit.cover,
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  data["thumbnail"],
                  fit: BoxFit.cover,
                ),
                const Positioned(
                  bottom: 8.0,
                  left: 8.0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      Text(
                        "Reel",
                        style: TextStyle(
                          fontFamily: "poppins1",
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/screens/posts/music_tile_builder.dart';
import 'package:instagram_clone/utils/colors.dart';

class MusicBuilder extends StatefulWidget {
  const MusicBuilder({
    super.key,
    required this.playerMethods,
    required this.setMusic,
  });
  final AudioPlayersMethods playerMethods;
  final Function(String id, Map data) setMusic;

  @override
  State<MusicBuilder> createState() => _MusicBuilderState();
}

class _MusicBuilderState extends State<MusicBuilder> {
  bool isSearching = false;
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                onChanged: (s) {
                  if (_controller.text.isNotEmpty) {
                    setState(() {
                      isSearching = true;
                    });
                  } else {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
                controller: _controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Müzik Arayın...",
                  prefixIcon: Icon(
                    Icons.search_rounded,
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: !isSearching
                  ? FirebaseFirestore.instance.collection("PostMusics").get()
                  : FirebaseFirestore.instance
                      .collection("PostMusics")
                      .orderBy("name")
                      .startAt([_controller.text]).endAt(
                          ['${_controller.text}\uf8ff']).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return MusicTileBuilder(
                  playerMethods: widget.playerMethods,
                  snapshot: snapshot,
                  setMusic: widget.setMusic,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/screens/posts/category_builder.dart';
import 'package:instagram_clone/screens/posts/music_builder.dart';

class MusicPicker extends StatefulWidget {
  const MusicPicker(
      {super.key, required this.playerMethods, required this.setMusic});
  final AudioPlayersMethods playerMethods;
  final Function(String id, Map data) setMusic;

  @override
  State<MusicPicker> createState() => _MusicPickerState();
}

class _MusicPickerState extends State<MusicPicker> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.music_note_rounded),
          title: const Text("Müzik Seçimi"),
          bottom: const TabBar(tabs: [
            Tab(
                icon: Icon(
                  Icons.music_note_rounded,
                ),
                text: "Müzik"),
            Tab(
                icon: Icon(
                  Icons.category_rounded,
                ),
                text: "Kategoriler"),
          ]),
        ),
        body: TabBarView(
          children: [
            MusicBuilder(
              playerMethods: widget.playerMethods,
              setMusic: widget.setMusic,
            ),
            CategoryBuilder(
              playerMethods: widget.playerMethods,
              setMusic: widget.setMusic,
            ),
          ],
        ),
      ),
    );
  }
}

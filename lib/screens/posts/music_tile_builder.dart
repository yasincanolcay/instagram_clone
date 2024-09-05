// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/screens/posts/music_tile_card.dart';


class MusicTileBuilder extends StatefulWidget {
  const MusicTileBuilder({
    super.key,
    required this.snapshot,
    required this.playerMethods,
    required this.setMusic,
  });

  final snapshot;
  final AudioPlayersMethods playerMethods;
  final Function(String id, Map data) setMusic;

  @override
  State<MusicTileBuilder> createState() => _MusicTileBuilderState();
}

class _MusicTileBuilderState extends State<MusicTileBuilder> {
  int selectedIndex = 0;
  void setSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MusicTileCard(
          snapshot: widget.snapshot.data!.docs[index].data(),
          index: index,
          playerMethods: widget.playerMethods,
          selectedIndex: selectedIndex,
          setSelectedIndex: setSelected,
          setMusic: widget.setMusic,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: widget.snapshot.data!.docs.length,
    );
  }
}

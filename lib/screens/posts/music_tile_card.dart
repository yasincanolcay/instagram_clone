// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';


class MusicTileCard extends StatefulWidget {
  const MusicTileCard({
    super.key,
    required this.snapshot,
    required this.index,
    required this.playerMethods,
    required this.setSelectedIndex,
    required this.selectedIndex,
    required this.setMusic,
  });
  final snapshot;
  final int index;
  final AudioPlayersMethods playerMethods;
  final Function(int selected) setSelectedIndex;
  final int selectedIndex;
  final Function(String id, Map data) setMusic;

  @override
  State<MusicTileCard> createState() => _MusicTileCardState();
}

class _MusicTileCardState extends State<MusicTileCard> {
  @override
  void dispose() {
    widget.playerMethods.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: widget.playerMethods.player.onPlayerStateChanged,
        builder: (context, snapshot) {
          return ListTile(
            onTap: () {
              widget.setMusic(
                  widget.snapshot["url"], Map.from(widget.snapshot));
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.snapshot["thumbnail"],
              ),
            ),
            title: Text(
              widget.snapshot["name"],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(widget.snapshot["author"]),
            trailing: IconButton(
              onPressed: () {
                if (snapshot.data == PlayerState.playing &&
                    widget.index == widget.selectedIndex) {
                  widget.playerMethods.stop();
                } else {
                  widget.playerMethods
                      .playMusic(UrlSource(widget.snapshot["url"]));
                  widget.setSelectedIndex(widget.index);
                }
              },
              icon: snapshot.data == PlayerState.playing &&
                      widget.index == widget.selectedIndex
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow_rounded),
            ),
          );
        });
  }
}

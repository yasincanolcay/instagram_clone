// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/audio_players_methods.dart';
import 'package:instagram_clone/screens/posts/music_tile_builder.dart';
import 'package:instagram_clone/utils/colors.dart';

class CategoryBuilder extends StatefulWidget {
  const CategoryBuilder(
      {super.key, required this.playerMethods, required this.setMusic});
  final AudioPlayersMethods playerMethods;
  final Function(String id, Map data) setMusic;
  @override
  State<CategoryBuilder> createState() => _CategoryBuilderState();
}

class _CategoryBuilderState extends State<CategoryBuilder> {
  List<String> categories = [];
  bool isLoaded = false;
  bool isClick = false;
  int categoryIndex = 0;
  void getAllCategories() async {
    var snap = await FirebaseFirestore.instance
        .collection("PostMusics")
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (!categories.contains(element["category"])) {
          categories.add(element["category"]);
          setState(() {});
        }
      }
    });
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoaded
          ? (!isClick
              ? GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                    ],
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          categoryIndex = index;
                          isClick = true;
                        });
                      },
                      child: Card(
                        color: backgroundColor,
                        shadowColor: Colors.black.withOpacity(0.3),
                        elevation: 1.0,
                        child: Center(
                          child: Text(
                            categories[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isClick = false;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                            ),
                          ),
                          const Text("Geri Git"),
                        ],
                      ),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("PostMusics")
                            .where("category",
                                isEqualTo: categories[categoryIndex])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                ))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

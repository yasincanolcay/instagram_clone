import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/push/post_viewer_page.dart';
import 'package:instagram_clone/screens/push/searcher_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/postwidgets/post_grid_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        titleSpacing: 4.0,
        title: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: textFieldColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: TextFormField(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const SearcherPage(isPost: false, hashtag: ""),
                ),
              );
            },
            readOnly: true,
            decoration: const InputDecoration(
                hintText: "Arama Yapın...",
                suffixIcon: Icon(Icons.search_rounded),
                border: InputBorder.none),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("Posts").get(),
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

            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(2, 1),
                  const QuiltedGridTile(1, 1),
                ],
              ),
              itemBuilder: (context, index) {
                Map<String, dynamic> data = snapshot.data!.docs[index].data();
                return PostGridCard(data: data);
              },
            );
          },
        ),
      ),
    );
  }
}

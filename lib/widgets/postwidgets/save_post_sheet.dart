import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/widgets/postwidgets/add_saved_collection.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';

class SavePostSheet extends StatefulWidget {
  final Function(String collectionName, bool isBack) savePost;
  final String thumbnail;
  const SavePostSheet({
    super.key,
    required this.savePost,
    required this.thumbnail,
  });

  @override
  State<SavePostSheet> createState() => _SavePostSheetState();
}

class _SavePostSheetState extends State<SavePostSheet> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> collections = [];
  QuerySnapshot<Map<String, dynamic>>? snap;

  void getSavedPost() async {
    snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("SavedPosts")
        .get();
    for (var element in snap!.docs) {
      if (!collections.contains(element.data()["collectionName"]) &&
          element.data()["collectionName"] != "Kaydedilenler") {
        collections.add(element.data()["collectionName"]);
        setState(() {});
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    getSavedPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SheetTouchButton(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddSavedCollection(
                    savePost: widget.savePost,
                    thumbnail: widget.thumbnail,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Card(
                elevation: 1.0,
                color: Colors.white,
                shadowColor: textColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Yeni Koleksiyon Ekle"),
                    SizedBox(
                      width: 8.0,
                    ),
                    Icon(
                      Icons.add,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          //tıklayınca o koleksiyona kaydetsin
          //postCard daki kaydetme fonksşyonunu tetikleycegiz
          snap != null
              ? (snap!.docs.isNotEmpty
                  ? DefauldSavedCard(
                      savePost: widget.savePost,
                      collectionName: "Kaydedilenler",
                      snap: snap,
                    )
                  : const SizedBox())
              : const SizedBox(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              return SavedPostCollectionCard(
                savePost: widget.savePost,
                collectionName: collections[index],
                snap: snap,
              );
            },
          ),
        ],
      ),
    );
  }
}


class SavedPostCollectionCard extends StatefulWidget {
  final String collectionName;
  final QuerySnapshot<Map<String, dynamic>>? snap;
  final Function(String collectionName, bool isBack) savePost;
  const SavedPostCollectionCard({
    super.key,
    required this.collectionName,
    required this.snap,
    required this.savePost,
  });

  @override
  State<SavedPostCollectionCard> createState() =>
      _SavedPostCollectionCardState();
}

class _SavedPostCollectionCardState extends State<SavedPostCollectionCard> {
  int postLength = 0;
  String thumbnail = "";

  void checkCollectionData() {
    postLength = widget.snap!.docs
        .where((element) =>
            element.data()["collectionName"] == widget.collectionName)
        .length;
    thumbnail = widget.snap!.docs
        .where((element) =>
            element.data()["collectionName"] == widget.collectionName)
        .last
        .data()["thumbnail"];
    setState(() {});
  }

  @override
  void initState() {
    checkCollectionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        widget.savePost(widget.collectionName, true);
      },
      leading: CachedNetworkImage(
        cacheManager: GlobalClass.customCacheManager,
        key: UniqueKey(),
        memCacheHeight: 200,
        width: 50,
        height: 50,
        imageUrl: thumbnail,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorWidget: (context, error, stackTrace) {
          return Center(
            child: Image.asset(
              'assets/images/error.png',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          );
        },
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
      ),
      title: Text(
        widget.collectionName,
        style: const TextStyle(
          color: textColor,
          fontFamily: "poppins1",
        ),
      ),
      subtitle: Text("$postLength Adet Gönderi"),
      trailing: const Icon(
        Icons.add,
        color: textColor,
      ),
    );
  }
}

class DefauldSavedCard extends StatefulWidget {
  final String collectionName;
  final QuerySnapshot<Map<String, dynamic>>? snap;
  final Function(String collectionName, bool isBack) savePost;
  const DefauldSavedCard({
    super.key,
    required this.collectionName,
    required this.snap,
    required this.savePost,
  });

  @override
  State<DefauldSavedCard> createState() => _DefauldSavedCardState();
}

class _DefauldSavedCardState extends State<DefauldSavedCard> {
  int postLength = 0;
  String thumbnail = "";

  void checkCollectionData() {
    postLength = widget.snap!.docs
        .where((element) =>
            element.data()["collectionName"] == widget.collectionName)
        .length;
    thumbnail = widget.snap!.docs
        .where((element) =>
            element.data()["collectionName"] == widget.collectionName)
        .last
        .data()["thumbnail"];
    setState(() {});
  }

  @override
  void initState() {
    checkCollectionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        widget.savePost(widget.collectionName, true);
      },
      leading: CachedNetworkImage(
        cacheManager: GlobalClass.customCacheManager,
        key: UniqueKey(),
        memCacheHeight: 200,
        width: 50,
        height: 50,
        imageUrl: thumbnail,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorWidget: (context, error, stackTrace) {
          return Center(
            child: Image.asset(
              'assets/images/error.png',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          );
        },
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
      ),
      title: Text(
        widget.collectionName,
        style: const TextStyle(
          color: textColor,
          fontFamily: "poppins1",
        ),
      ),
      subtitle: Text("$postLength Adet Gönderi"),
      trailing: const Icon(
        Icons.add,
        color: textColor,
      ),
    );
  }
}

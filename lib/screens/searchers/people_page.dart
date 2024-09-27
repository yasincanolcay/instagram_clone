import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({
    super.key,
    required this.value,
  });
  final String value;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("users")
            .orderBy("username")
            .startAt([widget.value]).endAt(['${widget.value}\uf8ff']).get(),
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              User user = User.fromSnap(snapshot.data!.docs[index]);
              return ListTile(
                onTap: () {
                  //profil sayfasına gidecek
                },
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.profilePhoto,
                    cacheManager: GlobalClass.customCacheManager,
                  ),
                ),
                title: Text(
                  user.username,
                  style: const TextStyle(
                    fontFamily: "poppins1",
                  ),
                ),
                subtitle: Text(
                  user.bio,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

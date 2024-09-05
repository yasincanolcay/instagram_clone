// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/global_class.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';

class TaggedUsersSheet extends StatelessWidget {
  const TaggedUsersSheet({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SheetTouchButton(),
          Column(
            children: List.generate(snap["users"].length, (index) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    snap["users"][index]["profilePhoto"],
                    cacheManager: GlobalClass.customCacheManager,
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snap["users"][index]["username"],
                      style: const TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),
                    snap["users"][index]["verified"]
                        ? const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                isThreeLine: false,
              );
            }),
          ),
        ],
      ),
    );
  }
}

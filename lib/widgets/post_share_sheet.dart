// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:instagram_clone/screens/posts/photo_description_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/postwidgets/sheet_touch_button.dart';

class PostShareSheet extends StatelessWidget {
  const PostShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetTouchButton(),
        ListTile(
          onTap: () async {
            // set picker theme based on app theme primary color
            final theme =
                InstaAssetPicker.themeData(Theme.of(context).primaryColor);
            final images = await InstaAssetPicker.pickAssets(
              context,
              pickerTheme: theme.copyWith(
                canvasColor: Colors.black, // body background color
                splashColor: Colors.grey, // ontap splash color
                colorScheme: theme.colorScheme.copyWith(
                  background: Colors.black87, // albums list background color
                ),
                appBarTheme: theme.appBarTheme.copyWith(
                  backgroundColor: Colors.black, // app bar background color
                  titleTextStyle: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle
                      ?.copyWith(
                          color: Colors
                              .white), // change app bar title text style to be like app theme
                ),
                // edit `confirm` button style
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    disabledForegroundColor: Colors.red,
                  ),
                ),
              ),
              onCompleted: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoDescriptionScreen(
                      photoStream: _,
                      editMode: false,
                      snap: null,
                    ),
                  ),
                );
              },
              title: "Gönderi Paylaşın",
            );
          },
          title: const Text("Gönderi Paylaş"),
          leading: const Icon(
            Icons.photo,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {},
          title: const Text("Reels Paylaş"),
          leading: const Icon(
            Icons.movie_filter,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {},
          title: const Text("Hikaye Paylaş"),
          leading: const Icon(
            Icons.auto_awesome_rounded,
            color: textColor,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_class.dart';

class AddSavedCollection extends StatelessWidget {
  final Function(String colletionName, bool isBack) savePost;
  final String thumbnail;
  AddSavedCollection({
    super.key,
    required this.savePost,
    required this.thumbnail,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text("Koleksiyon Ekle"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: CachedNetworkImageProvider(
                    thumbnail,
                    cacheManager: GlobalClass.customCacheManager,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextFormField(
                    controller: _controller,
                    style: const TextStyle(
                      color: textColor,
                      fontFamily: "poppins1",
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Koleksiyon İsmi...",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                    onPressed: () {
                      savePost(_controller.text, true);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.blue),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                          ),
                        )),
                    child: const Text(
                      "Koleksiyona Kaydet",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "poppins1",
                      ),
                    )),
              ]),
        ),
      ),
    );
  }
}

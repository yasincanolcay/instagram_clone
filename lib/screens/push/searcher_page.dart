import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/searchers/hastag_page.dart';
import 'package:instagram_clone/screens/searchers/people_page.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearcherPage extends StatefulWidget {
  const SearcherPage({
    super.key,
    required this.isPost,
    required this.hashtag,
  });
  final bool isPost;
  final String hashtag;

  @override
  State<SearcherPage> createState() => _SearcherPageState();
}

class _SearcherPageState extends State<SearcherPage> {
  final TextEditingController _controller = TextEditingController();
  bool isChanged = false;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.isPost) {
      _controller.text = widget.hashtag;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
            ),
          ),
          title: TextFormField(
            controller: _controller,
            onChanged: (s) {
              setState(() {
                isChanged = true;
              });
            },
            decoration: const InputDecoration(
              hintText: "Arama Yapın...",
              suffixIcon: Icon(Icons.search_rounded),
            ),
          ),
          bottom: const TabBar(tabs: [
            Tab(
              icon: Icon(
                Icons.tag_rounded,
                color: textColor,
              ),
              child: Text("#Hashtags"),
            ),
            Tab(
              icon: Icon(
                Icons.people_rounded,
                color: textColor,
              ),
              child: Text("Kişiler"),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            HashtagPage(
              isChangedSetter: (value, st) {
                setState(() {
                  _controller.text = st;
                  isChanged = value;
                });
              },
              isClick: !isChanged,
              isPost: widget.isPost,
              hashtag: widget.isPost && !isChanged
                  ? widget.hashtag
                  : "${_controller.text}",
            ),
            const PeoplePage(),
          ],
        ),
      ),
    );
  }
}

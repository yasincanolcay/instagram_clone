import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/pageviewer_screens/feed.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/profile_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/reels_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/search_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_share_sheet.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  final PageController _pageController = PageController();
  int _page = 0;
  void onChangedPage(int page) {
    setState(() {
      _page = page;
    });
  }

  void nextPage(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: PageView(
        controller: _pageController,
        onPageChanged: onChangedPage,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          //buraya sayfalar gelecek
          Feed(),
          SearchPage(),
          ReelsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 1,
              color: textColor.withOpacity(0.3),
            ),
          ),
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                nextPage(0);
              },
              icon: Icon(
                Icons.home_rounded,
                color: _page == 0 ? Colors.black : null,
              ),
            ),
            IconButton(
              onPressed: () {
                nextPage(1);
              },
              icon: Icon(
                Icons.search_rounded,
                color: _page == 1 ? Colors.black : null,
              ),
            ),
            IconButton(
              onPressed: () {
                // gönderi paylaşımı yapılacak
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  builder: (context) {
                    return PostShareSheet();
                  },
                );
              },
              icon: const Icon(
                Icons.add_box_outlined,
              ),
            ),
            IconButton(
              onPressed: () {
                nextPage(2);
              },
              icon: Icon(
                _page != 2
                    ? Icons.movie_creation_outlined
                    : Icons.movie_creation_rounded,
                color: _page == 2 ? Colors.black : null,
              ),
            ),
            IconButton(
              onPressed: () {
                nextPage(3);
              },
              icon: Icon(
                _page != 3
                    ? Icons.account_circle_outlined
                    : Icons.account_circle_rounded,
                color: _page == 3 ? Colors.black : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/pageviewer_screens/feed.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/profile_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/reels_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/search_page.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/page_routes.dart';
import 'package:instagram_clone/widgets/post_share_sheet.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int _page = 0;

  void nextPage(int page) {
    _page = page;
    currentUser.page = page;
    currentUser.uid = uid;
    setState(() {});
  }

  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  List<Widget> _widgetOptions = <Widget>[];

  buildNavigator() {
    return Navigator(
      key: navigatorKeys[currentUser.page],
      onGenerateRoute: (RouteSettings settings) {
        _widgetOptions[3] = ProfilePage(
          uid: currentUser.uid,
        );
        return MaterialPageRoute(
          builder: (_) => _widgetOptions.elementAt(
            currentUser.page,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _widgetOptions = [
      const Feed(),
      const SearchPage(),
      const ReelsPage(),
      ProfilePage(
        uid: currentUser.uid,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: buildNavigator(),
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
                nextPage(
                  0,
                );
              },
              icon: Icon(
                Icons.home_rounded,
                color: _page == 0 ? Colors.black : null,
              ),
            ),
            IconButton(
              onPressed: () {
                nextPage(
                  1,
                );
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
                nextPage(
                  2,
                );
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
                nextPage(
                  3,
                );
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

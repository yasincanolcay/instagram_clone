import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/pageviewer_screens/feed.dart';
import 'package:instagram_clone/screens/pageviewer_screens/profilePage/profile_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/reels_page.dart';
import 'package:instagram_clone/screens/pageviewer_screens/search_page.dart';

class PageRouteNames {
  static const String feed = '/feed';
  static const String search = '/search';
  static const String reels = '/reels';
  static const String profile = '/profile';
}

Map<String, WidgetBuilder> routes = {
  PageRouteNames.feed: (context) => const Feed(),
  PageRouteNames.search: (context) => const SearchPage(),
  PageRouteNames.reels: (context) => const ReelsPage(),
  PageRouteNames.profile: (context) => ProfilePage(
        uid: "",
      ),
};

class UserInfo {
  String uid = '';
  int page = 0;

  UserInfo({
    required this.uid,
    required this.page,
  });

  UserInfo.empty();
}

UserInfo currentUser = UserInfo.empty();

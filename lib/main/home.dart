import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/friends/friends_page.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/news/news_page.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/substitute/substitute_page.dart';
import 'package:Vertretung/substitute/substitute_pull_to_refresh.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  GlobalKey<NewsPageState> newsKey = GlobalKey();
  bool friendsFeature;
  List<Widget> pagesWithFriendsPage;
  List<Widget> pagesWithoutFriendsPage;
  List<GlobalKey<SubstitutePullToRefreshState>> keyList = [
    MyKeys.firstTab,
    MyKeys.secondTab,
    MyKeys.thirdTab,
    MyKeys.fourthTab,
  ];

  _HomeState() {
    pagesWithFriendsPage = [
      SubstitutePage(),
      FriendsPage(),
      NewsPage(
        key: newsKey,
      ),
    ];
    pagesWithoutFriendsPage = [
      SubstitutePage(),
      NewsPage(
        key: newsKey,
      ),
    ];
  }

  @override
  void initState() {
    FirebaseAnalytics().setCurrentScreen(screenName: "SubstitutePage");
    SharedPref.getBool(Names.friendsFeature)
        .then((value) => setState(() => friendsFeature = value));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    friendsFeature = Provider.of<UserData>(context).friendsFeature;
    super.didChangeDependencies();
  }

  void animatePages(index) {
    if (friendsFeature)
      switch (index) {
        case 0:
          for (GlobalKey<SubstitutePullToRefreshState> key in keyList) {
            if (key.currentState != null) key.currentState.reAnimate();
          }
          break;
        case 1:
          if (MyKeys.friendsTab.currentState != null)
            MyKeys.friendsTab.currentState.reAnimate();
          break;

        case 2:
          if (newsKey.currentState != null) newsKey.currentState.reAnimate();
          break;
      }
    else
      switch (index) {
        case 0:
          for (GlobalKey<SubstitutePullToRefreshState> key in keyList) {
            if (key.currentState != null) key.currentState.reAnimate();
          }
          break;
        case 1:
          if (newsKey.currentState != null) newsKey.currentState.reAnimate();
          break;
        default:
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //by this Indexed Stack, the pages are not reloaded every time
      body: IndexedStack(
        children:
            friendsFeature ? pagesWithFriendsPage : pagesWithoutFriendsPage,
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        backgroundColor:
            context.watch<ThemeSettings>().brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            title: Text("Vertretung"),
          ),
          if (friendsFeature)
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text("Freunde"),
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: Text("Nachrichten"),
          ),
        ],
        onTap: (index) {
          if (index != currentIndex) {
            animatePages(index);
            FirebaseAnalytics().setCurrentScreen(
                screenName: friendsFeature
                    ? pagesWithFriendsPage[index].toStringShort()
                    : pagesWithoutFriendsPage[index].toStringShort());
          }
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

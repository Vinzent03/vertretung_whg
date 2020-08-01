import 'package:Vertretung/friends/friendsPage.dart';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/otherWidgets/substituteList.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/substitute//substitutePage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  GlobalKey<FriendsPageState> friendKey = GlobalKey();
  GlobalKey<NewsPageState> newsKey = GlobalKey();
  bool friendsFeature = false;
  ThemeMode selectedThemeMode;
  List<Widget> pagesWithFriendsPage;
  List<Widget> pagesWithoutFriendsPage;
  List<GlobalKey<SubstituteListState>> keyList = [
    MyKeys.firstTab,
    MyKeys.secondTab,
    MyKeys.thirdTab,
    MyKeys.fourthTab,
  ];
  Future<void> showUpdateDialog(context) async {
    CloudDatabase cd = CloudDatabase();

    updateCodes updateSituation = await cd.getUpdate();
    String link = await cd.getUpdateLink();
    List<dynamic> message = await cd.getUpdateMessage();

    if (updateCodes.availableNormal == updateSituation ||
        updateCodes.availableForce == updateSituation) {
      if (updateCodes.availableForce == updateSituation)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              // ignore: missing_return
              onWillPop: () {},
              child: AlertDialog(
                title: Text(message[0]),
                content: Text(message[1]),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("Update"),
                    onPressed: () => launch(link),
                  )
                ],
              ),
            );
          },
        );
      else
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Text(message[0]),
              content: Text(message[1]),
              actions: <Widget>[
                FlatButton(
                  child: Text("abbrechen"),
                  onPressed: () => Navigator.pop(context),
                ),
                RaisedButton(
                  child: Text("Update"),
                  onPressed: () => launch(link),
                )
              ],
            );
          },
        );
    }
  }

  _HomeState() {
    pagesWithFriendsPage = [
      SubstitutePage(
        reloadFriendsSubstitute: reloadFriendsSubstitute,
        updateFriendFeature: updateFriendFeature,
      ),
      FriendsPage(
        key: friendKey,
      ),
      NewsPage(
        key: newsKey,
      ),
    ];
    pagesWithoutFriendsPage = [
      SubstitutePage(
        reloadFriendsSubstitute: reloadFriendsSubstitute,
        updateFriendFeature: updateFriendFeature,
      ),
      NewsPage(
        key: newsKey,
      ),
    ];
  }

  @override
  void initState() {
    FirebaseAnalytics().setCurrentScreen(screenName: "SubstitutePage");
    showUpdateDialog(context);
    SharedPref()
        .getBool(Names.friendsFeature)
        .then((value) => setState(() => friendsFeature = value));
    super.initState();
  }

  void reloadFriendsSubstitute() {
    if (friendsFeature) friendKey.currentState.reloadFriendsSubstitute();
  }

  void updateFriendFeature() {
    SharedPref().getBool(Names.friendsFeature).then((value) {
      if (value != friendsFeature)
        setState(() {
          friendsFeature = value;
        });
    });
  }

  void animatePages(index) {
    if (friendsFeature)
      switch (index) {
        case 0:
          for (GlobalKey<SubstituteListState> key in keyList) {
            if (key.currentState != null) key.currentState.reAnimate();
          }
          break;
        case 1:
          MyKeys.friendsTab.currentState.reAnimate();
          break;

        case 2:
          newsKey.currentState.reAnimate();
          break;
      }
    else
      switch (index) {
        case 0:
          for (GlobalKey<SubstituteListState> key in keyList) {
            if (key.currentState != null) key.currentState.reAnimate();
          }
          break;
        case 1:
          newsKey.currentState.reAnimate();
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
            Provider.of<ProviderData>(context).getUsedTheme() == Brightness.dark
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

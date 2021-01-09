import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/friends/add_friend_dialog.dart';
import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/friends/friends_page.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/main/main_screen/overview_page.dart';
import 'package:Vertretung/main/main_screen/school_class_substitute.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/news_model.dart';
import 'package:Vertretung/news/news_page.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/substitute/substitute_logic.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  bool isAdmin = false;
  bool loadedAdminStatus = false;
  String schoolClass;
  List<FriendModel> friendsSettings = [];
  List<NewsModel> news;
  bool substituteLoaded = false;
  final SubstituteLogic substituteLogic = SubstituteLogic();
  final RefreshController refreshController = RefreshController();

  @override
  void initState() {
    CloudDatabase().getFriendsSettings().listen((event) {
      if (mounted) {
        setState(() => friendsSettings = event);
      }
    });
    AuthService().getAdminStatus().then((value) {
      if (mounted) {
        loadedAdminStatus = true;
        setState(() => isAdmin = value);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    UserData provider = Provider.of<UserData>(context);
    if (provider.schoolClass != schoolClass || loadedAdminStatus) {
      if (loadedAdminStatus) loadedAdminStatus = false;
      schoolClass = provider.schoolClass;
      CloudDatabase().getNews(schoolClass, isAdmin).listen((event) {
        setState(() => news = event);
      });
    }
    if (!substituteLoaded)
      substituteLogic
          .reloadSubstitute(context, refreshController)
          .then((value) => substituteLoaded = true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool friendsFeature = context.watch<UserData>().friendsFeature;
    return Scaffold(
      appBar: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Übersicht ${substituteLogic.getWeekNumber()}.KW"),
              Text(
                "Letzte Änderung: ${context.watch<UserData>().lastChange}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () {
                showOriginalSubstituteBottomSheet(context);
              },
            ),
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () =>
                    Navigator.pushNamed(context, Names.settingsPage))
          ],
        ),
        if (context.watch<UserData>().personalSubstitute)
          AppBar(title: Text("Vertretung von $schoolClass")),
        if (friendsFeature)
          AppBar(
            title: Text(
              "Freunde",
              textAlign: TextAlign.left,
            ),
            actions: <Widget>[
              Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => showFriendsPageOptionsBottomSheet(context),
                );
              }),
            ],
          ),
        AppBar(
          title: Text("Nachrichten"),
        ),
      ][currentIndex],
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: [
          OverviewPage(
            friendsSettings: friendsSettings,
            finishedLoading: substituteLoaded,
            swapPage: swapPage,
            refresh: () =>
                substituteLogic.reloadSubstitute(context, refreshController),
            refreshController: refreshController,
          ),
          if (context.watch<UserData>().personalSubstitute)
            SchoolClassSubstitute(
              today: Filter.checkForSchoolClass(
                context.watch<UserData>().schoolClass,
                context.watch<UserData>().rawSubstituteToday,
              ),
              tomorrow: Filter.checkForSchoolClass(
                context.watch<UserData>().schoolClass,
                context.watch<UserData>().rawSubstituteTomorrow,
              ),
              refresh: () =>
                  substituteLogic.reloadSubstitute(context, refreshController),
              refreshController: refreshController,
            ),
          if (friendsFeature) FriendsPage(friendsSettings: friendsSettings),
          NewsPage(
            news: news,
            isAdmin: isAdmin,
          ),
        ][currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: swapPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Übersicht",
          ),
          if (context.watch<UserData>().personalSubstitute)
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label:
                  ["EF", "Q1", "Q2"].contains(schoolClass) ? "Stufe" : "Klasse",
            ),
          if (friendsFeature)
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Freunde",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: "Nachrichten",
          ),
        ],
      ),
    );
  }

  void swapPage(int index) => setState(() => currentIndex = index);

  void showFriendsPageOptionsBottomSheet(context) => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                title: Text("Deinen Freundestoken teilen"),
                leading: Icon(Icons.share),
                onTap: () {
                  Navigator.pop(context);
                  FriendLogic.shareFriendsToken(context);
                }),
            ListTile(
                title: Text("Als Freund eintragen"),
                leading: Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (context) => AddFriendDialog());
                }),
            ListTile(
              title: Text("Freundesliste"),
              leading: Icon(Icons.list),
              onTap: () async {
                await Navigator.pushNamed(context, Names.friendsList);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );

  void showOriginalSubstituteBottomSheet(context) => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                "Öffne Vertretung auf DSBmobile Website:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
                title: Text("Heute"),
                leading: Icon(Icons.today),
                onTap: () {
                  Navigator.pop(context);
                  launch(Names.substituteLinkToday);
                }),
            ListTile(
                title: Text("Morgen"),
                leading: Icon(Icons.today),
                onTap: () {
                  Navigator.pop(context);
                  launch(Names.substituteLinkTomorrow);
                }),
          ],
        ),
      );
}

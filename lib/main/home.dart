import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/friends/add_friend_dialog.dart';
import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/friends/friends_page.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/main/main_screen/overview_page.dart';
import 'package:Vertretung/main/main_screen/school_class_substitute.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/news_model.dart';
import 'package:Vertretung/news/news_page.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/services/remote_config.dart';
import 'package:Vertretung/settings/subjectsSelection/subjects_page.dart';
import 'package:Vertretung/substitute/substitute_logic.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  bool isAdmin = false;
  String schoolClass;
  List<FriendModel> friendsSettings = [];
  List<NewsModel> rawNews = [];
  bool substituteLoaded = false;
  final SubstituteLogic substituteLogic = SubstituteLogic();

  @override
  void initState() {
    CloudDatabase().getFriendsSettings().listen((event) {
      if (mounted) setState(() => friendsSettings = event);
    });
    AuthService().getAdminStatus().then((value) {
      if (mounted) setState(() => isAdmin = value);
    });
    CloudDatabase().getNews().listen((newNews) {
      if (mounted) setState(() => rawNews = newNews);
    });
    checkSubjects();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    schoolClass = context.read<UserData>().schoolClass;

    if (!substituteLoaded)
      substituteLogic
          .reloadSubstitute(context)
          .then((value) => setState(() => substituteLoaded = true));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool friendsFeature = context.watch<UserData>().friendsFeature;
    final List<NewsModel> news = rawNews
        .where(
            (element) => element.schoolClass.contains(schoolClass) || isAdmin)
        .toList();
    return Scaffold(
      appBar: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Übersicht ${SubstituteLogic.getWeekNumber()}.KW"),
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
            refresh: () => substituteLogic.reloadSubstitute(context),
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
              refresh: () => substituteLogic.reloadSubstitute(context),
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
                  launch(RemoteConfigService.getLinks(
                          context.read<UserData>().schoolClass)
                      .today);
                }),
            ListTile(
                title: Text("Morgen"),
                leading: Icon(Icons.today),
                onTap: () {
                  Navigator.pop(context);
                  launch(RemoteConfigService.getLinks(
                          context.read<UserData>().schoolClass)
                      .tomorrow);
                }),
          ],
        ),
      );

  /// If the user has personal substitute turned on, but his subject list is empty, he gets a SnackBar
  void checkSubjects() async {
    await Future.delayed(Duration(seconds: 5));
    if (!mounted) return;
    UserData userData = context.read<UserData>();

    if (userData.personalSubstitute) {
      if (["EF", "Q1", "Q2"].contains(userData.schoolClass)) {
        if (userData.subjects.isEmpty) {
          showEmptySubjectsSnackBar(true);
        }
      } else if (userData.subjectsNot.isEmpty) {
        showEmptySubjectsSnackBar(false);
      }
    }
  }

  void showEmptySubjectsSnackBar(bool isWhitelist) {
    Duration duration = Duration(seconds: 10);
    SnackBar snackBar = SnackBar(
      content: Text("Deine Fächerliste ist leer."),
      action: SnackBarAction(
        label: "Problem lösen",
        onPressed: () => showAddSubjectsDialog(isWhitelist),
      ),
      duration: duration,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showAddSubjectsDialog(bool isWhitelist) {
    String message;
    if (isWhitelist) {
      message =
          "Am besten fügst Du Deine Fächer hinzu. So siehst Du nur Vertretung, die für Dich wichtig ist. Wenn Du die personalisierte Vertretung nicht nutzen willst, deaktiviere sie.";
    } else {
      message =
          "Am besten fügst Du die Fächer Deiner Mitschüler ein, die Du nicht hast. So siehst Du nur Vertretung, die für Dich wichtig ist. Wenn Du die personalisierte Vertretung nicht nutzen willst, deaktiviere sie.";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Fächer eingeben"),
        content: Text(message),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              confirmDeactivatePersonalSubstitute();
            },
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.red)),
            child: Text("Deaktivieren"),
          ),
          ElevatedButton(
            child: Text("Fächer eingeben"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SubjectsPage(isWhitelist: isWhitelist)),
              );
            },
          ),
        ],
      ),
    );
  }

  void confirmDeactivatePersonalSubstitute() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Bist Du Dir sicher?"),
        content: Text(
            "Personalisierte Vertretung ist die Hauptfunktion dieser App. Es geht auch sehr gut ohne, aber mit bietet sie noch mehr Nutzen."),
        actions: [
          ElevatedButton(
            onPressed: () async {
              UserData userData = context.read<UserData>();
              userData.personalSubstitute = false;
              Navigator.pop(context);
              bool notificationOnChange =
                  await SharedPref.getBool(Names.notificationOnChange);
              bool notificationOnFirstChange =
                  await SharedPref.getBool(Names.notificationOnFirstChange);
              CloudDatabase().updateUserData(
                personalSubstitute: false,
                schoolClass: userData.schoolClass,
                notificationOnChange: notificationOnChange,
                notificationOnFirstChange: notificationOnFirstChange,
              );
            },
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.red)),
            child: Text("Deaktivieren"),
          ),
        ],
      ),
    );
  }
}

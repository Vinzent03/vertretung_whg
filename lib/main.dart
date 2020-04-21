import 'package:Vertretung/pages/aboutPage.dart';
import 'package:Vertretung/pages/faecherPage.dart';
import 'package:Vertretung/pages/helpPage.dart';
import 'package:Vertretung/pages/introScreen.dart';
import 'package:Vertretung/pages/newsPage.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:Vertretung/widgets/generalSite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/filter.dart';
import 'logic/functionsForMain.dart';
import 'logic/localDatabase.dart';
import 'logic/names.dart';
import 'logic/theme.dart';
import 'logic/themedata.dart';
import 'pages/settingsPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDatabase().getBool(Names.dark).then((isDark) {
    runApp(ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(isDark ? darkTheme : lightTheme, isDark),
      child: MyAppSt(),
    ));
  });
}

class MyAppSt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      initialRoute: Names.homePage,
      routes: {
        Names.homePage: (context) => MyApp(),
        Names.settingsPage: (context) => SettingsPage(),
        Names.helpPage: (context) => HelpPage(),
        Names.introScreen: (context) => IntroScreen(),
        Names.faecherPage: (context) => FaecherPage(),
        Names.newsPage: (context) => NewsPage(),
        Names.aboutPage: (context) => AboutPage(),
      },
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = PageController(initialPage: 0);
  CloudDatabase cd;
  LocalDatabase getter = LocalDatabase();
  int currentIndex = 0;//the index of the bottomNavigationBar(heute/morgen)
  int currentPage = 0;
  bool isNewsAvailable = false;
  bool faecherOn = false;//of personalisierte Vertretung is enabled
  bool horizontal = true;//how to swipe
  bool twoPages = false;
  bool shouldShowBanner = false;//the banner if a update is recommended
  String change = "Loading";// The last tine the data on dsb mobile changed
  List<String> listWithoutClasses = [""];

  //initialize these list, because to load faecher from localDatabase takes time, and the UI have to be build
  List<List<String>> myListToday = [
    [""],
    [""]
  ];
  List<List<String>> listToday = [
    [""],
    [""]
  ];
  List<List<String>> myListTomorrow = [
    [""],
    [""]
  ];
  List<List<String>> listTomorrow = [
    [""],
    [""]
  ];

  List<String> rawListToday = [
    "6a",
    "4. Std. BI bei MK im Raum H024 ",
    "07A, 07B, 07C",
    "6. Std. F6 bei ??? im Raum H111  statt bei VT",
    "08A, 08B, 08C, 08F",
    "4. Std. WW im Raum ??? ",
    "EF",
    "4. - 5. Std. M-GK1 bei SI im Raum H216  statt bei SE",
    "4. - 5. Std. L6-GK2 im Raum ??? ",
    "Q1",
    "8. Std. S0-GK1 bei + im Raum H137  statt bei VT",
    "9. Std. S0-GK1 bei + im Raum H137  statt bei VT",
    "Q2",
    "6. - 7. Std. L6-GK1 im Raum ??? ",
    "6. - 7. Std. L6-GK1 im Raum ??? "
  ];
  List<String> rawListTomorrow = [
    "6a",
    "4. Std. Wy bei Mu im Raum H024 ",
    "07A, 07B, 07C",
    "3. Std. Ku bei ??? im Raum H111  statt bei Kn",
    "08A, 08B, 08C, 08F",
    "2. Std. L6 im Raum ??? ",
    "EF",
    "4. - 5. Std. Mu-GK1 bei SI im Raum H216  statt bei We",
    "4. - 5. Std. M-GK2 im Raum ??? ",
    "Q1",
    "8. Std. S0-GK1 bei + im Raum H137  statt bei VT",
    "9. Std. S0-GK1 bei + im Raum H137  statt bei VT",
    "Q2",
    "6. - 7. Std. Pl-GK5 im Raum ??? "
  ];

  void reload() {
    setState(() {
      change = "Loading";
    });
    /*getData().then((st) { //Now in functionsForMain.dart But have to called here however
      setState(() {
        change = st;
      });
    });*/
  }

  void refresh() async {
    getter.setStringList(Names.lessonsToday, rawListToday);
    getter.setStringList(Names.lessonsTomorrow, rawListTomorrow);
    getter.getBool(Names.faecherOn).then((onValue) {
      if (mounted) {
        setState(() {
          faecherOn = onValue;
        });
      }
    });
    getter.getBool(Names.twoPages).then((onValue) {
      if (mounted) {
        setState(() {
          twoPages = onValue;
        });
      }
    });
    getter.getBool(Names.horizontal).then((onValue) {
      if (mounted) {
        setState(() {
          horizontal = onValue;
        });
      }
    });
    Filter filter = Filter();
    List<List<String>> allMyListToday;
    List<List<String>> allListToday;
    List<List<String>> allMyListTomorrow;
    List<List<String>> allListTomorrow;

    allMyListToday = await filter.checkerFaecher(Names.lessonsToday);
    allListToday = await filter.checker(Names.lessonsToday);
    allMyListTomorrow = await filter.checkerFaecher(Names.lessonsTomorrow);
    allListTomorrow = await filter.checker(Names.lessonsTomorrow);

    setState(() {
      if (mounted) {
        myListToday = allMyListToday;
        listToday = allListToday;
        myListTomorrow = allMyListTomorrow;
        listTomorrow = allListTomorrow;
      }
    });
  }

  @override
  void initState() {
    cd = CloudDatabase();

    // Show the onboarding on first start
    showOnboarding(context).then((nothing) => refresh());

    // Push-Notification handling
    PushNotificationsManager().init();

    //news badge on inbox icon handling
    cd.getIsNewsAvailable().then((onValue) {
      setState(() {
        isNewsAvailable = onValue;
      });
    });

    //update Message handling
    showUpdateDialog(context).then((showBanner) {
      setState(() {
        shouldShowBanner = showBanner;
      });
    });
    reload();
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Vertretung"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => Navigator.pushNamed(context, Names.helpPage),
            ),
            IconButton(
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.inbox),
                  Positioned(
                    left: 15,
                    child: Icon(
                      Icons.brightness_1,
                      size: isNewsAvailable ? 10 : 0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, Names.newsPage).then((onValue) {
                    setState(() {
                      isNewsAvailable = false;
                    });
                  }),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, Names.settingsPage)
                    .then((onValue) {
                  refresh();
                  getter.getBool(Names.faecherOn).then((onValue) {
                    if (mounted) {
                      setState(() {
                        faecherOn = onValue;
                      });
                    }
                  });
                  getter.getBool(Names.horizontal).then((onValue) {
                    if (mounted) {
                      setState(() {
                        horizontal = onValue;
                      });
                    }
                  });
                });
              },
            ),
          ],
        ),
        body: GeneralSite(
          controller: controller,
          change: change,
          currentIndex: currentIndex,
          faecherOn: faecherOn,
          horizontal: horizontal,
          shouldShowBanner: shouldShowBanner,
          twoPages: twoPages,
          listToday: listToday,
          listTomorrow: listTomorrow,
          myListToday: myListToday,
          myListTomorrow: myListTomorrow,
        ),


        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              reload(),
          child: Icon(
          Icons.refresh,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.getIsDark() ? Colors.black : Colors.white,
          elevation: 10,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text("Heute"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              title: Text("Morgen"),
            ),
          ],
          onTap: (index) {
            if (currentIndex == index && twoPages) {
              // Beim tab wechseln soll nicht immer die page gewechselt werden
              controller.animateToPage(controller.page == 0 ? 1 : 0,
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn);
            }
            setState(() {
              currentIndex = index;
            });
          }),
    ),);
  }
}

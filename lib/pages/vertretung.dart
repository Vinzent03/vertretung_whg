import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/logic/theme.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/widgets/generalBlueprint.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
class Vertretung extends StatefulWidget {
  @override
  _VertretungState createState() => _VertretungState();
}

class _VertretungState extends State<Vertretung> {
  final controller = PageController(initialPage: 0);
  CloudDatabase cd;
  LocalDatabase getter = LocalDatabase();
  int currentIndex = 0; //the index of the bottomNavigationBar(heute/morgen)
  int currentPage = 0;
  bool isNewsAvailable = false;
  bool faecherOn = false; //if personalisierte Vertretung is enabled
  bool horizontal = true; //how to swipe
  bool shouldShowBanner = false; //the banner if a update is recommended
  String change = "Loading"; // The last tine the data on dsb mobile changed
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

  RefreshController _refreshController =
    RefreshController(initialRefresh: false);
  int getWeekNumber() {
    DateTime date = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  void reload() {
    setState(() {
      change = "Loading";
    });
    _refreshController.refreshCompleted();
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
    reload();
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Vertretung $change  Woche:${getWeekNumber()}"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: ()=>Navigator.pushNamed(context, Names.helpPage),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: ()=>Navigator.pushNamed(context, Names.settingsPage),
              )
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.person),
                      Text("Heute")
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.person),
                      Text("Morgen")
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.group),
                      Text("Heute")
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.group),
                      Text("Morgen")
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(),
            controller: _refreshController,
            onRefresh: reload,
            child: TabBarView(
              physics: ScrollPhysics(),
              children: <Widget>[
                GeneralBlueprint(
                  change: change,
                  list: myListToday,
                  today: true,
                  isMy: true,
                ),
                GeneralBlueprint(
                  change: change,
                  list: myListTomorrow,
                  today: false,
                  isMy: true,
                ),
                GeneralBlueprint(
                  change: change,
                  list: listToday,
                  today: true,
                  isMy: false,
                ),
                GeneralBlueprint(
                  change: change,
                  list: listTomorrow,
                  today: false,
                  isMy: false,
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}

import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/substitute//FunctionsForSubstitute.dart';
import 'package:Vertretung/otherWidgets/generalBlueprint.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:Vertretung/otherWidgets/myTab.dart' as myTab;

class VertretungsPage extends StatefulWidget {
  VertretungsPage({Key key}) : super(key: key);

  @override
  _VertretungsPageState createState() => _VertretungsPageState();
}

class _VertretungsPageState extends State<VertretungsPage>
    with TickerProviderStateMixin {
  CloudDatabase cd;
  LocalDatabase getter = LocalDatabase();

  ///if the user selected personal substitute(use also subjects in filter)
  bool personalSubstitute = false;
  bool finishedLoading = false;
  bool loadingSuccess = true;

  ///The last change of the stubstitute
  String lastChange = "Loading";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //initialize these list, because to load subjects from localDatabase takes time, and the UI have to be build
  List<dynamic> myListToday = [];
  List<dynamic> listToday = [];
  List<dynamic> myListTomorrow = [];
  List<dynamic> listTomorrow = [];

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
    "6. - 7. Std. L6-GK1 im Raum ??? ",
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

  Future<void> reload({bool fromPullToRefresh = false}) async {
    SnackBar snack = SnackBar(
      content: Text("Es werden alte Daten verwendet."),
      duration: Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
          label: "Ausblenden",
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
            loadingSuccess = true; // make snackbar able to reshow
          }),
    );
    //reload the settings

    getter.getBool(Names.personalSubstitute).then((onValue) {
      setState(() {
        personalSubstitute = onValue;
      });
    });

    List<dynamic> dataResult = await FunctionsForVertretung()
        .getData(); //load the data from dsb mobile

    if (fromPullToRefresh) _refreshController.refreshCompleted();
    finishedLoading = true;
    if (dataResult.isEmpty) {
      if (loadingSuccess) Scaffold.of(context).showSnackBar(snack);
      loadingSuccess = false;
      lastChange = await getter.getString(Names.lastChange);
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      setState(() {
        lastChange = dataResult[0];
        //rawListToday = dataResult[1];
        //rawListTomorrow = dataResult[2];
      });
      getter.setString(Names.lastChange, lastChange);
      getter.setStringList(Names.substituteToday, rawListToday);
      getter.setStringList(Names.substituteTomorrow, rawListTomorrow);
    }

    String schoolClass = await LocalDatabase().getString(Names.schoolClass);
    Filter filter = Filter(schoolClass);
    List<dynamic> allMyListToday;
    List<dynamic> allListToday;
    List<dynamic> allMyListTomorrow;
    List<dynamic> allListTomorrow;

    List<String> subjectsList =
        await LocalDatabase().getStringList(Names.subjectsList);
    List<String> subjectsNotList =
        await LocalDatabase().getStringList(Names.subjectsNotList);

    allMyListToday = await filter.checkForSubjects(
        Names.substituteToday, subjectsList, subjectsNotList);
    allListToday = await filter.checkForSchoolClass(Names.substituteToday);
    allMyListTomorrow = await filter.checkForSubjects(
        Names.substituteTomorrow, subjectsList, subjectsNotList);
    allListTomorrow =
        await filter.checkForSchoolClass(Names.substituteTomorrow);

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ProviderData>(context).getVertretungReload()) {
      reload().then((value) => Provider.of<ProviderData>(context, listen: false)
          .setVertretungReload(false));
    }

    final theme = Provider.of<ProviderData>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      home: DefaultTabController(
        length: personalSubstitute ? 4 : 2,
        key: Key(personalSubstitute ? "On" : "Off"),
        //key is needed because otherwise the tab length would not be updated
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                "$lastChange  Woche: ${FunctionsForVertretung().getWeekNumber()}"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () => Navigator.pushNamed(context, Names.helpPage),
              ),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () async {
                    await Navigator.pushNamed(context, Names.settingsPage);
                    reload();
                  })
            ],
            bottom: TabBar(
              tabs: [
                if (personalSubstitute)
                  myTab.MyTab(
                    // Extra tab class, because the default tab height is too high, so I cloned the class
                    icon: Icon(
                      Icons.person,
                    ),
                    iconMargin: EdgeInsets.all(0),
                    text: "Heute",
                  ),
                if (personalSubstitute)
                  myTab.MyTab(
                    icon: Icon(
                      Icons.person,
                    ),
                    iconMargin: EdgeInsets.all(0),
                    text: "Morgen",
                  ),
                myTab.MyTab(
                  icon: Icon(
                    Icons.group,
                  ),
                  iconMargin: EdgeInsets.all(0),
                  text: "Heute",
                ),
                myTab.MyTab(
                  icon: Icon(
                    Icons.group,
                  ),
                  iconMargin: EdgeInsets.all(0),
                  text: "Morgen",
                ),
              ],
            ),
          ),
          body: finishedLoading
              ? TabBarView(
                  children: [
                    if (personalSubstitute)
                      SmartRefresher(
                        controller: _refreshController,
                        onRefresh: () => reload(fromPullToRefresh: true),
                        child: GeneralBlueprint(
                          list: myListToday,
                        ),
                      ),
                    if (personalSubstitute)
                      SmartRefresher(
                        controller: _refreshController,
                        onRefresh: () => reload(fromPullToRefresh: true),
                        child: GeneralBlueprint(
                          list: myListTomorrow,
                        ),
                      ),
                    SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () => reload(fromPullToRefresh: true),
                      child: GeneralBlueprint(
                        list: listToday,
                      ),
                    ),
                    SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () => reload(fromPullToRefresh: true),
                      child: GeneralBlueprint(
                        list: listTomorrow,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}

import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/models/substituteModel.dart';
import 'package:Vertretung/otherWidgets/myTab.dart' as myTab;
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/substitute/substituteLogic.dart';
import 'package:Vertretung/substitute/substitutePullToRefresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class SubstitutePage extends StatefulWidget {
  @override
  String toStringShort() {
    return "SubstitutePage";
  }

  @override
  SubstitutePageState createState() => SubstitutePageState();
}

class SubstitutePageState extends State<SubstitutePage>
    with TickerProviderStateMixin {
  CloudDatabase cd = CloudDatabase();
  SharedPref sharedPref = SharedPref();

  ///if the user selected personal substitute(use also subjects in filter)
  bool personalSubstitute = false;
  bool finishedLoading = false;
  bool loadingSuccess = true;

  ///The last change of the substitute
  String lastChange = "Loading";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //initialize these list, because to load subjects from localDatabase takes time, and the UI have to be build
  List<SubstituteModel> myListToday = [];
  List<SubstituteModel> listToday = [];
  List<SubstituteModel> myListTomorrow = [];
  List<SubstituteModel> listTomorrow = [];

  Future<void> reloadAll({bool fromPullToRefresh = false}) async {
    SnackBar snack = SnackBar(
      content: Text("Es werden alte Daten verwendet."),
      duration: Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Ausblenden",
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
          loadingSuccess = true; // make snackbar able to reshow
        },
      ),
    );
    List<dynamic> dataResult =
        await SubstituteLogic().getData(); //load the data from dsb mobile

    if (dataResult.isEmpty) {
      if (loadingSuccess) Scaffold.of(context).showSnackBar(snack);
      loadingSuccess = false;
      String newLastChange = await sharedPref.getString(Names.lastChange);
      List<String> oldRawSubstituteToday =
          await sharedPref.getStringList(Names.substituteToday);
      List<String> oldRawSubstituteTomorrow =
          await sharedPref.getStringList(Names.substituteTomorrow);
      setState(() {
        lastChange = newLastChange;
      });
      context.read<UserData>().rawSubstituteToday = oldRawSubstituteToday;
      context.read<UserData>().rawSubstituteTomorrow = oldRawSubstituteTomorrow;
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      setState(() {
        lastChange = dataResult[0];
      });
      context.read<UserData>().rawSubstituteToday = dataResult[1];
      context.read<UserData>().rawSubstituteTomorrow = dataResult[2];
      await sharedPref.setString(Names.lastChange, lastChange);
      await sharedPref.setStringList(Names.substituteToday, dataResult[1]);
      await sharedPref.setStringList(Names.substituteTomorrow, dataResult[2]);
    }
    setState(() {
      finishedLoading = true;
    });
    if (fromPullToRefresh) _refreshController.refreshCompleted();
  }

  void reloadFilteredSubstitute(
      String schoolClass,
      List<String> subjects,
      List<String> subjectsNot,
      List<String> rawSubstituteToday,
      List<String> rawSubstituteTomorrow) {
    Filter filterToday = Filter(schoolClass, rawSubstituteToday);
    Filter filterTomorrow = Filter(schoolClass, rawSubstituteTomorrow);
    List<dynamic> tempList = (personalSubstitute ? myListToday : listToday);
    setState(() {
      myListToday = filterToday.checkForSubjects(subjects, subjectsNot);
      listToday = filterToday.checkForSchoolClass();
      myListTomorrow = filterTomorrow.checkForSubjects(subjects, subjectsNot);
      listTomorrow = filterTomorrow.checkForSchoolClass();
    });
    if (tempList.toString() !=
        (personalSubstitute ? myListToday : listToday)
            .toString()) //used to decrease Firestore writes.
      cd.updateLastNotification(personalSubstitute ? myListToday : listToday);
  }

  @override
  void initState() {
    reloadAll(fromPullToRefresh: false);
    context.read<UserData>().addListener(() {
      if (!mounted) return;
      UserData provider = context.read<UserData>();
      reloadFilteredSubstitute(
          provider.schoolClass,
          provider.subjects,
          provider.subjectsNot,
          provider.rawSubstituteToday,
          provider.rawSubstituteTomorrow);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    UserData provider = Provider.of<UserData>(context);
    personalSubstitute = provider.personalSubstitute;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: personalSubstitute ? 4 : 2,
      key: Key(personalSubstitute ? "On" : "Off"),
      //key is needed because otherwise the tab length would not be updated
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title:
                Text("$lastChange  ${SubstituteLogic().getWeekNumber()}. KW"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.open_in_browser),
                onPressed: () {
                  int index = DefaultTabController.of(context).index;
                  if (personalSubstitute) {
                    if (index % 2 == 0)
                      launch(Names.substituteLinkToday);
                    else
                      launch(Names.substituteLinkTomorrow);
                  } else {
                    if (index == 0)
                      launch(Names.substituteLinkToday);
                    else
                      launch(Names.substituteLinkTomorrow);
                  }
                },
              ),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () async {
                    await Navigator.pushNamed(context, Names.settingsPage);
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
                      SubstitutePullToRefresh(
                        key: MyKeys.firstTab,
                        list: myListToday,
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        isNotUpdated: myListToday.isEmpty &&
                            lastChange.substring(7) == "00:09",
                      ),
                    if (personalSubstitute)
                      SubstitutePullToRefresh(
                        key: MyKeys.secondTab,
                        list: myListTomorrow,
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        isNotUpdated: myListTomorrow.isEmpty &&
                            lastChange.substring(7) == "00:09",
                      ),
                    SubstitutePullToRefresh(
                      key: MyKeys.thirdTab,
                      list: listToday,
                      controller: _refreshController,
                      reload: () => reloadAll(fromPullToRefresh: true),
                      isNotUpdated: listToday.isEmpty &&
                          lastChange.substring(7) == "00:09",
                    ),
                    SubstitutePullToRefresh(
                      key: MyKeys.fourthTab,
                      list: listTomorrow,
                      controller: _refreshController,
                      reload: () => reloadAll(fromPullToRefresh: true),
                      isNotUpdated: listTomorrow.isEmpty &&
                          lastChange.substring(7) == "00:09",
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        );
      }),
    );
  }
}

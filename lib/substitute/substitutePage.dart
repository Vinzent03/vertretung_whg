import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/substitute/substituteLogic.dart';
import 'package:Vertretung/otherWidgets/substituteList.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:Vertretung/otherWidgets/myTab.dart' as myTab;
import 'package:url_launcher/url_launcher.dart';

class SubstitutePage extends StatefulWidget {
  final Function reloadFriendsSubstitute;
  final Function updateFriendFeature;
  SubstitutePage(
      {Key key, this.reloadFriendsSubstitute, this.updateFriendFeature})
      : super(key: key);
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
  List<dynamic> myListToday = [];
  List<dynamic> listToday = [];
  List<dynamic> myListTomorrow = [];
  List<dynamic> listTomorrow = [];

  List<String> rawListToday = [];
  List<String> rawListTomorrow = [];
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
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      setState(() {
        lastChange = dataResult[0];
        rawListToday = dataResult[1];
        rawListTomorrow = dataResult[2];
      });
      await sharedPref.setString(Names.lastChange, lastChange);
      await sharedPref.setStringList(Names.substituteToday, rawListToday);
      await sharedPref.setStringList(Names.substituteTomorrow, rawListTomorrow);
    }
    await reloadFilteredSubstitute();
    finishedLoading = true;
    if (fromPullToRefresh) _refreshController.refreshCompleted();
    widget.reloadFriendsSubstitute();
  }

  void reloadSettings() {
    sharedPref.getBool(Names.personalSubstitute).then((onValue) {
      setState(() {
        personalSubstitute = onValue;
      });
    });
  }

  Future<void> reloadFilteredSubstitute() async {
    reloadSettings();
    String schoolClass = await sharedPref.getString(Names.schoolClass);
    List<String> subjectsList = await sharedPref.getStringList(Names.subjects);
    List<String> subjectsNotList =
        await sharedPref.getStringList(Names.subjectsNot);
    List<String> rawSubstituteToday =
        await sharedPref.getStringList(Names.substituteToday);
    List<String> rawSubstituteListTomorrow =
        await sharedPref.getStringList(Names.substituteTomorrow);
    String newLastChange = await sharedPref.getString(Names.lastChange);

    Filter filterToday = Filter(schoolClass, rawSubstituteToday);
    Filter filterTomorrow = Filter(schoolClass, rawSubstituteListTomorrow);
    List<dynamic> tempList = (personalSubstitute ? myListToday : listToday);
    setState(() {
      if (mounted) {
        myListToday =
            filterToday.checkForSubjects(subjectsList, subjectsNotList);
        listToday = filterToday.checkForSchoolClass();
        myListTomorrow =
            filterTomorrow.checkForSubjects(subjectsList, subjectsNotList);
        listTomorrow = filterTomorrow.checkForSchoolClass();
        lastChange = newLastChange;
      }
    });
    if (tempList.toString() !=
        (personalSubstitute ? myListToday : listToday)
            .toString()) //used to decrease Firestore writes.
      cd.updateLastNotification(personalSubstitute ? myListToday : listToday);
  }

  @override
  void initState() {
    reloadSettings();
    reloadAll();
    super.initState();
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
                    if (AuthService().getUserId() != null)
                      reloadFilteredSubstitute();
                    widget.updateFriendFeature();
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
                      SubstituteList(
                        key: MyKeys.firstTab,
                        list: myListToday,
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        isNotUpdated: myListToday.isEmpty &&
                            lastChange.substring(7) == "00:09",
                      ),
                    if (personalSubstitute)
                      SubstituteList(
                        key: MyKeys.secondTab,
                        list: myListTomorrow,
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        isNotUpdated: myListTomorrow.isEmpty &&
                            lastChange.substring(7) == "00:09",
                      ),
                    SubstituteList(
                      key: MyKeys.thirdTab,
                      list: listToday,
                      controller: _refreshController,
                      reload: () => reloadAll(fromPullToRefresh: true),
                      isNotUpdated: listToday.isEmpty &&
                          lastChange.substring(7) == "00:09",
                    ),
                    SubstituteList(
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

import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/otherWidgets/my_tab.dart' as myTab;
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/substitute/substitute_logic.dart';
import 'package:Vertretung/substitute/substitute_pull_to_refresh.dart';
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
  _SubstitutePageState createState() => _SubstitutePageState();
}

class _SubstitutePageState extends State<SubstitutePage>
    with TickerProviderStateMixin {
  CloudDatabase cd = CloudDatabase();

  ///if the user selected personal substitute(use also subjects in filter)
  bool personalSubstitute = false;
  bool finishedLoading = false;
  bool loadingSuccess = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
      String newLastChange = await SharedPref.getString(Names.lastChange);
      List<String> oldRawSubstituteToday =
          await SharedPref.getStringList(Names.substituteToday);
      List<String> oldRawSubstituteTomorrow =
          await SharedPref.getStringList(Names.substituteTomorrow);
      context.read<UserData>().rawSubstituteToday = oldRawSubstituteToday;
      context.read<UserData>().rawSubstituteTomorrow = oldRawSubstituteTomorrow;
      context.read<UserData>().lastChange = newLastChange;
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      context.read<UserData>().lastChange = dataResult[0];
      context.read<UserData>().rawSubstituteToday = dataResult[1];
      context.read<UserData>().rawSubstituteTomorrow = dataResult[2];

      _updateLastNotification(context.read<UserData>());
    }
    setState(() {
      finishedLoading = true;
    });
    if (fromPullToRefresh) _refreshController.refreshCompleted();
  }

  void _updateLastNotification(UserData provider) {
    List<SubstituteModel> myListToday = Filter.checkPersonalSubstitute(
      provider.schoolClass,
      provider.rawSubstituteToday,
      provider.subjects,
      provider.subjectsNot,
    );
    List<SubstituteModel> listToday = Filter.checkForSchoolClass(
      provider.schoolClass,
      provider.rawSubstituteToday,
    );
    cd.updateLastNotification(personalSubstitute ? myListToday : listToday);
  }

  @override
  void initState() {
    reloadAll(fromPullToRefresh: false);
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
            title: Text(
                "${context.watch<UserData>().lastChange}  ${SubstituteLogic().getWeekNumber()}. KW"),
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
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        list: Filter.checkPersonalSubstitute(
                          context.watch<UserData>().schoolClass,
                          context.watch<UserData>().rawSubstituteToday,
                          context.watch<UserData>().subjects,
                          context.watch<UserData>().subjectsNot,
                        ),
                      ),
                    if (personalSubstitute)
                      SubstitutePullToRefresh(
                        key: MyKeys.secondTab,
                        controller: _refreshController,
                        reload: () => reloadAll(fromPullToRefresh: true),
                        list: Filter.checkPersonalSubstitute(
                          context.watch<UserData>().schoolClass,
                          context.watch<UserData>().rawSubstituteTomorrow,
                          context.watch<UserData>().subjects,
                          context.watch<UserData>().subjectsNot,
                        ),
                      ),
                    SubstitutePullToRefresh(
                      key: MyKeys.thirdTab,
                      controller: _refreshController,
                      reload: () => reloadAll(fromPullToRefresh: true),
                      list: Filter.checkForSchoolClass(
                        context.watch<UserData>().schoolClass,
                        context.watch<UserData>().rawSubstituteToday,
                      ),
                    ),
                    SubstitutePullToRefresh(
                      key: MyKeys.fourthTab,
                      controller: _refreshController,
                      reload: () => reloadAll(fromPullToRefresh: true),
                      list: Filter.checkForSchoolClass(
                        context.watch<UserData>().schoolClass,
                        context.watch<UserData>().rawSubstituteTomorrow,
                      ),
                    )
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

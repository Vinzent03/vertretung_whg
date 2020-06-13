import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/vertretung/FunctionsForVertretung.dart';
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
  bool faecherOn = false; //if personalisierte Vertretung is enabled
  bool finishedLoading = false;
  bool loadingSuccess = true;

  String change = "Loading"; // The last tine the data on dsb mobile changed
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //initialize these list, because to load faecher from localDatabase takes time, and the UI have to be build
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
  List<Widget> myTabViews;
  List<Widget> myTabViewsFaecherOn;
  List<Widget> myTabs;
  List<Widget> myTabsFaecherOn;

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
    getter.setStringList(Names.lessonsToday, rawListToday);
    getter.setStringList(Names.lessonsTomorrow, rawListTomorrow);
    getter.getBool(Names.faecherOn).then((onValue) {
      setState(() {
        faecherOn = onValue;
      });
    });

    List<dynamic> dataResult = await FunctionsForVertretung()
        .getData(); //load the data from dsb mobile

    if (fromPullToRefresh) _refreshController.refreshCompleted();
    finishedLoading = true;
    if (dataResult.isEmpty) {
      if (loadingSuccess) Scaffold.of(context).showSnackBar(snack);
      loadingSuccess = false;
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      setState(() {
        change = dataResult[0];
        //rawListToday = dataResult[1];
        //rawListTomorrow = dataResult[2];
      });
    }

    String stufe = await LocalDatabase().getString(Names.stufe);
    Filter filter = Filter(stufe);
    List<dynamic> allMyListToday;
    List<dynamic> allListToday;
    List<dynamic> allMyListTomorrow;
    List<dynamic> allListTomorrow;

    List<String> faecherList =
        await LocalDatabase().getStringList(Names.faecherList);
    List<String> faecherNotList =
        await LocalDatabase().getStringList(Names.faecherNotList);

    allMyListToday = await filter.checkerFaecher(
        Names.lessonsToday, faecherList, faecherNotList);
    allListToday = await filter.checker(Names.lessonsToday);
    allMyListTomorrow = await filter.checkerFaecher(
        Names.lessonsTomorrow, faecherList, faecherNotList);
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

  /*void linkGenerate() async {
    DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://vertretung.page.link/friendrequest",
      link: Uri.parse("https://vertretung.page.link/"),
      androidParameters: AndroidParameters(
        packageName: 'com.whg.vertretung',
      ),
    );
    ShortDynamicLink link = await parameters.buildShortLink();
    print(link.shortUrl);
  }*/

  @override
  void initState() {
    /*linkGenerate();
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhll");
            print(deepLink.data.toString());
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );*/

    reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ProviderData>(context).getVertretungReload()) {
      print("will reloaden");
      reload().then((value) => Provider.of<ProviderData>(context, listen: false)
          .setVertretungReload(false));
    }

    final theme = Provider.of<ProviderData>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      home: DefaultTabController(
        length: faecherOn ? 4 : 2,
        key: Key(faecherOn ? "On" : "Off"),
        //key is needed because otherwise the tab length would not be updated
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                "$change  Woche: ${FunctionsForVertretung().getWeekNumber()}"),
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
                if (faecherOn)
                  myTab.MyTab(
                    // Extra tab class, because the default tab height is too high, so I cloned the class
                    icon: Icon(
                      Icons.person,
                    ),
                    iconMargin: EdgeInsets.all(0),
                    text: "Heute",
                  ),
                if (faecherOn)
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
                    if (faecherOn)
                      SmartRefresher(
                        controller: _refreshController,
                        onRefresh: () => reload(fromPullToRefresh: true),
                        child: GeneralBlueprint(
                          list: myListToday,
                        ),
                      ),
                    if (faecherOn)
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

import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'editNewsPage.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

enum actions { delete, edit }

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  List<dynamic> newsList = [];
  bool isAdmin = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AnimationController _controller;

  Animation<double> _animation;

  @override
  void initState() {
    AuthService().getAdminStatus().then((value) => setState(() {
          isAdmin = value;
        }));
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this, value: 0.1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _controller.forward();
    reload();
    super.initState();
  }

  void reload() async {
    CloudDatabase manager = CloudDatabase();
    await manager.getNews().then((onValue) {
      setState(() {
        newsList = onValue;
      });
      //LocalDatabase().setString(Names.newsAnzahl, newsList.length.toString());  //not used in the moment
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ProviderData>(context).getAnimation()) {
      _controller.reset();
      _controller.forward().then((value) =>
          Provider.of<ProviderData>(context, listen: false)
              .setAnimation(false));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Nachrichten"),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: reload,
        child: ScaleTransition(
          scale: _animation,
          child: ListView.builder(
            physics: ScrollPhysics(),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text(newsList[index]["title"]),
                  subtitle: newsList[index]["text"] != ""
                      ? Text(newsList[index]["text"])
                      : null,
                  trailing: isAdmin
                      ? PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          onSelected: (selected) async {
                            if ((await Connectivity().checkConnectivity()) ==
                                ConnectivityResult.none) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text("Keine Verbindung"),
                              ));
                              return;
                            }
                            var result;
                            if (selected == actions.delete) {
                              ProgressDialog pr = ProgressDialog(context,
                                  type: ProgressDialogType.Normal,
                                  isDismissible: false,
                                  showLogs: false);
                              pr.show();

                              result = await Functions().deleteNews(index);
                              pr.hide();

                              switch (result["code"]) {
                                case "Successful":
                                  reload();
                                  break;
                                case "ERROR_NO_ADMIN":
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Du bist kein Admin, bitte melde dich ab und dann wieder an. Wenn du denktst du solltest Admin sein, melde dich bitte bei mir."),
                                      duration: Duration(minutes: 1),
                                    ),
                                  );
                                  break;
                              }
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditNewsPage(),
                                  settings: RouteSettings(
                                    arguments: NewsTransmitter(true,
                                        text: newsList[index]["text"],
                                        title: newsList[index]["title"]),
                                  ),
                                ),
                              );
                              reload();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: actions.delete,
                                child: Text("löschen"),
                              ),
                              PopupMenuItem(
                                value: actions.edit,
                                child: Text("bearbeiten"),
                              ),
                            ];
                          },
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: "filter",
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNewsPage(),
                    settings: RouteSettings(
                      arguments: NewsTransmitter(false),
                    ),
                  ),
                ).then((value) => _refreshController.requestRefresh());
              },
            )
          : null,
    );
  }
}

class NewsTransmitter {
  final String text;
  final String title;
  final bool isEditAction;
  final int index;
  NewsTransmitter(this.isEditAction, {this.text, this.title, this.index});
}

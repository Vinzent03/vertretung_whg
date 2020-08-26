import 'dart:math';

import 'package:Vertretung/news/detailsPage.dart';
import 'package:Vertretung/news/newsTransmitter.dart';
import 'package:Vertretung/otherWidgets/OpenContainerWrapper.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'editNewsPage.dart';
import 'newsLogic.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key key}) : super(key: key);
  @override
  String toStringShort() {
    return "NewsPage";
  }

  @override
  NewsPageState createState() => NewsPageState();
}

enum actions { delete, edit }

class NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  List<dynamic> newsList = [];
  bool isAdmin = false;
  bool finishedLoading = false;
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
    reload();
    super.initState();
  }

  void reload() async {
    CloudDatabase cloudDatabase = CloudDatabase();
    try {
      List<dynamic> newNews = await cloudDatabase.getNews();
      setState(() {
        newsList = newNews;
      });
      finishedLoading = true;
      _controller.forward();
      _refreshController.refreshCompleted();
    } catch (e) {
      finishedLoading = true;
      Flushbar(
        message: "Es ist ein Fehler beim Laden der Nachrichten aufgetreten.",
        duration: Duration(seconds: 3),
      )..show(context);
      _refreshController.refreshFailed();
    }
  }

  void reAnimate() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nachrichten"),
      ),
      body: finishedLoading
          ? SmartRefresher(
              controller: _refreshController,
              onRefresh: reload,
              child: ScaleTransition(
                scale: _animation,
                child: ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      elevation: 3,
                      child: OpenContainerWrapper(
                        openBuilder: (context, action) => DetailsPage(
                          index: index,
                          text: newsList[index]["text"],
                          title: newsList[index]["title"],
                        ),
                        closedBuilder: (context, action) =>
                            buildListItem(index, action),
                        onClosed: (data) => data != null
                            ? _refreshController.requestRefresh()
                            : null,
                      ),
                    );
                  },
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: "filter",
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNewsPage(NewsTransmitter(false)),
                  ),
                ).then((value) => _refreshController.requestRefresh());
              },
            )
          : null,
    );
  }

  Widget buildListItem(int index, Function action) {
    return ListTile(
      title: Text(newsList[index]["title"]),
      //show only the first 100 chars as subtitle, to see more click on the ListTile
      subtitle: newsList[index]["text"] != ""
          ? Text(newsList[index]["text"].toString().substring(
              0, min(newsList[index]["text"].toString().length, 100)))
          : null,
      onTap: () async {
        action();
        //check if the page have to be reloaded(needed when deleted or edited)
      },
      trailing: isAdmin
          ? PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (selected) async {
                if (selected == actions.delete) {
                  if (await NewsLogic().deleteNews(context, index))
                    _refreshController.requestRefresh();
                } else {
                  await NewsLogic().openEditNewsPage(
                    context,
                    newsList[index]["text"],
                    newsList[index]["title"],
                    index,
                  );
                  _refreshController.requestRefresh();
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
    );
  }
}

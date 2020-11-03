import 'package:Vertretung/models/newsModel.dart';
import 'package:Vertretung/news/detailsPage.dart';
import 'package:Vertretung/news/newsTransmitter.dart';
import 'package:Vertretung/otherWidgets/OpenContainerWrapper.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  bool isAdmin = false;
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
    super.initState();
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
      body: StreamBuilder<List<NewsModel>>(
          stream: CloudDatabase().getNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            else if (snapshot.hasError)
              return Center(
                child: Text(
                    "Ein Fehler ist aufgetreten:" + snapshot.error.toString()),
              );
              return ScaleTransition(
                scale: _animation,
                child: ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      elevation: 3,
                      child: OpenContainerWrapper(
                        openBuilder: (context, action) => DetailsPage(
                          index: index,
                          news: snapshot.data[index],
                        ),
                        closedBuilder: (context, action) =>
                            buildListItem(snapshot.data[index], index, action),
                      ),
                    );
                  },
                ),
              );
          }),
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
                );
              },
            )
          : null,
    );
  }

  ///show only the first 100 chars as subtitle, to see more click on the ListTile
  Widget buildSubtitle(NewsModel item) {
    final text = item.text;
    final toManyLines = '\n'.allMatches(text).length >= 4;

    int fourthLine;
    String displayedText = text;

    if (toManyLines) {
      final firstNewLine = text.indexOf("\n") + 1;
      final secondNewLine = text.indexOf("\n", firstNewLine) + 1;
      final thirdNewLine = text.indexOf("\n", secondNewLine) + 1;
      fourthLine = text.indexOf("\n", thirdNewLine) + 1;
    }

    if (text.isEmpty) return null;
    if (toManyLines)
      displayedText = text.substring(0, fourthLine) + "...";
    else if (text.length > 100) displayedText = text.substring(0, 100) + "...";

    return Opacity(
      opacity: 0.5,
      child: MarkdownBody(
        data: displayedText,
        styleSheet: MarkdownStyleSheet(
            h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildListItem(NewsModel item, int index, Function action) {
    return ListTile(
      title: Text(
        item.title,
        style: TextStyle(fontSize: 18),
      ),
      subtitle: buildSubtitle(item),
      onTap: action,
      trailing: isAdmin
          ? PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (selected) {
                if (selected == actions.delete) {
                  NewsLogic().deleteNews(context, index);
                } else {
                  NewsLogic().openEditNewsPage(
                    context,
                    item,
                    index,
                  );
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

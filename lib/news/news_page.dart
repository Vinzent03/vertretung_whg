import 'package:Vertretung/models/news_model.dart';
import 'package:Vertretung/news/details_page.dart';
import 'package:Vertretung/news/news_transmitter.dart';
import 'package:Vertretung/otherWidgets/open_container_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'edit_news_page.dart';
import 'news_logic.dart';

enum actions { delete, edit }

class NewsPage extends StatelessWidget {
  final List<NewsModel> news;
  final bool isAdmin;
  const NewsPage({
    Key key,
    @required this.news,
    @required this.isAdmin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (news == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            physics: ScrollPhysics(),
            itemCount: news.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                elevation: 3,
                child: OpenContainerWrapper(
                  openBuilder: (context, action) => DetailsPage(
                    index: index,
                    news: news[index],
                  ),
                  closedBuilder: (context, action) =>
                      buildListItem(news[index], index, action, context),
                ),
              );
            },
          );
        }
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

  Widget buildListItem(
      NewsModel item, int index, Function action, BuildContext context) {
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
                  NewsLogic().deleteNews(context, item.id);
                } else {
                  NewsLogic().openEditNewsPage(
                    context,
                    item,
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

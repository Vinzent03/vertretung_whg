import 'package:Vertretung/models/newsModel.dart';
import 'package:Vertretung/news/newsLogic.dart';
import 'package:Vertretung/services/authService.dart';
import "package:flutter/material.dart";
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  final NewsModel news;
  final int index;
  DetailsPage({this.news, this.index});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isAdmin = false;
  @override
  void initState() {
    AuthService()
        .getAdminStatus()
        .then((value) => setState(() => isAdmin = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        actions: <Widget>[
          if (isAdmin)
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await NewsLogic()
                      .openEditNewsPage(context, widget.news, widget.index);
                  Navigator.pop(context);
                }),
          if (isAdmin)
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  if (await NewsLogic().deleteNews(context, widget.index))
                    Navigator.pop(context);
                }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.news.title,
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 10),
              Text(
                "Zuletzt bearbeitet: " + widget.news.lastEdited,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Divider(
                thickness: 4,
              ),
              SizedBox(height: 10),
              MarkdownBody(
                data: widget.news.text,
                onTapLink: (text, href, title) => launch(href),
                shrinkWrap: true,
                selectable: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}

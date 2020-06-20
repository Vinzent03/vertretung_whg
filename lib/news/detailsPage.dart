import 'package:Vertretung/news/newsLogic.dart';
import "package:flutter/material.dart";
import "package:flutter_linkify/flutter_linkify.dart";
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  final title;
  final text;
  final index;
  DetailsPage({this.text, this.title, this.index});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await NewsLogic().openEditNewsPage(
                    context, widget.text, widget.title, widget.index);
                Navigator.pop(context, true);
              }),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await NewsLogic().deleteNews(context, widget.index);
                Navigator.pop(context, true);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Linkify(
                onOpen: (link) => launch(link.url),
                text: widget.title,
                style: TextStyle(fontSize: 22),
              ),
            ),
            Divider(
              thickness: 4,
              indent: 8,
              endIndent: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Linkify(
                onOpen: (link) => launch(link.url),
                text: widget.text,
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsList = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  @override
  void initState() {
    reload();
    super.initState();
  }
  void reload()async{
    CloudDatabase manager = CloudDatabase();
    await manager.getNews().then((onValue) {
      setState(() {
        newsList = onValue;
      });
      LocalDatabase().setString(Names.newsAnzahl, newsList.length.toString());
    });
    _refreshController.refreshCompleted();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: reload,
        child: ListView.builder(
          physics: ScrollPhysics(),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(newsList[index]["title"]),
                subtitle: Text(newsList[index]["text"]),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsList = [];
  @override
  void initState() {
    
    CloudDatabase manager = CloudDatabase();

      manager.getNews().then((onValue) {
        setState(() {
         newsList = onValue;
        });
        LocalDatabase().setString(Names.newsAnzahl, newsList.length.toString());
      });   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
      ),
      body: ListView.builder(
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
    );
  }
}

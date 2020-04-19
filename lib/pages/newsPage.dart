import 'package:Vertretung/logic/getter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/manager.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsList = [];
  @override
  void initState() {
    
    Manager manager = Manager();

      manager.getNews().then((onValue) {
        setState(() {
         newsList = onValue;
        });
        Getter().setString(Names.newsAnzahl, newsList.length.toString());
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

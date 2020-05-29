import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/theme.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  List<dynamic> newsList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AnimationController _controller;

  Animation<double> _animation;

  @override
  void initState() {
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
      LocalDatabase().setString(Names.newsAnzahl, newsList.length.toString());
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
        if (Provider.of<ThemeChanger>(context).getAnimation()) {
      _controller.reset();
      _controller.forward().then((value) => Provider.of<ThemeChanger>(context, listen: false)
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
                child: ListTile(
                  title: Text(newsList[index]["title"]),
                  subtitle: Text(newsList[index]["text"]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:Vertretung/friends/friendsPage.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/substitute//substitutePage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget usedPage = VertretungsPage();

  int currentIndex = 0;

  @override
  void initState() {
    Future<void> showUpdateDialog(context) async {
      CloudDatabase cd = CloudDatabase();

      String updateSituation = await cd.getUpdate();
      bool force = false;
      bool updateAvailable = false;
      String link;
      List<dynamic> message;
      // ignore: missing_return
      if (updateSituation == "updateAvaible") {
        updateAvailable = true;
        force = false;
      } else if (updateSituation == "forceUpdate") {
        updateAvailable = true;
        force = true;
      }
      link = await cd.getUpdateLink();
      message = await cd.getUpdateMessage();
      if (updateAvailable) {
        if (force)
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return WillPopScope(
                onWillPop: () {},
                child: AlertDialog(
                  title: Text(message[0]),
                  content: Text(message[1]),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Update"),
                      onPressed: () => launch(link),
                    )
                  ],
                ),
              );
            },
          );
        else
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: Text(message[0]),
                content: Text(message[1]),
                actions: <Widget>[
                  FlatButton(
                    child: Text("abbrechen"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  RaisedButton(
                    child: Text("Update"),
                    onPressed: () => launch(link),
                  )
                ],
              );
            },
          );
      }
    }

    super.initState();
  }

  final List<Widget> pages = [
    VertretungsPage(),
    Friends(),
    NewsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //by this Indexed Stack, the pages are not reloaded every time
      body: IndexedStack(
        children: pages,
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        backgroundColor: Provider.of<ProviderData>(context).getIsDark()
            ? Colors.black
            : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            title: Text("Vertretung"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text("Freunde"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: Text("Nachrichten"),
          ),
        ],
        onTap: (index) {
          if (index != currentIndex)
            Provider.of<ProviderData>(context, listen: false)
                .setAnimation(true);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

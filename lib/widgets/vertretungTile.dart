import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:share/share.dart';
import 'package:Vertretung/logic/theme.dart';
import 'package:provider/provider.dart';

class VertretungTile extends StatelessWidget {
  final List<List<String>> list;
  List<String> faecher;
  List<String> names;
  final bool dense;
  final int index;

  VertretungTile(
      {Key key, @required this.list, @required this.index, this.dense})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    faecher = list[0];
    names = list[1];
    //bool isDark = Provider.of<ThemeChanger>(context).getIsDark();
    return Card(
      color: Colors.blue[700],
      child: ListTile(
        dense: dense,
        onTap: () {},
        title: Text(
          faecher[index],
          style: TextStyle(fontSize: 16),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            names[index],
            style: TextStyle(fontSize: 18),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            FirebaseAnalytics analytics = FirebaseAnalytics();
            analytics.logShare(
                contentType: "geshared",
                itemId: index.toString(),
                method: "gedrückt halten");
            Share.share("Wir haben Vertretung und zwar: ${faecher[index]}");
          },
        ),
        onLongPress: () {
          FirebaseAnalytics analytics = FirebaseAnalytics();
          analytics.logShare(
              contentType: "geshared",
              itemId: index.toString(),
              method: "gedrückt halten");
          Share.share("Wir haben Vertretung und zwar: ${faecher[index]}");
        },
      ),
    );
  }
}

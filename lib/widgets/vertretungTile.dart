import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:share/share.dart';

class VertretungTile extends StatelessWidget {
  String faecher;
  String names;

  VertretungTile(
      {Key key, @required this.faecher,@required this.names,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //bool isDark = Provider.of<ThemeChanger>(context).getIsDark();
    return Card(
      color: Colors.blue[700],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: ListTile(
        onTap: () {},
        title: Text(
          faecher,
          style: TextStyle(fontSize: 16),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            names,
            style: TextStyle(fontSize: 18),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            FirebaseAnalytics analytics = FirebaseAnalytics();
            analytics.logShare(
                contentType: "geshared",
                method: "gedrückt halten", itemId: "42");
            Share.share("Wir haben Vertretung und zwar: $faecher");
          },
        ),
        onLongPress: () {
          FirebaseAnalytics analytics = FirebaseAnalytics();
          analytics.logShare(
              contentType: "geshared",
              itemId: "42",
              method: "gedrückt halten");
          Share.share("Wir haben Vertretung und zwar: $faecher");
        },
      ),
    );
  }
}

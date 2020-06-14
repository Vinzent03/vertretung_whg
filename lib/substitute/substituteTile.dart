import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:share/share.dart';

class VertretungTile extends StatelessWidget {
  final String title;
  final String subjectPrefix;
  final String names;

  VertretungTile({
    Key key,
    @required this.title,
    @required this.subjectPrefix,
    this.names,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Card(
        color: Colors.blue[700],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: ListTile(
          onTap: () {},
          title: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              subjectPrefix,
              style: TextStyle(fontSize: 18),
            ),
          ),
          trailing: names == null
              ? //dont show the share button on the friendspage
              IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    FirebaseAnalytics analytics = FirebaseAnalytics();
                    analytics.logShare(
                        contentType: "geshared",
                        method: "gedrückt halten",
                        itemId: "42");
                    Share.share("Wir haben Vertretung und zwar: $title");
                  },
                )
              : null,
          subtitle: names != null ? Text(names) : null,
          onLongPress: () {
            FirebaseAnalytics analytics = FirebaseAnalytics();
            analytics.logShare(
                contentType: "geshared",
                itemId: "42",
                method: "gedrückt halten");
            Share.share("Wir haben Vertretung und zwar: $title");
          },
        ),
      ),
    );
  }
}

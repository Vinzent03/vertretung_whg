import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:share/share.dart';

class SubstituteListTile extends StatelessWidget {
  final String title;
  final String subjectPrefix;
  final String names;

  SubstituteListTile({
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
            child: subjectPrefix.isEmpty
                ? Text(
                    "?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )
                : Text(
                    subjectPrefix,
                    style: TextStyle(fontSize: 18),
                  ),
          ),
          //dont show the share button on the friendsPage
          trailing: names != null
              ? null
              : IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    FirebaseAnalytics analytics = FirebaseAnalytics();
                    analytics.logShare(
                      contentType:
                          names == null ? "SubstitutePage" : "FriendsPage",
                      method: "hold",
                      itemId: subjectPrefix,
                    );
                    Share.share("Wir haben Vertretung und zwar: $title");
                  },
                ),
          subtitle: names != null ? Text(names) : null,
          onLongPress: names != null
              ? null
              : () {
                  FirebaseAnalytics analytics = FirebaseAnalytics();
                  analytics.logShare(
                    contentType:
                        names == null ? "SubstitutePage" : "FriendsPage",
                    method: "button pressed",
                    itemId: subjectPrefix,
                  );
                  Share.share("Wir haben Vertretung und zwar: $title");
                },
        ),
      ),
    );
  }
}

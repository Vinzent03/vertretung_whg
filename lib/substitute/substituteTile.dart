import 'package:Vertretung/models/substituteModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:share/share.dart';

class SubstituteListTile extends StatelessWidget {
  final SubstituteModel substitute;

  SubstituteListTile(
    this.substitute, {
    Key key,
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
            substitute.title,
            style: TextStyle(fontSize: 16),
          ),
          leading: CircleAvatar(
              backgroundColor: Colors.white, child: buildCircleAvatar()),
          //dont show the share button on the friendsPage
          trailing: substitute.names != null
              ? null
              : IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    FirebaseAnalytics analytics = FirebaseAnalytics();
                    analytics.logShare(
                      contentType: substitute.names == null
                          ? "SubstitutePage"
                          : "FriendsPage",
                      method: "hold",
                      itemId: substitute.subjectPrefix,
                    );
                    Share.share(
                        "Wir haben Vertretung und zwar: ${substitute.title}");
                  },
                ),
          subtitle: substitute.names != null ? Text(substitute.names) : null,
          onLongPress: substitute.names != null
              ? null
              : () {
                  FirebaseAnalytics analytics = FirebaseAnalytics();
                  analytics.logShare(
                    contentType: substitute.names == null
                        ? "SubstitutePage"
                        : "FriendsPage",
                    method: "button pressed",
                    itemId: substitute.subjectPrefix,
                  );
                  Share.share(
                      "Wir haben Vertretung und zwar: ${substitute.title}");
                },
        ),
      ),
    );
  }

  Widget buildCircleAvatar() {
    if (substitute.subjectPrefix.isEmpty)
      return Text(
        "?",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      );
    else if (substitute.title.contains("Freistunde"))
      return Icon(Icons.free_breakfast);
    else
      return Text(
        substitute.subjectPrefix,
        style: TextStyle(fontSize: 18),
      );
  }
}

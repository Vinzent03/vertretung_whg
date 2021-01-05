import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        elevation: 4,
        child: ListTile(
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
                  onPressed: () => share(context),
                ),
          subtitle: substitute.names != null ? Text(substitute.names) : null,
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

  share(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    analytics.logShare(
      contentType: substitute.names == null ? "SubstitutePage" : "FriendsPage",
      method: "button pressed",
      itemId: substitute.subjectPrefix,
    );
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(
          text: "Wir haben Vertretung und zwar: ${substitute.title}"));
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Text zur Zwischenablage hinzugefügt.",
        ),
        behavior: SnackBarBehavior.floating,
      ));
    }
    Share.share("Wir haben Vertretung und zwar: ${substitute.title}");
  }
}

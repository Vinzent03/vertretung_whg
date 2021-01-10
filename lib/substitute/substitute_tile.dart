import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class SubstituteListTile extends StatelessWidget {
  final SubstituteModel substitute;

  ///Wether to use a lighter background or not (only for dark mode important)
  final bool secondLevel;
  SubstituteListTile(
    this.substitute, [
    this.secondLevel = true,
  ]);

  @override
  Widget build(BuildContext context) {
    bool lightMode = Theme.of(context).brightness == Brightness.light;
    return Card(
      color: !lightMode && secondLevel
          ? Color.fromRGBO(45, 45, 45,
              1) //Following these rules for elevation: https://material.io/design/color/dark-theme.html#properties
          : null,
      child: ListTile(
        title: Text(
          substitute.title,
          style: TextStyle(fontSize: 16),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: buildCircleAvatar(context),
        ),
        //don't show the share button on the friendsPage
        trailing: substitute.names != null
            ? null
            : IconButton(
                icon: Icon(Icons.share),
                onPressed: () => share(context),
              ),
        subtitle: substitute.names != null
            ? Text(
                substitute.names,
              )
            : null,
      ),
    );
  }

  Widget buildCircleAvatar(BuildContext context) {
    if (substitute.subjectPrefix.isEmpty) {
      return Text(
        "?",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    } else if (substitute.title.contains("Freistunde")) {
      return Icon(
        Icons.free_breakfast,
        color: Colors.white,
      );
    } else {
      return Text(
        substitute.subjectPrefix,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Text zur Zwischenablage hinzugefügt.",
        ),
        behavior: SnackBarBehavior.floating,
      ));
    }
    Share.share("Wir haben Vertretung und zwar: ${substitute.title}");
  }
}

import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/otherWidgets/openContainerWrapper.dart';
import 'package:Vertretung/otherWidgets/schoolClassSelection.dart';
import 'package:Vertretung/otherWidgets/themeModeSelection.dart';
import 'package:Vertretung/provider/themeSettings.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/settings/freeLessonSelection/freeLessonSelection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import "package:wiredash/wiredash.dart";

import 'myLicensePage.dart';
import 'subjectsSelection/subjectsPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CloudDatabase manager = CloudDatabase();
  bool notificationOnChange = false;
  bool notificationOnFirstChange = false;
  bool personalSubstitute;
  bool friendsFeature;

  SharedPref sharedPref = SharedPref();

  deleteSubjectsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Möchtest Du deine bisher eingegeben Fächer löschen?"),
        actions: [
          RaisedButton(
            child: Text("Bestätigen"),
            onPressed: () async {
              await sharedPref.setStringList(Names.subjects, []);
              await sharedPref.setStringList(Names.subjectsNot, []);
              context.read<UserData>().subjects = [];
              context.read<UserData>().subjectsNot = [];

              CloudDatabase().updateSubjects();
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("Abbrechen"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<String> selectSchoolClassDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Bitte wähle Deine Stufe/Klasse"),
            content: SchoolClassSelection(),
            actions: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7))),
                child: Text("Bestätigen"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if ((await sharedPref.getStringList(Names.subjects))
                          .isNotEmpty ||
                      (await sharedPref.getStringList(Names.subjectsNot))
                          .isNotEmpty) {
                    await deleteSubjectsDialog();
                  }
                  updateUserdata();
                },
              ),
            ],
          );
        });
  }

  void updateUserdata() {
    manager.updateUserData(
      personalSubstitute: context.read<UserData>().personalSubstitute,
      schoolClass: context.read<UserData>().schoolClass,
      notificationOnChange: notificationOnChange,
      notificationOnFirstChange: notificationOnFirstChange,
    );
  }

  void loadSettings() async {
    bool pNotificationOnChange =
        await sharedPref.getBool(Names.notificationOnChange);
    bool pNotificationOnFirstChange =
        await sharedPref.getBool(Names.notificationOnFirstChange);
    setState(() {
      notificationOnChange = pNotificationOnChange;
      notificationOnFirstChange = pNotificationOnFirstChange;
    });
  }

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    friendsFeature = Provider.of<UserData>(context).friendsFeature;
    personalSubstitute = Provider.of<UserData>(context).personalSubstitute;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, Names.helpPage),
          ),
          if (!kIsWeb)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                Map<String, String> links =
                    await CloudDatabase().getUpdateLinks();
                Share.share(
                    "Hier ist der Download Link für die Vertretungsapp: ${links["download"]}");
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
                elevation: 3,
                color: Colors.blue[500],
                child: ListTile(
                  title: Text(
                    "Dein Account",
                  ),
                  leading: Icon(Icons.donut_large),
                  onTap: () => Navigator.pushNamed(context, Names.accountPage),
                )),
            Card(
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.school),
                  title: Text(
                    "Klasse/Stufe",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () => selectSchoolClassDialog(context),
                  trailing: FlatButton(
                    child: Text(
                      context.watch<UserData>().schoolClass,
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: () => selectSchoolClassDialog(context),
                  ),
                )),
            Card(
              elevation: 3,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text("Personalisierte Vertretung"),
                    value: personalSubstitute,
                    secondary: Icon(Icons.group),
                    onChanged: (bool b) {
                      sharedPref.setBool(Names.personalSubstitute, b);
                      context.read<UserData>().personalSubstitute = b;
                      updateUserdata();
                    },
                  ),
                  OpenContainerWrapper(
                    tappable: personalSubstitute,
                    openBuilder: (BuildContext context, VoidCallback _) =>
                        SubjectsPage(
                      isWhitelist: ["EF", "Q1", "Q2"]
                          .contains(context.watch<UserData>().schoolClass),
                    ),
                    closedBuilder: (context, action) => ListTile(
                      title: Text(["EF", "Q1", "Q2"]
                              .contains(context.watch<UserData>().schoolClass)
                          ? "Deine Fächer eingeben"
                          : "Fächer Deiner Mitschüler eingeben"),
                      enabled: personalSubstitute,
                      leading: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text(
                      "Freundes Funktion",
                      style: TextStyle(fontSize: 17),
                    ),
                    secondary: Icon(Icons.group),
                    value: friendsFeature,
                    onChanged: (bool b) {
                      sharedPref.setBool(Names.friendsFeature, b);
                      context.read<UserData>().friendsFeature = b;
                    },
                  ),
                  OpenContainerWrapper(
                    tappable: friendsFeature,
                    openBuilder: (BuildContext context, VoidCallback _) =>
                        FreeLessonSelection(),
                    closedBuilder: (context, action) => ListTile(
                      title: Text(
                        "Freistunden",
                        style: TextStyle(fontSize: 17),
                      ),
                      leading: Icon(Icons.free_breakfast),
                      enabled: friendsFeature,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: Column(
                children: <Widget>[
                  ThemeModeSelection(
                      context.watch<ThemeSettings>().getThemeMode()),
                  if (!kIsWeb)
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      value: notificationOnChange,
                      onChanged: (bool b) {
                        sharedPref.setBool(Names.notificationOnChange, b);
                        setState(() {
                          notificationOnChange = b;
                        });
                        updateUserdata();
                      },
                      title: Text(
                        "Benachrichtigung bei neuer Vertretung",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  if (!kIsWeb)
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      value: notificationOnFirstChange,
                      onChanged: (bool b) {
                        sharedPref.setBool(Names.notificationOnFirstChange, b);
                        setState(() {
                          notificationOnFirstChange = b;
                        });
                        updateUserdata();
                      },
                      title: Text(
                        "Benachrichtigung wenn der Plan zum ersten mal aktualisiert wird",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Über Uns"),
                    leading: Icon(Icons.info),
                    onTap: () => Navigator.pushNamed(context, Names.aboutPage),
                  ),
                  if (!kIsWeb)
                    ListTile(
                      leading: Icon(Icons.feedback),
                      title: Text("Feedback"),
                      onTap: () async {
                        Wiredash.of(context).setBuildProperties(
                            buildVersion: kIsWeb
                                ? "web"
                                : (await PackageInfo.fromPlatform()).version);
                        Wiredash.of(context).setUserProperties(
                            userId: AuthService().getUserId());
                        Wiredash.of(context).show();
                      },
                    ),
                  ListTile(
                    title: Text("Lizenzen"),
                    leading: Icon(Icons.library_books),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyLicensePage(),
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/otherWidgets/open_container_wrapper.dart';
import 'package:Vertretung/otherWidgets/school_class_selection.dart';
import 'package:Vertretung/otherWidgets/theme_mode_selection.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/settings/freeLessonSelection/free_lesson_selection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import "package:wiredash/wiredash.dart";

import 'my_license_page.dart';
import 'subjectsSelection/subjects_page.dart';

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
        await SharedPref.getBool(Names.notificationOnChange);
    bool pNotificationOnFirstChange =
        await SharedPref.getBool(Names.notificationOnFirstChange);
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
              color: Theme.of(context).primaryColor,
              child: ListTile(
                title: Text(
                  "Dein Account",
                  style: TextStyle(color: Colors.white),
                ),
                leading: Icon(
                  Icons.donut_large,
                  color: Colors.white,
                ),
                onTap: () => Navigator.pushNamed(context, Names.accountPage),
              ),
            ),
            Card(
              child: SchoolClassSelection(updateUserdata: updateUserdata),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text("Personalisierte Vertretung"),
                    value: personalSubstitute,
                    secondary: Icon(Icons.star),
                    onChanged: (bool b) {
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
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text(
                      "Freunde-Funktion",
                      style: TextStyle(fontSize: 17),
                    ),
                    secondary: Icon(Icons.group),
                    value: friendsFeature,
                    onChanged: (bool b) {
                      context.read<UserData>().friendsFeature = b;
                    },
                  ),
                  OpenContainerWrapper(
                    openBuilder: (BuildContext context, VoidCallback _) =>
                        FreeLessonSelection(),
                    closedBuilder: (context, action) => ListTile(
                      title: Text(
                        "Freistunden",
                        style: TextStyle(fontSize: 17),
                      ),
                      leading: Icon(Icons.free_breakfast),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ThemeModeSelection(
                      context.watch<ThemeSettings>().getThemeMode()),
                  if (!kIsWeb)
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      value: notificationOnChange,
                      onChanged: (bool b) {
                        SharedPref.setBool(Names.notificationOnChange, b);
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
                        SharedPref.setBool(Names.notificationOnFirstChange, b);
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
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Über Uns"),
                    leading: Icon(Icons.info),
                    onTap: () => Navigator.pushNamed(context, Names.aboutPage),
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback),
                    title: Text("Feedback"),
                    onTap: () async {
                      Wiredash.of(context).setBuildProperties(
                          buildVersion:
                              (await PackageInfo.fromPlatform()).version);
                      Wiredash.of(context)
                          .setUserProperties(userId: AuthService().getUserId());
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

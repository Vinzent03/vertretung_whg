import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:share/share.dart';
import 'package:Vertretung/otherWidgets/SchoolClassSelection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "package:wiredash/wiredash.dart";
import 'package:Vertretung/services/authService.dart';
import '../logic/sharedPref.dart';
import '../logic/names.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import 'subjectsPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CloudDatabase manager;
  bool dark = false;
  bool personalSubstitute = false;
  bool refresh = false;
  bool notification = false;
  bool friendsFeature = false;
  String schoolClass = "Nicht Geladen";
  List<String> subjectsList = [];
  List<String> subjectsNotList = [];

  SharedPref sharedPref = SharedPref();

  Future<String> createAlertDialog(
      BuildContext context, String situation, String message) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(message),
            content: StufenList(),
            actions: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7))),
                child: Text("bestätigen"),
                onPressed: () {
                  updateUserdata();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void updateUserdata() {
    print(subjectsList);
    manager.updateUserData(
      personalSubstitute: personalSubstitute,
      schoolClass: schoolClass,
      subjects: subjectsList,
      subjectsNot: subjectsNotList,
      notification: notification,
    );
  }

  @override
  void initState() {
    manager = CloudDatabase();
    bool pDark;
    bool pPersonalSubstitute;
    bool pNotification;
    bool pFriendsFeature;
    String pSchoolClass;
    List<String> pSubjectsList;
    sharedPref.getBool(Names.darkmode).then((bool b) {
      pDark = b;
    });
    sharedPref.getBool(Names.personalSubstitute).then((bool b) {
      pPersonalSubstitute = b;
    });
    sharedPref.getBool(Names.notification).then((bool b) {
      pNotification = b;
    });
    sharedPref.getBool(Names.friendsFeature).then((bool b) {
      pFriendsFeature = b;
    });
    sharedPref.getString(Names.schoolClass).then((String st) {
      pSchoolClass = st;
    });
    sharedPref.getStringList(Names.subjects).then((List<String> st) {
      pSubjectsList = st;
    });
    sharedPref.getStringList(Names.subjectsNot).then((List<String> st) {
      setState(() {
        subjectsNotList = st;
        dark = pDark;
        personalSubstitute = pPersonalSubstitute;
        notification = pNotification;
        friendsFeature = pFriendsFeature;
        schoolClass = pSchoolClass;
        subjectsList = pSubjectsList;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProviderData _themeChanger = Provider.of<ProviderData>(context);
    return Theme(
      data: _themeChanger.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                String link = await CloudDatabase().getUpdateLink();
                Share.share("Hier ist der Link für die Vertretungsapp: $link");
              },
            )
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
                    onTap: () =>
                        Navigator.pushNamed(context, Names.accountPage),
                  )),
              Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.school),
                    title: Text(
                      "Klasse/Stufe",
                      style: TextStyle(fontSize: 17),
                    ),
                    trailing: FlatButton(
                      child: Text(
                        schoolClass,
                        style: TextStyle(fontSize: 17),
                      ),
                      onPressed: () async {
                        PushNotificationsManager push =
                            PushNotificationsManager();
                        if (!schoolClass.contains(" "))
                          push.unsubTopic(
                              schoolClass); //Beim ersten starten ist die schoolClass "nicht festgelegt" und das geht nicht
                        await createAlertDialog(context, "schoolClass",
                            "Bitte wähle deine Stufe/Klasse");
                        sharedPref.getString(Names.schoolClass).then((onValue) {
                          setState(() {
                            schoolClass = onValue;
                          });
                          updateUserdata();
                        });
                      },
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
                        if (mounted)
                          setState(() {
                            personalSubstitute = b;
                          });
                        updateUserdata();
                      },
                    ),
                    ListTile(
                      title: Text("Deine Fächer(Whitelist)"),
                      enabled: personalSubstitute,
                      leading: Icon(Icons.edit),
                      onTap: !personalSubstitute
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubjectsPage(
                                      [Names.subjects, Names.subjectsCustom]),
                                ),
                              );

                              List<String> _newSubjects =
                                  await sharedPref.getStringList(Names.subjects);
                              setState(() {
                                subjectsList = _newSubjects;
                              });
                              updateUserdata();
                            },
                    ),
                    ListTile(
                      title: Text("Fächer anderer(Blacklist)"),
                      enabled: personalSubstitute,
                      leading: Icon(Icons.edit),
                      onTap: !personalSubstitute
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubjectsPage([
                                    Names.subjectsNot,
                                    Names.subjectsNotCustom
                                  ]),
                                ),
                              );
                              List<String> _newSubjects = await sharedPref
                                  .getStringList(Names.subjectsNot);
                              setState(() {
                                subjectsNotList = _newSubjects;
                              });
                              updateUserdata();
                            },
                    )
                  ],
                ),
              ),
              Card(
                elevation: 3,
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: Text(
                        "Freunde",
                        style: TextStyle(fontSize: 17),
                      ),
                      secondary: Icon(Icons.group),
                      value: friendsFeature,
                      onChanged: (bool b) {
                        sharedPref.setBool(Names.friendsFeature, b);
                        setState(() {
                          friendsFeature = b;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 17),
                      ),
                      secondary: Icon(Icons.brightness_2),
                      value: dark,
                      onChanged: (bool b) {
                        setState(() {
                          dark = b;
                          if (b) {
                            _themeChanger.setDarkTheme();
                          } else {
                            _themeChanger.setLightTheme();
                          }
                        });
                      },
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      value: notification,
                      onChanged: (bool b) {
                        sharedPref.setBool(Names.notification, b);
                        setState(() {
                          notification = b;
                        });
                        updateUserdata();
                      },
                      title: Text(
                        "Benachrichtigungen",
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
                      onTap: () =>
                          Navigator.pushNamed(context, Names.aboutPage),
                    ),
                    ListTile(
                      leading: Icon(Icons.feedback),
                      title: Text("Feedback"),
                      onTap: () async {
                        Wiredash.of(context).setBuildProperties(
                            buildVersion:
                                (await PackageInfo.fromPlatform()).version);
                        Wiredash.of(context).setUserProperties(
                            userId: await AuthService().getUserId());
                        Wiredash.of(context).show();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

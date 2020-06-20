import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:share/share.dart';
import 'package:Vertretung/otherWidgets/SchoolClassSelection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "package:wiredash/wiredash.dart";
import 'package:Vertretung/services/authService.dart';
import '../logic/localDatabase.dart';
import '../logic/names.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import 'faecherPage.dart';

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
  String schoolClass = "Nicht Geladen";
  List<String> subjectsList = [];
  List<String> subjectsNotList = [];

  LocalDatabase localDb = LocalDatabase();

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
    bool pdark;
    bool pPersonalSubstitute;
    bool pnotification;
    String pSchoolClass;
    List<String> pSubjectsList;
    localDb.getBool(Names.darkmode).then((bool b) {
      pdark = b;
    });
    localDb.getBool(Names.personalSubstitute).then((bool b) {
      pPersonalSubstitute = b;
    });
    localDb.getBool(Names.notification).then((bool b) {
      pnotification = b;
    });
    localDb.getString(Names.schoolClass).then((String st) {
      pSchoolClass = st;
    });

    localDb.getStringList(Names.subjectsList).then((List<String> st) {
      pSubjectsList = st;
    });
    localDb.getStringList(Names.subjectsNotList).then((List<String> st) {
      setState(() {
        subjectsNotList = st;
        dark = pdark;
        personalSubstitute = pPersonalSubstitute;
        notification = pnotification;
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
                        await createAlertDialog(
                            context, "schoolClass", "Bitte wähle deine Stufe/Klasse");
                        localDb.getString(Names.schoolClass).then((onValue) {
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
                        localDb.setBool(Names.personalSubstitute, b);
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
                                  builder: (context) => FaecherPage([
                                    Names.subjectsList,
                                    Names.subjectsListCustom
                                  ]),
                                ),
                              );
                              Future.delayed(Duration(seconds: 2), () {
                                //Wait for the writing from the page
                                localDb
                                    .getStringList(Names.subjectsList)
                                    .then((onValue) {
                                  if (mounted)
                                    setState(() {
                                      subjectsList = onValue;
                                    });
                                  print("hallo bin fächer mit $onValue");
                                  updateUserdata();
                                });
                              });
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
                                    builder: (context) => FaecherPage([
                                      Names.subjectsNotList,
                                      Names.subjectsNotListCustom
                                    ]),
                                  ),
                                );
                                localDb
                                    .getStringList(Names.subjectsNotList)
                                    .then((onValue) {
                                  setState(() {
                                    subjectsNotList = onValue;
                                  });
                                  updateUserdata();
                                });
                              })
                  ],
                ),
              ),
              Card(
                elevation: 3,
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 17),
                      ),
                      secondary: Icon(Icons.brightness_2),
                      value: dark,
                      onChanged: (bool b) {
                        setState(() {
                          if (b) {
                            _themeChanger.setDarkTheme();
                          } else {
                            _themeChanger.setLightTheme();
                          }
                        });
                        setState(() {
                          dark = b;
                        });
                      },
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      value: notification,
                      onChanged: (bool b) {
                        localDb.setBool(Names.notification, b);
                        localDb.getBool(Names.notification).then((bool b) {
                          setState(() {
                            notification = b;
                          });
                          updateUserdata();
                        });
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

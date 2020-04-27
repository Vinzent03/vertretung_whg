import 'package:Vertretung/logic/theme.dart';
import 'dart:convert';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:Vertretung/widgets/stufenList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:github/github.dart';
import 'package:flutter/widgets.dart';
import 'package:Vertretung/services/authService.dart';
import '../logic/localDatabase.dart';
import '../logic/names.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CloudDatabase manager;
  bool dark = false;
  bool faecherOn = false;
  bool refresh = false;
  bool notification = false;
  String stufe = "Nicht Geladen";
  String name = "Nicht Geladen";
  List<String> faecherList = [];
  List<String> faecherNotList = [];
  AuthService _authService = AuthService();


  LocalDatabase getter = LocalDatabase();

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
    print(faecherList);
    manager.updateUserData(
      faecherOn: faecherOn,
      stufe: stufe,
      faecher: faecherList,
      faecherNot: faecherNotList,
      notification: notification,
      name: name,
    );
  }

  @override
  void initState() {
    manager = CloudDatabase();
    bool pdark;
    bool pfaecherOn;
    bool pnotification;
    String pstufe;
    String pname;
    List<String> pfaecherList;
    getter.getBool(Names.dark).then((bool b) {
      pdark = b;
    });
    getter.getBool(Names.faecherOn).then((bool b) {
      pfaecherOn = b;
    });
    getter.getBool(Names.notification).then((bool b) {
      pnotification = b;
    });
    getter.getString(Names.stufe).then((String st) {
      pstufe = st;
    });
    getter.getString(Names.name).then((String st) {
      pname = st;
    });
    getter.getStringList(Names.faecherList).then((List<String> st) {
      pfaecherList = st;
    });
    getter.getStringList(Names.faecherNot).then((List<String> st) {
      setState(() {
        faecherNotList = st;
        dark = pdark;
        faecherOn = pfaecherOn;
        notification = pnotification;
        stufe = pstufe;
        name = pname;
        faecherList = pfaecherList;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Theme(
      data: _themeChanger.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            "Möchtest du dich wirklich abmelden? Dadurch wird dein Konto gelöscht!"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("abbrechen"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          RaisedButton(
                            child: Text("Bestätigen"),
                            onPressed: () async {
                              await Functions().callDeleteProfile();
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
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
                child: ListTile(
                  title: Text(
                    "Dein Account",
                  ),
                  leading: Icon(Icons.donut_large),
                  onTap: ()=> Navigator.pushNamed(context, Names.accountPage),
                )
              ),
              Card(
                  elevation: 3,
                  color: Colors.blue[500],
                  child: ListTile(
                    leading: Icon(Icons.school),
                    title: Text(
                      "Klasse/Stufe",
                      style: TextStyle(fontSize: 17),
                    ),
                    trailing: FlatButton(
                      child: Text(
                        stufe,
                        style: TextStyle(fontSize: 17),
                      ),
                      onPressed: () async {
                        PushNotificationsManager push =
                            PushNotificationsManager();
                        if (!stufe.contains(" "))
                          push.unsubTopic(
                              stufe); //Beim ersten starten ist die stufe "nicht festgelegt" und das geht nicht
                        await createAlertDialog(
                            context, "stufe", "Bitte wähle deine Stufe/Klasse");
                        getter.getString(Names.stufe).then((onValue) {
                          setState(() {
                            stufe = onValue;
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
                      value: faecherOn,
                      secondary: Icon(Icons.group),
                      onChanged: (bool b) {
                        getter.setBool(Names.faecherOn, b);
                        setState(() {
                          faecherOn = b;
                        });
                        updateUserdata();
                      },
                    ),
                    ListTile(
                      title: Text("Deine Fächer(Whitelist)"),
                      enabled: faecherOn,
                      leading: Icon(Icons.edit),
                      trailing: FlatButton(
                          child: Text(
                            "ändern",
                            style: TextStyle(fontSize: 17),
                          ),
                          onPressed: !faecherOn
                              ? null
                              : () async {
                                  await Navigator.pushNamed(
                                      context, Names.faecherPage, arguments: [
                                    Names.faecherList,
                                    Names.faecherListCustom
                                  ]);
                                  Future.delayed(Duration(seconds: 2), () {
                                    //Man muss noch auf das abspeicher in der faecherList warten, ohne extra warte Zeit, würde man noch die alten daten bekommen, weil der Schreibvorgang noch nicht fertig ist.
                                    getter
                                        .getStringList(Names.faecherList)
                                        .then((onValue) {
                                      setState(() {
                                        faecherList = onValue;
                                      });
                                      print("hallo bin fächer mit $onValue");
                                      updateUserdata();
                                    });
                                  });
                                }),
                    ),
                    ListTile(
                      title: Text("Fächer anderer(Blacklist)"),
                      enabled: faecherOn,
                      leading: Icon(Icons.edit),
                      trailing: FlatButton(
                          child: Text(
                            "ändern",
                            style: TextStyle(fontSize: 17),
                          ),
                          onPressed: !faecherOn
                              ? null
                              : () async {
                                  await Navigator.pushNamed(
                                      context, Names.faecherPage, arguments: [
                                    Names.faecherNotList,
                                    Names.faecherNotListCustom
                                  ]);
                                  getter
                                      .getStringList(Names.faecherNotList)
                                      .then((onValue) {
                                    setState(() {
                                      faecherNotList = onValue;
                                    });
                                    updateUserdata();
                                  });
                                }),
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
                        getter.setBool(Names.notification, b);
                        getter.getBool(Names.notification).then((bool b) {
                          setState(() {
                            notification = b;
                          });
                          if (notification) {
                            updateUserdata();
                          } else {
                            manager.deleteDocument();
                          }
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
                      title: Text("Fehler melden"),
                      leading: Icon(Icons.error_outline),
                      onTap: () {
                        TextEditingController controller =
                            TextEditingController();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SingleChildScrollView(//damit man beim schreiben nicht nur 3 Zeilen sieht
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Hier kannst du deinen Fehler/Verbesserungsvorschlag eingeben. Dein Fehler wird automatisch auf GitHub als Issue erstellt, er ist also öffentlich einsehbar!",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      TextField(
                                        controller: controller,
                                        maxLines: null,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("abbrechen"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  RaisedButton(
                                    child: Text("abschicken"),
                                    onPressed: () async {
                                      print("abschicken");
                                      GitHub github = GitHub(
                                          auth: Authentication.withToken(
                                              "45dd9fc3f80a5b49baf31b187d8941c2db861050"));
                                      github.issues.create(
                                          RepositorySlug(
                                              "Vinzent03", "vertretung_whg"),
                                          IssueRequest(
                                              title: "Feedback aus der App",
                                              body: controller.text,
                                              labels: ["Aus der App"]));
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            });
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

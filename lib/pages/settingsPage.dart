import 'package:Vertretung/logic/theme.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/widgets/stufenList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
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
  bool twoPages = false;
  bool refresh = false;
  bool horizontal = false;
  bool notification = false;
  String stufe = "Nicht Geladen";
  List<String> faecherList = [];
  List<String> faecherNotList = [];

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
/*              FlatButton(
                child: Text("abbrechen"),
                onPressed: () {
                  Navigator.of(context).pop(situation);
                },
              ),*/
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
    manager.updateUserData(
        faecherOn: faecherOn,
        stufe: stufe.toLowerCase(),
        faecher: faecherList,
        faecherNot: faecherNotList,
        notification: notification);
  }

  @override
  void initState() {
    manager = CloudDatabase();
    bool pdark;
    bool phorizontal;
    bool pfaecherOn;
    bool pOnlyOnePage;
    bool pnotification;
    String pstufe;
    List<String> pfaecherList;
    String pVersion;
    getter.getBool(Names.dark).then((bool b) {
      pdark = b;
    });
    getter.getBool(Names.horizontal).then((bool b) {
      phorizontal = b;
    });
    getter.getBool(Names.faecherOn).then((bool b) {
      pfaecherOn = b;
    });
    getter.getBool(Names.twoPages).then((bool b) {
      pOnlyOnePage = b;
    });
    getter.getBool(Names.notification).then((bool b) {
      pnotification = b;
    });
    getter.getString(Names.stufe).then((String st) {
      pstufe = st;
    });
    getter.getStringList(Names.faecherList).then((List<String> st) {
      pfaecherList = st;
    });
    getter.getStringList(Names.faecherNot).then((List<String> st) {
      setState(() {
        faecherNotList = st;
        dark = pdark;
        horizontal = phorizontal;
        faecherOn = pfaecherOn;
        twoPages = pOnlyOnePage;
        notification = pnotification;
        stufe = pstufe;
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
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                      onPressed: () {
                        PushNotificationsManager push =
                            PushNotificationsManager();
                        if (!stufe.contains(" "))
                          push.unsubTopic(
                              stufe); //Beim ersten starten ist die stufe "nicht festgelegt" und das geht nicht
                        createAlertDialog(context, "stufe",
                                "Bitte wähle deine Stufe/Klasse")
                            .then((nichts) {
                          getter.getString(Names.stufe).then((onValue) {
                            setState(() {
                              stufe = onValue;
                            });
                            manager.updateUserData(stufe: onValue);
                          });
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
                    SwitchListTile(
                      title: Text("Privat und Gruppen Ansicht trennen"),
                      value: twoPages,
                      secondary: Icon(Icons.list),
                      onChanged: faecherOn
                          ? (bool b) {
                              getter.setBool(Names.twoPages, b);
                              setState(() {
                                twoPages = b;
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: Text("Horizontales Wischen zum Modus wechsel"),
                      value: horizontal,
                      secondary: Icon(Icons.swap_horiz),
                      onChanged: (faecherOn && twoPages)
                          ? (bool b) {
                              getter.setBool(Names.horizontal, b);
                              setState(() {
                                horizontal = b;
                              });
                            }
                          : null,
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
                                  getter
                                      .getStringList(Names.faecherList)
                                      .then((onValue) {
                                    setState(() {
                                      faecherList = onValue;
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
                            manager.createDocument();
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
                child: ListTile(
                  title: Text(
                    "Über Uns"
                  ),
                  leading: Icon(
                    Icons.info
                  ),
                  onTap: ()=> Navigator.pushNamed(context, Names.aboutPage),
                ),
              )
            ],
          ),
        ),
        /*bottomSheet: Builder(
          builder: (context) {
            return Container(
                color: _themeChanger.getIsDark() ? Colors.black : Colors.white,
                height: 11,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Version: $version",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        final SnackBar snack = SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                                "Benachrichtigungstoken wurde zur Zwischenablage hinzugefügt"),
                            backgroundColor: Colors.red);
                        Scaffold.of(context).showSnackBar(snack);
                        PushNotificationsManager().getToken().then((onValue) {
                          Clipboard.setData(ClipboardData(text: onValue));
                        });
                      },
                    ),
                  ],
                ));
          },
        ),*/
      ),
    );
  }
}

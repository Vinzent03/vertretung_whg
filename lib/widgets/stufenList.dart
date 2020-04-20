import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class StufenList extends StatefulWidget {
  @override
  _StufenListState createState() => _StufenListState();
}

class _StufenListState extends State<StufenList> {
  LocalDatabase getter = LocalDatabase();
  String value = "";
  String stufe = "Wähle eine Stufe";
  String klasse = "Wähle eine Klasse";
  bool disabledDropdown = true;
  List stufen = [
    {"value": 0, "title": "5"},
    {"value": 1, "title": "6"},
    {"value": 2, "title": "7"},
    {"value": 3, "title": "8"},
    {"value": 4, "title": "9"},
    {"value": 5, "title": "Oberstufe"},
  ];
  List klassen = [
    {
      "1": "5a",
      "2": "5b",
      "3": "5c",
      "4": "5f",
    },
    {
      "1": "6a",
      "2": "6b",
      "3": "6c",
      "4": "6f",
    },
    {
      "1": "7a",
      "2": "7b",
      "3": "7c",
      "4": "7f",
    },
    {
      "1": "8a",
      "2": "8b",
      "3": "8c",
      "4": "8f",
    },
    {
      "1": "9a",
      "2": "9b",
      "3": "9c",
      "4": "9f",
    },
    {
      "1": "EF",
      "2": "Q1",
      "3": "Q2",
    },
  ];

  List<DropdownMenuItem<String>> menuItems = [];

  void populate(int i) {
    menuItems = [];
    for (String key in klassen[i].keys) {
      menuItems.add(DropdownMenuItem<String>(
        child: Text(klassen[i][key]),
        value: key,
      ));
    }
  }

  void valueChanged(_value) {
    setState(() {
      stufe = stufen[int.parse(_value)]["title"];
      populate(int.parse(_value));
      disabledDropdown = false;
      value = _value;
    });
  }

  void finish(_value) {
    String finalStufe = klassen[int.parse(value)][_value];
    setState(() {
      klasse = finalStufe;
    });
    PushNotificationsManager().unsubTopic(finalStufe);
    PushNotificationsManager().subTopic(finalStufe);
    FirebaseAnalytics().setUserProperty(name: "stufe", value: finalStufe);
    getter.setString(Names.stufe, finalStufe);
/*    Manager().updateUserData(
        faecherOn: getter.getBool(Names.faecherOn),
        stufe: finalStufe,
        faecher: ["Nicht festgelegt"],
        faecherNot: ["Nicht festgelegt"],
        notification: true);*/
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<String>(
          hint: Text(
            stufe,
            style: TextStyle(fontSize: 20),
          ),
          items: stufen.map((item) {
            return DropdownMenuItem<String>(
              value: item["value"].toString(),
              child: Text(
                item["title"],
              ),
            );
          }).toList(),
          onChanged: (_value) => valueChanged(_value),
        ),
        DropdownButton<String>(
          hint: Text(
            klasse,
            style: TextStyle(fontSize: 18),
          ),
          disabledHint: Text(
            "Wähle zuerst eine Stufe",
            style: TextStyle(fontSize: 18),
          ),
          items: menuItems,
          onChanged: disabledDropdown ? null : (_value) => finish(_value),
        ),
      ],
    );
  }
}

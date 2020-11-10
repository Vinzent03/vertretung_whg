import 'package:Vertretung/logic/sharedPref.dart';
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
  SharedPref sharedPref = SharedPref();
  String value = "";
  String levelHint = "1. Wähle eine Stufe";
  String classHint = "2. Wähle eine Klasse";
  bool disabledDropdown = true;
  List level = [
    {"value": 0, "title": "5"},
    {"value": 1, "title": "6"},
    {"value": 2, "title": "7"},
    {"value": 3, "title": "8"},
    {"value": 4, "title": "9"},
    {"value": 5, "title": "Oberstufe"},
  ];
  List classes = [
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
    for (String key in classes[i].keys) {
      menuItems.add(DropdownMenuItem<String>(
        child: Text(classes[i][key]),
        value: key,
      ));
    }
  }

  void valueChanged(_value) {
    setState(() {
      levelHint = level[int.parse(_value)]["title"];
      populate(int.parse(_value));
      disabledDropdown = false;
      value = _value;
    });
  }

  void finish(_value) async {
    PushNotificationsManager push = PushNotificationsManager();
    String finalClass = classes[int.parse(value)][_value];
    setState(() {
      classHint = finalClass;
    });
    String oldSchoolClass = await sharedPref.getString(Names.schoolClass);
    sharedPref.setString(Names.schoolClass, finalClass);
    if (!oldSchoolClass.contains(" "))
      await push.unsubTopic(
          oldSchoolClass); //If schoolClass is not manually set, it is set to "Nicht festgelegt", but that shouldn't be a topic
    push.subTopic(finalClass);
    FirebaseAnalytics().setUserProperty(name: "schoolClass", value: finalClass);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<String>(
          hint: Text(
            levelHint,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          items: level.map((item) {
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
            classHint,
            style: TextStyle(fontSize: 18),
          ),
          disabledHint: Text(
            classHint,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          items: menuItems,
          onChanged: disabledDropdown ? null : (_value) => finish(_value),
        ),
      ],
    );
  }
}

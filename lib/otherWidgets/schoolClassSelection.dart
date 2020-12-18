import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/data/schoolClasses.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/models/schoolClassModel.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SchoolClassSelection extends StatefulWidget {
  @override
  _SchoolClassSelectionState createState() => _SchoolClassSelectionState();
}

class _SchoolClassSelectionState extends State<SchoolClassSelection> {
  String levelHint = "1. Wähle eine Stufe";
  String classHint = "2. Wähle eine Klasse";
  String chosenLevel = "5";
  bool disabledDropdown = true;
  List<SchoolClassModel> schoolClasses = SchoolClasses().schoolClasses;

  void valueChanged(String _value) {
    setState(() {
      chosenLevel = _value;
      levelHint = _value;
      disabledDropdown = false;
    });
  }

  void finish(String _value, BuildContext context) async {
    PushNotificationsManager push = PushNotificationsManager();
    setState(() {
      classHint = _value;
    });
    String oldSchoolClass = await SharedPref.getString(Names.schoolClass);
    context.read<UserData>().schoolClass = _value;
    if (!oldSchoolClass.contains(" "))
      await push.unsubTopic(
          oldSchoolClass); //If schoolClass is not manually set, it is set to "Nicht festgelegt", but that shouldn't be a topic
    push.subTopic(_value);
    FirebaseAnalytics().setUserProperty(name: "schoolClass", value: _value);
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
          items: schoolClasses
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.title,
                  child: Text(
                    item.title,
                  ),
                ),
              )
              .toList(),
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
          items: schoolClasses
              .firstWhere((element) => element.title == chosenLevel)
              .children
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.title,
                  child: Text(e.title),
                ),
              )
              .toList(),
          onChanged:
              disabledDropdown ? null : (_value) => finish(_value, context),
        ),
      ],
    );
  }
}

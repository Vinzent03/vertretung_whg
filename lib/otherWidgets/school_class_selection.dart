import 'package:Vertretung/data/school_classes.dart';
import 'package:Vertretung/main/intro_screen.dart';
import 'package:Vertretung/models/school_class_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SchoolClassSelection extends StatefulWidget {
  /// Only given in [SettingsPage] . In [IntroScreen] this is emitted.
  final Function updateUserdata;
  final bool highlight;

  const SchoolClassSelection({
    this.updateUserdata,
    this.highlight = false,
  });
  @override
  _SchoolClassSelectionState createState() => _SchoolClassSelectionState();
}

class _SchoolClassSelectionState extends State<SchoolClassSelection> {
  List<SchoolClassModel> schoolClasses = SchoolClasses().schoolClasses;
  String grade = "";
  void selectedGrade(String newGrade) {
    Navigator.pop(context);
    setState(() => grade = newGrade);
    showSchoolClassSelection();
  }

  void finish(String newSchoolClass, BuildContext context) async {
    Navigator.pop(context);
    PushNotificationsManager push = PushNotificationsManager();
    String oldSchoolClass = context.read<UserData>().schoolClass;

    context.read<UserData>().schoolClass = newSchoolClass;
    if (widget.updateUserdata == null) {
      // Enable personal substitute for advanced level by default
      context.read<UserData>().personalSubstitute =
          ["EF", "Q1", "Q2"].contains(newSchoolClass);
    } else {
      widget.updateUserdata();
    }
    if (!oldSchoolClass.contains(" ")) {
      //If schoolClass is not manually set, it is set to "Nicht festgelegt", but that shouldn't be a topic
      await push.unsubTopic(oldSchoolClass);
    }
    push.subTopic(newSchoolClass);
    FirebaseAnalytics()
        .setUserProperty(name: "schoolClass", value: newSchoolClass);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.highlight ? Colors.red : Colors.transparent,
            width: 4,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        key: ValueKey(widget.highlight),
        child: ListTile(
          title: Text(context.watch<UserData>().schoolClass),
          leading: Icon(Icons.group),
          onTap: showGradeSelection,
          trailing: buildTrailingWidget(),
        ),
      ),
    );
  }

  buildTrailingWidget() {
    if (widget.updateUserdata == null) {
      if (context.watch<UserData>().schoolClass == "Nicht festgelegt") {
        return Text("Klasse wählen");
      }
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      return Text("Klasse wählen");
    }
  }

  showGradeSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: schoolClasses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(schoolClasses[index].title),
            onTap: () => selectedGrade(schoolClasses[index].title),
          );
        },
        shrinkWrap: true,
      ),
    );
  }

  showSchoolClassSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: schoolClasses
            .firstWhere((element) => element.title == grade)
            .children
            .length,
        itemBuilder: (context, index) {
          String title = schoolClasses
              .firstWhere((element) => element.title == grade)
              .children[index]
              .title;
          return ListTile(
            title: Text(title),
            onTap: () => finish(title, context),
          );
        },
        shrinkWrap: true,
      ),
    );
  }
}

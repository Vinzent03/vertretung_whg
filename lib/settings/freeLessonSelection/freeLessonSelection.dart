import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/settings/freeLessonSelection/lessonModel.dart';
import 'package:flutter/material.dart';

enum Weekdays { monday, tuesday, wednesday, thursday, friday }

class FreeLessonSelection extends StatefulWidget {
  @override
  _FreeLessonSelectionState createState() => _FreeLessonSelectionState();
}

class _FreeLessonSelectionState extends State<FreeLessonSelection> {
  SharedPref sharedPref = SharedPref();
  List<String> rawNewFreeLessons = [];
  List<LessonModel> template = [];
  loadData() async {
    rawNewFreeLessons = await sharedPref.getStringList(Names.freeLessons);
    for (String item in rawNewFreeLessons) {
      setState(() {
        template[int.parse(item.substring(0, 1))]
            .children[int.parse(item.substring(1)) - 1]
            .isChecked = true;
      });
    }
  }

  List<LessonModel> generateLessons(int day) {
    List<LessonModel> list = [];
    for (int i = 1; i < 10; i++) {
      list.add(LessonModel(day: Weekdays.values[day], lesson: i));
    }
    return list;
  }

  @override
  void initState() {
    for (int day = 0; day < 5; day++) {
      template.add(LessonModel(
          children: generateLessons(day), day: Weekdays.values[day]));
    }
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wähle deine Freistunden"),
      ),
      body: ListView(
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Text(buildSelectionText()),
            ),
          ),
          ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: template.length,
            itemBuilder: (context, index) => buildTiles(template[index]),
          ),
        ],
      ),
    );
  }

  checkItem(LessonModel item, bool b) async {
    if (b)
      rawNewFreeLessons.add("${item.day.index}${item.lesson}");
    else
      rawNewFreeLessons.remove("${item.day.index}${item.lesson}");
    rawNewFreeLessons.sort();
    sharedPref.setStringList(Names.freeLessons, rawNewFreeLessons);
    setState(() {
      item.isChecked = b;
    });
  }

  Widget buildTiles(LessonModel item) {
    if (item.children.isEmpty)
      return CheckboxListTile(
        title: Text("${item.lesson}. Stunde"),
        value: item.isChecked,
        onChanged: (bool b) => checkItem(item, b),
      );
    else
      return ExpansionTile(
        key: PageStorageKey<LessonModel>(item),
        title: Text(getWeekday(item.day)),
        children: item.children.map<Widget>(buildTiles).toList(),
      );
  }

  String getWeekday(Weekdays day) {
    switch (day) {
      case Weekdays.monday:
        return "Montag";
      case Weekdays.tuesday:
        return "Dienstag";
      case Weekdays.wednesday:
        return "Mittwoch";
      case Weekdays.thursday:
        return "Donnerstag";
      case Weekdays.friday:
        return "Freitag";
    }
  }

  String getShortWeekday(Weekdays day) {
    switch (day) {
      case Weekdays.monday:
        return "Mo.";
      case Weekdays.tuesday:
        return "Di.";
      case Weekdays.wednesday:
        return "Mi.";
      case Weekdays.thursday:
        return "Do.";
      case Weekdays.friday:
        return "Fr.";
    }
  }

  String buildSelectionText() {
    String text = "";
    for (String item in rawNewFreeLessons) {
      text +=
          getShortWeekday(Weekdays.values[int.parse(item.substring(0, 1))]) +
              " " +
              item.substring(1, 2) +
              ", ";
    }
    if (text.isEmpty)
      return "Noch keine Freistunden ausgewählt.";
    else
      //remove ", " at the end
      return text.substring(0, text.length - 2);
  }

  @override
  void dispose() {
    CloudDatabase().updateFreeLessons(rawNewFreeLessons);
    super.dispose();
  }
}

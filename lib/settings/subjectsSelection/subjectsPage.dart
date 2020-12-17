import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/settings/subjectsSelection/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/courseTileModel.dart';
import 'subjectsTemplate.dart';

class SubjectsPage extends StatefulWidget {
  ///whether to use data of whitelist or blacklist
  final bool isWhitelist;

  //if settings will be stored to Firestore too
  final bool inIntroScreen;
  SubjectsPage({@required this.isWhitelist, this.inIntroScreen = false});
  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<CourseTileModel> subjectsListCustom;
  List<String> selectedSubjects = [];
  TextEditingController myController;
  SharedPref sharedPref = SharedPref();
  SubjectsTemplate template = SubjectsTemplate();

  Future<void> showInfoDialog() async {
    String text;
    if (widget.isWhitelist)
      text =
          "Trage Deine eigenen Fächer ein und Dir wird nur Vertretung von Fächern angezeigt, die Du dort eingetragen hast. Dies ist hauptsächlich für die Oberstufe gedacht.";
    else
      text =
          "Trage die Fächer Deiner Freunde ein und Dir wird nur Vertretung von anderen Fächern angezeigt. Dies ist hauptsächlich für die Unterstufe gedacht.";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(text),
        actions: [
          RaisedButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  showFormatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            "Fächer müssen exakt wie auf dem normalen Vertretungsplan geschrieben werden. (z.B. M-LK1)"),
        actions: [
          RaisedButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  loadData() async {
    myController = TextEditingController(text: "Gib ein Fach ein");

    subjectsListCustom = [
      CourseTileModel() //is the add ListTile at the bottom
    ];
    //recover custom subjects
    template.subjectsTemplate.sort((a, b) => a.title.compareTo(b.title));
    List<String> savedSubjectsCustom = await sharedPref.getStringList(
        widget.isWhitelist ? Names.subjectsCustom : Names.subjectsNotCustom);
    for (String fach in savedSubjectsCustom) {
      subjectsListCustom.insert(
        subjectsListCustom.length - 1,
        CourseTileModel(
          title: fach,
          isCustom: true,
        ),
      );
    }
    // recover already selected subjects
    List<String> newSubjects = await sharedPref
        .getStringList(widget.isWhitelist ? Names.subjects : Names.subjectsNot);
    if (newSubjects.isEmpty) await showInfoDialog();

    showFormatingDialog();

    setState(() {
      selectedSubjects = newSubjects;
      for (String selectedSubject in selectedSubjects) {
        //in the moment only "EF", easier to add more lists in the future
        for (CourseTileModel section in template.subjectsTemplate) {
          for (CourseTileModel subject in section.children) {
            for (CourseTileModel course in subject.children) {
              if (course.title == selectedSubject) {
                course.isChecked = true;
              }
            }
          }
        }
        for (CourseTileModel customSubject in subjectsListCustom) {
          //used to ignore the ListTile at the bottom (used to add  subjects)
          if (customSubject.title != null) {
            if (customSubject.title == selectedSubject) {
              customSubject.isChecked = true;
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void checkItem(root, isChecked) {
    if (selectedSubjects.contains(root.title)) {
      selectedSubjects.remove(root.title);
    } else {
      selectedSubjects.add(root.title);
    }
    sharedPref.setStringList(
        widget.isWhitelist ? Names.subjects : Names.subjectsNot,
        selectedSubjects);
    if (widget.isWhitelist) {
      context.read<UserData>().subjects = selectedSubjects;
    } else {
      context.read<UserData>().subjectsNot = selectedSubjects;
    }
    selectedSubjects.sort();
    if (mounted)
      setState(() {
        root.isChecked = isChecked;
      });
  }

  Widget buildTiles(CourseTileModel root) {
    if (root.children.isEmpty) {
      if (root.title == null) {
        //ListTile with TextField
        return ListTile(
          title: TextField(
              controller: myController,
              onTap: () {
                if (myController.text == "Gib ein Fach ein")
                  myController.clear();
              }),
          leading: Icon(Icons.group),
          trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (myController.text != "") {
                  CourseTileModel newItem = CourseTileModel(
                      title: myController.text.trim(),
                      isCustom: true,
                      isChecked: true);
                  setState(() {
                    subjectsListCustom.insert(
                        subjectsListCustom.indexOf(subjectsListCustom.last),
                        newItem);
                  });
                  checkItem(newItem, true);
                  myController.clear();
                }
              }),
        );
      } else {
        //CheckBoxListTile
        return Card(
          child: CheckboxListTile(
            title: Text(root.title),
            value: root.isChecked,
            secondary: root.isCustom
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        checkItem(root, false);
                        subjectsListCustom
                            .removeWhere((item) => item.title == root.title);
                      });
                    },
                    icon: Icon(Icons.delete),
                  )
                : Icon(Icons.group),
            onChanged: (isChecked) => checkItem(root, isChecked),
          ),
        );
      }
    } else {
      //expansion ListTile
      return ExpansionTile(
        key: PageStorageKey<CourseTileModel>(root),
        title: Text(
          root.title,
        ),
        children: root.children.map<Widget>(buildTiles).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Fächer Wahl ${widget.isWhitelist ? 'Whitelist' : 'Blacklist'}"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SearchPage(
                    checkItem: checkItem,
                    templateList: template.subjectsTemplate,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Card(
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.topLeft,
                  child: Text(
                      " ${selectedSubjects.length} ausgewählte Fächer: ${selectedSubjects.toString().substring(1, selectedSubjects.toString().length - 1)}"),
                ),
              ),
              ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: template.subjectsTemplate.length,
                itemBuilder: (context, index) =>
                    buildTiles(template.subjectsTemplate[index]),
              ),
              ExpansionTile(
                title: Text(
                  "Custom",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: subjectsListCustom.map<Widget>(buildTiles).toList(),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    CloudDatabase db = CloudDatabase();
    List<String> _customSubjectsForSaving = [];
    for (CourseTileModel subject in subjectsListCustom) {
      if (subject.title != null) _customSubjectsForSaving.add(subject.title);
    }
    sharedPref.setStringList(
        widget.isWhitelist ? Names.subjectsCustom : Names.subjectsNotCustom,
        _customSubjectsForSaving);

    if (!widget.inIntroScreen) {
      db.updateSubjects();
      db.updateCustomSubjects();
    }

    myController.dispose();
    super.dispose();
  }
}

import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/settings/subjectsSelection/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/names.dart';
import '../../models/courseTileModel.dart';
import 'subjectsTemplate.dart';

class SubjectsPage extends StatefulWidget {
  ///whether to use data of whitelist or blacklist
  final List<String> names;
  SubjectsPage(this.names);
  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<CourseTileModel> subjectsListCustom;
  List<String> selectedSubjects = [];
  TextEditingController myController;
  SharedPref sharedPref = SharedPref();
  String title;
  SubjectsTemplate template = SubjectsTemplate();

  loadData() async {
    if (widget.names[0] == Names.subjects)
      title = "Whitelist";
    else
      title = "Blacklist";
    myController = TextEditingController(text: "Gib ein Fach ein");

    subjectsListCustom = [
      CourseTileModel() //is the add ListTile at the bottom
    ];
    //recover custom subjects
    template.subjectsTemplate.sort((a, b) => a.title.compareTo(b.title));
    List<String> savedSubjectsCustom =
        await sharedPref.getStringList(widget.names[1]);
    for (String fach in savedSubjectsCustom) {
      subjectsListCustom.insert(
          subjectsListCustom.length - 1,
          CourseTileModel(
            title: fach,
            isCustom: true,
          ));
    }
    // recover already selected subjects
    sharedPref.getStringList(widget.names[0]).then((newSelectedSubjects) {
      setState(() {
        selectedSubjects = newSelectedSubjects;
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
    sharedPref.setStringList(widget.names[0], selectedSubjects);
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
                        selectedSubjects.remove(root.title);
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
        title: Text("Fächer Wahl $title"),
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
                      " ${selectedSubjects.length} ausgewählte Fächer: ${selectedSubjects.toString()}"),
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
    List<String> _customSubjectsForSaving = [];
    for (CourseTileModel subject in subjectsListCustom) {
      if (subject.title != null) _customSubjectsForSaving.add(subject.title);
    }
    sharedPref.setStringList(widget.names[1], _customSubjectsForSaving);
    CloudDatabase()
        .updateCustomSubjects(widget.names[1], _customSubjectsForSaving);
    myController.dispose();
    super.dispose();
  }
}

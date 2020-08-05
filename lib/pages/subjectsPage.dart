import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/names.dart';

class SubjectModel {
  String title;
  bool isChecked;
  bool isCustom;
  List<SubjectModel> children;

  SubjectModel(
      {this.title,
      this.children = const [],
      this.isChecked = false,
      this.isCustom = false});
}

class SubjectsPage extends StatefulWidget {
  ///whether to use data of whitelist or blacklist
  final List<String> names;
  SubjectsPage(this.names);
  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<SubjectModel> subjectsTemplate;
  List<SubjectModel> subjectsListCustom;
  List<String> selectedSubjects = [];
  TextEditingController myController;
  SharedPref sharedPref = SharedPref();
  String title;

  List<SubjectModel> buildVariants(base, count) {
    List<SubjectModel> list = [];
    for (int i = 1; i <= count; i++) {
      list.add(SubjectModel(title: "$base$i"));
    }
    return list;
  }

  loadData() async {
    if (widget.names[0] == Names.subjects)
      title = "Whitelist";
    else
      title = "Blacklist";
    myController = TextEditingController(text: "Gib ein Fach ein");
    subjectsTemplate = [
      SubjectModel(
        title: "Ef Vorlagen",
        children: [
          SubjectModel(
            title: "D-GK",
            children: buildVariants("D-GK", 5),
          ),
          SubjectModel(
            title: "DVK-VK",
            children: buildVariants("DVK-VK", 1),
          ),
          SubjectModel(
            title: "KU-GK",
            children: buildVariants("KU-GK", 3),
          ),
          SubjectModel(
            title: "MU-GK",
            children: buildVariants("MU-GK", 2),
          ),
          SubjectModel(
            title: "E5-GK",
            children: buildVariants("E5-GK", 5),
          ),
          SubjectModel(
            title: "EVK-VK",
            children: buildVariants("EVK-VK", 1),
          ),
          SubjectModel(
            title: "F6-GK",
            children: buildVariants("F6-GK", 1),
          ),
          SubjectModel(
            title: "SO-GK",
            children: buildVariants("SO-GK", 2),
          ),
          SubjectModel(
            title: "L6-GK",
            children: buildVariants("L6-GK", 2),
          ),
          SubjectModel(
            title: "GE-GK",
            children: buildVariants("GE-GK", 3),
          ),
          SubjectModel(
            title: "EK-GK",
            children: buildVariants("EK-GK", 3),
          ),
          SubjectModel(
            title: "PA-GK",
            children: buildVariants("PA-GK", 2),
          ),
          SubjectModel(
            title: "SW-GK",
            children: buildVariants("SW-GK", 3),
          ),
          SubjectModel(
            title: "PL-GK",
            children: buildVariants("PL-GK", 2),
          ),
          SubjectModel(
            title: "M-GK",
            children: buildVariants("M-GK", 4),
          ),
          SubjectModel(
            title: "MVK-VK",
            children: buildVariants("MVK-VK", 2),
          ),
          SubjectModel(
            title: "PH-GK",
            children: buildVariants("PH-GK", 3),
          ),
          SubjectModel(
            title: "BI-GK",
            children: buildVariants("BI-GK", 3),
          ),
          SubjectModel(
            title: "CH-GK",
            children: buildVariants("CH-GK", 3),
          ),
          SubjectModel(
            title: "IF-GK",
            children: buildVariants("IF-GK", 2),
          ),
          SubjectModel(
            title: "KR-GK",
            children: buildVariants("KR-GK", 2),
          ),
          SubjectModel(
            title: "ER-GK",
            children: buildVariants("ER-GK", 1),
          ),
          SubjectModel(
            title: "SP-GK",
            children: buildVariants("SP-GK", 4),
          ),
        ],
      )
    ];
    subjectsListCustom = [
      SubjectModel() //is the add ListTile at the bottom
    ];
    //recover custom subjects
    subjectsTemplate.sort((a, b) => a.title.compareTo(b.title));
    List<String> savedSubjectsCustom = await sharedPref.getStringList(widget.names[1]);
    for (String fach in savedSubjectsCustom) {
      subjectsListCustom.insert(
          subjectsListCustom.length - 1,
          SubjectModel(
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
          for (SubjectModel section in subjectsTemplate) {
            for (SubjectModel subject in section.children) {
              for (SubjectModel course in subject.children) {
                if (course.title == selectedSubject) {
                  course.isChecked = true;
                }
              }
            }
          }
          for (SubjectModel customSubject in subjectsListCustom) {
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
    setState(() {
      root.isChecked = isChecked;
    });
  }

  Widget buildTiles(SubjectModel root) {
    if (root.children.isEmpty) {
      if (root.title == null) {
        //ListTile with TextField
        return ListTile(
          title: TextField(
            controller: myController,
            onTap: () => myController.clear(),
          ),
          leading: Icon(Icons.group),
          trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (myController.text != "") {
                  SubjectModel newItem = SubjectModel(
                      title: myController.text,
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
        key: PageStorageKey<SubjectModel>(root),
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
                      " ${selectedSubjects.length} Ausgewählte Fächer: ${selectedSubjects.toString()}"),
                ),
              ),
              ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: subjectsTemplate.length,
                itemBuilder: (context, index) =>
                    buildTiles(subjectsTemplate[index]),
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
    for (SubjectModel subject in subjectsListCustom) {
      if (subject.title != null) _customSubjectsForSaving.add(subject.title);
    }
    sharedPref.setStringList(widget.names[1], _customSubjectsForSaving);
    CloudDatabase().updateCustomSubjects(widget.names[1], _customSubjectsForSaving);
    super.dispose();
  }
}

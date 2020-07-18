import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/names.dart';

class Item {
  String title;
  bool isChecked;
  bool isCustom;
  List<Item> children;

  Item(
      {this.title,
      this.children = const [],
      this.isChecked = false,
      this.isCustom = false});
}

class FaecherPage extends StatefulWidget {
  final names;
  FaecherPage(this.names);
  @override
  _FaecherPageState createState() => _FaecherPageState();
}

class _FaecherPageState extends State<FaecherPage> {
  List<String> names;
  List<Item> subjects;
  List<Item> subjectsListCustom;
  List<String> selectedSubjects = [];
  TextEditingController myController;
  String title;

  List<Item> buildVariants(stamm, max) {
    List<Item> list = [];
    for (int i = 1; i <= max; i++) {
      list.add(Item(title: "$stamm$i"));
    }
    return list;
  }

  @override
  void initState() {
    names = widget.names;
    if (names[0] == Names.subjects)
      title = "Whitelist";
    else
      title = "Blacklist";
    myController = TextEditingController(text: "Gib ein Fach ein");
    subjects = [
      Item(
        title: "Ef Vorlagen",
        children: [
          Item(
            title: "D-GK",
            children: buildVariants("D-GK", 5),
          ),
          Item(
            title: "DVK-VK",
            children: buildVariants("DVK-VK", 1),
          ),
          Item(
            title: "KU-GK",
            children: buildVariants("KU-GK", 3),
          ),
          Item(
            title: "MU-GK",
            children: buildVariants("MU-GK", 2),
          ),
          Item(
            title: "E5-GK",
            children: buildVariants("E5-GK", 5),
          ),
          Item(
            title: "EVK-VK",
            children: buildVariants("EVK-VK", 1),
          ),
          Item(
            title: "F6-GK",
            children: buildVariants("F6-GK", 1),
          ),
          Item(
            title: "SO-GK",
            children: buildVariants("SO-GK", 2),
          ),
          Item(
            title: "L6-GK",
            children: buildVariants("L6-GK", 2),
          ),
          Item(
            title: "GE-GK",
            children: buildVariants("GE-GK", 3),
          ),
          Item(
            title: "EK-GK",
            children: buildVariants("EK-GK", 3),
          ),
          Item(
            title: "PA-GK",
            children: buildVariants("PA-GK", 2),
          ),
          Item(
            title: "SW-GK",
            children: buildVariants("SW-GK", 3),
          ),
          Item(
            title: "PL-GK",
            children: buildVariants("PL-GK", 2),
          ),
          Item(
            title: "M-GK",
            children: buildVariants("M-GK", 4),
          ),
          Item(
            title: "MVK-VK",
            children: buildVariants("MVK-VK", 2),
          ),
          Item(
            title: "PH-GK",
            children: buildVariants("PH-GK", 3),
          ),
          Item(
            title: "BI-GK",
            children: buildVariants("BI-GK", 3),
          ),
          Item(
            title: "CH-GK",
            children: buildVariants("CH-GK", 3),
          ),
          Item(
            title: "IF-GK",
            children: buildVariants("IF-GK", 2),
          ),
          Item(
            title: "KR-GK",
            children: buildVariants("KR-GK", 2),
          ),
          Item(
            title: "ER-GK",
            children: buildVariants("ER-GK", 1),
          ),
          Item(
            title: "SP-GK",
            children: buildVariants("SP-GK", 4),
          ),
        ],
      )
    ];
    subjectsListCustom = [
      Item() //is the add ListTile at the bottom
    ];
    //recover custom subjects
    subjects.sort((a, b) => a.title.compareTo(b.title));
    LocalDatabase().getStringList(names[1]).then((onValue) {
      for (String fach in onValue) {
        subjectsListCustom.insert(
            subjectsListCustom.length - 1,
            Item(
              title: fach,
              isCustom: true,
            ));
      }
    });
    // recover already selected subjects
    LocalDatabase().getStringList(names[0]).then((onValue) {
      setState(() {
        selectedSubjects = onValue;
        for (String fach in onValue) {
          for (Item teil in subjects) {
            for (Item item in teil.children) {
              for (Item kurs in item.children) {
                if (kurs.title == fach) {
                  kurs.isChecked = true;
                }
              }
            }
          }
          for (Item item in subjectsListCustom) {
            if (item.title != null) {
              if (item.title == fach) {
                item.isChecked = true;
              }
            }
          }
        }
      });
    });
    super.initState();
  }

  void checkItem(root, isChecked) {
    if (selectedSubjects.contains(root.title)) {
      selectedSubjects.remove(root.title);
    } else {
      selectedSubjects.add(root.title);
    }
    LocalDatabase().setStringList(names[0], selectedSubjects);
    selectedSubjects.sort();
    setState(() {
      root.isChecked = isChecked;
    });
  }

  Widget buildTiles(Item root) {
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
                  Item newItem = Item(
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
        key: PageStorageKey<Item>(root),
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
                itemCount: subjects.length,
                itemBuilder: (context, index) => buildTiles(subjects[index]),
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
    List<String> _customSubjects = [];
    for (Item item in subjectsListCustom) {
      if (item.title != null) _customSubjects.add(item.title);
    }
    LocalDatabase().setStringList(names[1], _customSubjects);
    CloudDatabase().updateCustomSubjects(names[1],_customSubjects);
    super.dispose();
  }
}

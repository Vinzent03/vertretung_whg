import 'package:Vertretung/logic/getter.dart';
import 'package:Vertretung/services/manager.dart';
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

class FaecherList extends StatefulWidget {
  List<String> names;

  FaecherList(this.names);

  @override
  _FaecherListState createState() => _FaecherListState(names);
}

class _FaecherListState extends State<FaecherList> {
  _FaecherListState(this.names); ////Konstruktor !!!!!!!!!!!

  List<String> names;
  List<Item> faecher;
  List<Item> faecherCustom;
  List<String> selectedFaecher = [];
  TextEditingController myController;

  List<Item> buildVariants(stamm, max) {
    List<Item> list = [];
    for (int i = 1; i <= max; i++) {
      list.add(Item(title: "$stamm$i"));
    }
    return list;
  }

  @override
  void initState() {
    myController = TextEditingController(text: "Gib ein Fach ein");
    faecher = [
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
    faecherCustom = [
      Item() //für das hinzufüge listtile
    ];
    // wiederherstellen der custom fächer(ohne checken der kästchen, das passiert ein weiter unten)
    faecher.sort((a, b) => a.title.compareTo(b.title));
    Getter().getStringList(names[1]).then((onValue) {
      for (String fach in onValue) {
        faecherCustom.insert(
            faecherCustom.length - 1,
            Item(
              title: fach,
              isCustom: true,
            ));
      }
    });
    // wiederherstellen der schon gecheckten fächer
    Getter().getStringList(names[0]).then((onValue) {
      setState(() {
        selectedFaecher = onValue;
        for (String fach in onValue) {
          for (Item teil in faecher) {
            for (Item item in teil.children) {
              for (Item kurs in item.children) {
                if (kurs.title == fach) {
                  print(kurs.title);
                  kurs.isChecked = true;
                }
              }
            }
          }
          for (Item item in faecherCustom) {
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
    if (selectedFaecher.contains(root.title)) {
      selectedFaecher.remove(root.title);
    } else {
      selectedFaecher.add(root.title);
    }
    print(selectedFaecher);
    selectedFaecher.sort();
    setState(() {
      root.isChecked = isChecked;
    });
  }

  Widget buildTiles(Item root) {
    if (root.children.isEmpty) {
      if (root.title == null) {
        //eingebe ListTile
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
                    faecherCustom.insert(
                        faecherCustom.indexOf(faecherCustom.last), newItem);
                  });
                  checkItem(newItem, true);
                  myController.clear();
                }
              }),
        );
      } else {
        //chckboxlisttile generell
        return CheckboxListTile(
          title: Text(root.title),
          value: root.isChecked,
          secondary: root.isCustom
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      selectedFaecher.remove(root.title);
                      faecherCustom
                          .removeWhere((item) => item.title == root.title);
                    });
                  },
                  icon: Icon(Icons.delete),
                )
              : Icon(Icons.group),
          onChanged: (isChecked) => checkItem(root, isChecked),
        );
      }
    } else {
      //expansion listtile generell
      return ExpansionTile(
        key: PageStorageKey<Item>(root),
        title: Text(
          root.title,
          //style: TextStyle(color: Colors.white),
        ),
        children: root.children.map<Widget>(buildTiles).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.topLeft,
                child: Text(
                    " ${selectedFaecher.length} Ausgewählte Fächer: ${selectedFaecher.toString()}"),
              ),
            ),
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: faecher.length,
              itemBuilder: (context, index) => buildTiles(faecher[index]),
            ),
            ExpansionTile(
              title: Text(
                "Custom",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              children: faecherCustom.map<Widget>(buildTiles).toList(),
            )
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    List<String> _list = [];
    Getter().setStringList(names[0], selectedFaecher);
    for (Item item in faecherCustom) {
      if (item.title != null) _list.add(item.title);
    }
    Getter().setStringList(names[1], _list);
    if (names[0] == Names.faecherList)
      Manager().updateUserData(faecher: selectedFaecher);
    else
      Manager().updateUserData(faecherNot: selectedFaecher);
    super.dispose();
  }
}

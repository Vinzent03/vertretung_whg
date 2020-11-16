import 'package:Vertretung/models/schoolClassModel.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsSchoolClassesSelection extends StatefulWidget {
  List<SchoolClassModel> schoolClasses;
  NewsSchoolClassesSelection(this.schoolClasses);
  @override
  _NewsSchoolClassesSelectionState createState() =>
      _NewsSchoolClassesSelectionState();
}

class _NewsSchoolClassesSelectionState
    extends State<NewsSchoolClassesSelection> {
  changeEveryItem(bool enable) {
    for (SchoolClassModel items in widget.schoolClasses) {
      for (SchoolClassModel item in items.children) {
        setState(() {
          item.isChecked = enable;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wähle Klassen/Stufen für die Nachricht"),
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
            itemCount: widget.schoolClasses.length,
            itemBuilder: (context, index) =>
                buildTiles(widget.schoolClasses[index]),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Provider.of<ProviderData>(context).getUsedTheme() ==
                Brightness.dark
            ? Colors.black
            : Colors.white,
        child: ButtonBar(
          buttonPadding: EdgeInsets.symmetric(horizontal: 15),
          children: [
            FlatButton(
              child: Text("Alle abwählen"),
              onPressed: () => changeEveryItem(false),
            ),
            FlatButton(
              child: Text("Alle auswählen"),
              onPressed: () => changeEveryItem(true),
            ),
          ],
        ),
      ),
    );
  }

  checkItem(SchoolClassModel item, bool b) async {
    setState(() {
      item.isChecked = b;
    });
  }

  Widget buildTiles(SchoolClassModel item) {
    if (item.children.isEmpty)
      return CheckboxListTile(
        title: Text(item.title),
        value: item.isChecked,
        onChanged: (bool b) => checkItem(item, b),
      );
    else
      return ExpansionTile(
        key: PageStorageKey<SchoolClassModel>(item),
        title: Text(item.title),
        children: item.children.map<Widget>(buildTiles).toList(),
      );
  }

  String buildSelectionText() {
    String text = "";
    widget.schoolClasses.forEach((element) {
      element.children.where((element) => element.isChecked).forEach((element) {
        text += element.title + ", ";
      });
    });
    if (text.isEmpty)
      return "Noch keine Klassen/Stufen ausgewählt.";
    else
      //remove ", " at the end
      return text.substring(0, text.length - 2);
  }
}

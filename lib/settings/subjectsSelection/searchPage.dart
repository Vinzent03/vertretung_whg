import 'package:flutter/material.dart';
import '../../models/courseTileModel.dart';

class SearchPage extends StatefulWidget {
  final Function checkItem;
  final List<CourseTileModel> templateList;
  SearchPage({this.checkItem, this.templateList, Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<CourseTileModel> filteredList = [];
  List<CourseTileModel> listForSearch = [];
  TextEditingController controller = TextEditingController();

  filter(String search) {
    setState(() {
      filteredList = listForSearch
          .where((element) => element.title
              .toLowerCase()
              .replaceAll("-", "")
              .contains(search.toLowerCase()))
          .toList();
    });
  }

  buildList(List<CourseTileModel> subjectsTemplate) {
    List<CourseTileModel> subjectsListForSearch = [];
    for (CourseTileModel section in subjectsTemplate) {
      for (CourseTileModel subject in section.children) {
        for (CourseTileModel course in subject.children) {
          subjectsListForSearch.add(course);
        }
      }
    }
    return subjectsListForSearch;
  }

  @override
  void initState() {
    listForSearch = buildList(widget.templateList);
    filteredList = listForSearch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          onChanged: filter,
        ),
      ),
      body: filteredList.length > 0
          ? ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (BuildContext context, int index) =>
                  CheckboxListTile(
                title: Text(filteredList[index].title),
                value: filteredList[index].isChecked,
                onChanged: (bool value) {
                  widget.checkItem(filteredList[index], value);
                  setState(() {
                    filteredList[index].isChecked = value;
                  });
                },
              ),
            )
          : Center(
              // child: Text("Dieses Fach ist nicht in der Liste vorhanden."),
              child: Icon(
                Icons.cancel,
                size: 100,
              ),
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

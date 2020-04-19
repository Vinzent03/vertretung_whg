import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/widgets/faecherList.dart';
import 'package:flutter/material.dart';

class FaecherPage extends StatefulWidget {
  @override
  _FaecherPageState createState() => _FaecherPageState();
}

class _FaecherPageState extends State<FaecherPage> {
  List<String> names;
  String title;


  @override
  Widget build(BuildContext context) {
    names = ModalRoute.of(context).settings.arguments;
    if(names[0]== Names.faecherList)
      title = "Whitelist";
    else
      title= "Blacklist";
    return Scaffold(
      appBar: AppBar(
        title: Text("Fächer Wahl $title"),
      ),
      body: FaecherList(names),
    );
  }
}

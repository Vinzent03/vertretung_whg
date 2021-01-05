import 'package:Vertretung/provider/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoSubstitute extends StatefulWidget {
  @override
  _NoSubstituteState createState() => _NoSubstituteState();
}

class _NoSubstituteState extends State<NoSubstitute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.all(Radius.circular(15))),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        context.watch<UserData>().lastChange.contains("00:09")
            ? "Leider keine Vertretung, aber der Plan wurde noch nicht aktualisiert"
            : "Leider keine Vertretung 😔",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NoSubstitute extends StatefulWidget {
  final bool isNotUpdated;
  NoSubstitute(this.isNotUpdated);
  @override
  _NoSubstituteState createState() => _NoSubstituteState();
}

class _NoSubstituteState extends State<NoSubstitute> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.business_center,
            color: Colors.blue,
            size: 200,
          ),
          Text(
            widget.isNotUpdated
                ? "Leider keine Vertretung, aber der Plan wurde noch nicht aktualisiert."
                : "Leider keine Vertretung",
            style: TextStyle(fontSize: 19),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

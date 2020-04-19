import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InformationTile extends StatelessWidget {
  final String day;
  final bool isMy;
  final String change;

  InformationTile({Key key, @required this.day, @required this.change, @required this.isMy})
      : super(key: key);

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 5,bottom: 15,left: 5,right: 5),
      color: Colors.orange,
      child: ListTile(
        title: Text(
          "$day ${isMy ? "Privat": ""}",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          "Woche: ${getWeekNumber(DateTime.now()).toString()}",
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        trailing: Text(
          change,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: Icon(isMy ? Icons.person:Icons.group,size: 33,),
        dense: true,
      ),
    );
  }
}

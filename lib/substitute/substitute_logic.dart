import 'dart:convert';
import 'dart:io';

import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubstituteLogic {
  bool loadingSuccess = true;
  static int getWeekNumber() {
    DateTime date = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  //replace this for your own situation
  Future<List<dynamic>> _getData() async {
    try {
      if (kIsWeb) return await CloudDatabase().getSubstitute();
      var todayResponse = await http.get(Uri.parse(Names.substituteLinkToday));
      var tomorrowResponse =
          await http.get(Uri.parse(Names.substituteLinkTomorrow));
      dom.Document todayDocument = parse(utf8.decode(todayResponse.bodyBytes));
      dom.Document tomorrowDocument =
          parse(utf8.decode(tomorrowResponse.bodyBytes));
      String unformattedLastChange =
          todayDocument.querySelectorAll('h2').first.text;

      List<dom.Element> vertretungToday = todayDocument.querySelectorAll('td');
      List<dom.Element> vertretungTomorrow =
          tomorrowDocument.querySelectorAll('td');

      List<String> vertretungTodayList = [];
      vertretungToday.forEach((element) {
        vertretungTodayList.add(element.text.trim());
      });
      List<String> vertretungTomorrowList = [];
      vertretungTomorrow.forEach((element) {
        vertretungTomorrowList.add(element.text.trim());
      });
      return [
        formatLastChange(unformattedLastChange),
        _getDayNames(todayDocument, tomorrowDocument),
        vertretungTodayList,
        vertretungTomorrowList
      ];
    } on SocketException catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> reloadSubstitute(BuildContext context) async {
    SnackBar snack = SnackBar(
      content: Text("Es werden alte Daten verwendet."),
      duration: Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Ausblenden",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          loadingSuccess = true; // make snackbar able to reshow
        },
      ),
    );
    List<dynamic> dataResult =
        await SubstituteLogic()._getData(); //load the data from dsb mobile
    if (dataResult.isEmpty) {
      if (loadingSuccess) ScaffoldMessenger.of(context).showSnackBar(snack);
      loadingSuccess = false;
    } else {
      loadingSuccess = true;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.read<UserData>().lastChange = dataResult[0];
      context.read<UserData>().dayNames = dataResult[1];
      context.read<UserData>().rawSubstituteToday = dataResult[2];
      context.read<UserData>().rawSubstituteTomorrow = dataResult[3];

      CloudDatabase().updateLastNotification(context.read<UserData>());
    }
  }

  static String formatLastChange(String unformattedLastChange) {
    var lastChangeShort = unformattedLastChange.substring(17);
    var lastChangeFinal =
        lastChangeShort.replaceAll(lastChangeShort.substring(6, 10), "");
    return lastChangeFinal;
  }

  List<String> _getDayNames(
      dom.Document todayDocument, dom.Document tomorrowDocument) {
    List<dom.Element> dayNameToday =
        todayDocument.getElementsByClassName("dayHeader");
    List<dom.Element> dayNameTomorrow =
        tomorrowDocument.getElementsByClassName("dayHeader");
    if (dayNameToday.isEmpty) {
      dayNameToday = todayDocument.querySelectorAll("legend");
    }
    if (dayNameTomorrow.isEmpty) {
      dayNameTomorrow = tomorrowDocument.querySelectorAll("legend");
    }
    List<String> dayNames = [
      dayNameToday.first.text,
      dayNameTomorrow.first.text
    ];
    List<String> dayNamesFormatted =
        dayNames.map((e) => e.substring(e.indexOf(",") + 2)).toList();
    return dayNamesFormatted;
  }
}

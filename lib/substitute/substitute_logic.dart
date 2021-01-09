import 'dart:convert';

import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SubstituteLogic {
  bool loadingSuccess = true;
  int getWeekNumber() {
    DateTime date = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  //replace this for your own situation
  Future<List<dynamic>> getData() async {
    try {
      if (kIsWeb) return await CloudDatabase().getSubstitute();
      var todayResponse = await http.get(Names.substituteLinkToday);
      var tomorrowResponse = await http.get(Names.substituteLinkTomorrow);
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
        vertretungTodayList,
        vertretungTomorrowList
      ];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> reloadSubstitute(
      BuildContext context, RefreshController refreshController) async {
    SnackBar snack = SnackBar(
      content: Text("Es werden alte Daten verwendet."),
      duration: Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Ausblenden",
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
          loadingSuccess = true; // make snackbar able to reshow
        },
      ),
    );
    List<dynamic> dataResult =
        await SubstituteLogic().getData(); //load the data from dsb mobile
    if (dataResult.isEmpty) {
      if (loadingSuccess) Scaffold.of(context).showSnackBar(snack);
      loadingSuccess = false;
      String newLastChange = await SharedPref.getString(Names.lastChange);
      List<String> oldRawSubstituteToday =
          await SharedPref.getStringList(Names.substituteToday);
      List<String> oldRawSubstituteTomorrow =
          await SharedPref.getStringList(Names.substituteTomorrow);
      context.read<UserData>().rawSubstituteToday = oldRawSubstituteToday;
      context.read<UserData>().rawSubstituteTomorrow = oldRawSubstituteTomorrow;
      context.read<UserData>().lastChange = newLastChange;
    } else {
      loadingSuccess = true;
      Scaffold.of(context).hideCurrentSnackBar();
      context.read<UserData>().lastChange = dataResult[0];
      context.read<UserData>().rawSubstituteToday = dataResult[1];
      context.read<UserData>().rawSubstituteTomorrow = dataResult[2];

      CloudDatabase().updateLastNotification(context.read<UserData>());
    }
    refreshController.refreshCompleted();
  }

  String formatLastChange(String unformattedLastChange) {
    var lastChangeShort = unformattedLastChange.substring(17);
    var lastChangeFinal =
        lastChangeShort.replaceAll(lastChangeShort.substring(6, 10), "");
    return lastChangeFinal;
  }
}

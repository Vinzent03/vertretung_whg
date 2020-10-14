import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'dart:convert';

class SubstituteLogic {
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
      String lastChange = todayDocument.querySelectorAll('h2').first.text;
      var lastChangeShort = lastChange.substring(17);
      var lastChangeFinal =
          lastChangeShort.replaceAll(lastChangeShort.substring(6, 10), "");

      List<dom.Element> vertretungToday = todayDocument.querySelectorAll('td');
      List<dom.Element> vertretungTomorrow =
          tomorrowDocument.querySelectorAll('td');

      List<String> vertretungTodayList = [];
      vertretungToday.forEach((element) {
        vertretungTodayList.add(element.text);
      });
      List<String> vertretungTomorrowList = [];
      vertretungTomorrow.forEach((element) {
        vertretungTomorrowList.add(element.text);
      });
      return [lastChangeFinal, vertretungTodayList, vertretungTomorrowList];
    } catch (e) {
      print(e);
      return [];
    }
  }
}

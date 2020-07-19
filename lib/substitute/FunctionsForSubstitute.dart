import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class FunctionsForVertretung {
  int getWeekNumber() {
    DateTime date = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  //replace this for your own situation
  Future<List<dynamic>> getData() async {
    try {
      var todayResponse = await http.get(
          "https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html");
      var tomorrowResponse = await http.get(
          "https://app.dsbcontrol.de/data/0c2b6ffe-f068-47b0-833a-07ec15bae1ed/12dcaead-309b-4fc6-904e-5e0bfc1f20b3/12dcaead-309b-4fc6-904e-5e0bfc1f20b3.html");
      dom.Document todayDocument = parse(todayResponse.body);
      dom.Document tomorrowDocument = parse(tomorrowResponse.body);
      String lastChange = todayDocument.querySelectorAll('h2').first.text;
      var lastChangeShort = lastChange.substring(18);
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

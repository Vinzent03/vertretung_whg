import 'package:http/http.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class FunctionsForVertretung{
  int getWeekNumber() {
    DateTime date = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  //replace this for your own situation
  Future<List<dynamic>> getData() async {
    print("Anfang des webscrapen");
    var client = Client();
    try {
      Response todayResponse = await client.get(
          "https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html");//"https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html"
      Response tomorrowResponse = await client.get(
          "https://app.dsbcontrol.de/data/0c2b6ffe-f068-47b0-833a-07ec15bae1ed/12dcaead-309b-4fc6-904e-5e0bfc1f20b3/12dcaead-309b-4fc6-904e-5e0bfc1f20b3.html");
      print("Der web Zugriff ist abgeschlossen");
      dom.Document todayDocument = parse(todayResponse.body);
      dom.Document tomorrowDocument = parse(tomorrowResponse.body);
      String lastChange = todayDocument.querySelectorAll('h2').first.text;
      var lastChangeShort = lastChange.substring(18);
      var lastChangeFinal = lastChangeShort.replaceAll(lastChangeShort.substring(3,10), "");

      List<dom.Element> vertretungToday = todayDocument.querySelectorAll('td');
      List<dom.Element> vertretungTomorrow = tomorrowDocument.querySelectorAll('td');

      List<String> vertretungTodayList = [];
      vertretungToday.forEach((element) {
        vertretungTodayList.add(element.text);
      });
      List<String> vertretungTomorrowList = [];
      vertretungTomorrow.forEach((element) {
        vertretungTomorrowList.add(element.text);
      });
      return [lastChangeFinal, vertretungTodayList,vertretungTomorrowList];
    } catch (e) {
      print(e);
      return [];

    }
  }
}
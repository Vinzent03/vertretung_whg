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

  Future<List<dynamic>> getData() async {
    print("Anfang des webscrapen");
    var client = Client();
    try {
      Response response = await client.get(
          "https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html");//"https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html"
      print("Der web Zugriff ist abgeschlossen");
      dom.Document document = parse(response.body);
      String lastChange = document.querySelectorAll('h2').first.text;
      var lol = lastChange.substring(18);
      var lol2 = lol.replaceAll(lol.substring(3,10), "");

      List<dom.Element> vertretungToday = document.querySelectorAll('td');

      List<String> vertretungTodayList = [];
      vertretungToday.forEach((element) {
        vertretungTodayList.add(element.text);
      });
      return [lol2, vertretungTodayList];
    } catch (e) {
      print(e);
      return [];

    }
  }
}
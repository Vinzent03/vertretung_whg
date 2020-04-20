import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

Future<String> getData() async {
  print("Anfang des webscrapen");
  var client = Client();
  try {
    Response response = await client.get(
        "https://app.dsbcontrol.de/data/748a002d-3b4b-44ce-8311-232ed983711d/f3e9a6da-7e76-4949-816c-58c7ee05abc8/f3e9a6da-7e76-4949-816c-58c7ee05abc8.html");
    print("Der web Zugriff ist abgeschlossen");
    var document = parse(response.body);
    List<dom.Element> links = document.querySelectorAll('h2');
    return links.first.text.substring(18);
  } catch (e) {
    return "Fehler";
  }
}

Future<bool> showUpdateDialog(context) async{
  CloudDatabase cd = CloudDatabase();

  String updateSituation = await cd.getUpdate();
  // ignore: missing_return
    if (updateSituation == "updateAvaible") {
      return true;
    } else if (updateSituation == "forceUpdate") {
      String link = await cd.getUpdateLink();
      List<dynamic> message = await cd.getUpdateMessage();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {},
            child: AlertDialog(
              title: Text(message[0]),
              content: Text(message[1]),
              actions: <Widget>[
                RaisedButton(
                  child: Text("Update"),
                  onPressed: () => launch(link),
                )
              ],
            ),
          );
        },
      );
    }else
      return false;

}

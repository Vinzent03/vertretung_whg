import 'package:flutter/material.dart';

class HelpItem {
  bool isExpanded;
  final String header;
  final String body;

  HelpItem({this.isExpanded: false, this.header, this.body});
}

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<HelpItem> _items;

  @override
  void initState() {
    _items = <HelpItem>[
      HelpItem(
        header: "Woher kommen die Daten?",
        body:
            "Die Daten werden aus dem DSBmobile HTML code gefiltert (siehe Ursprung: https://www.dsbmobile.de)",
      ),
      HelpItem(
        header: "Was ist personalisierte Vertretung?",
        body:
            "Wenn in den Einstellungen die personalisierte Vertretung eingestellt ist, kannst du in den Einstellungen Fächer die du hast bzw. nicht hast Blacklisten / Whitelisten. Anschließend ist eine personalisierte Seite sichtbar, wo für dich relevante Vertretungen zu sehen sind.",
      ),
      HelpItem(
        header: "Wie funktionieren die Benachrichtigungen?",
        body:
            "Die Cloud schaut mehrmals stündlich bei jedem individuellem Nutzer, ob neue Vertretungen verfügbar sind. Dabei werden nur Vertretungen für den aktuellen Tag berücksichtigt. Wenn personalisierte Fächer eingeschaltet ist, wird man nur bei relevanten Äußerungen benachrichtigt. Da die Benachrichtigung nicht lokal erzeugt wird, erhält man auch Benachrichtigungen wenn die Anwendung geschlossen ist.",
      ),
      HelpItem(
        header: "Freunde",
        body:
            "Du kannst Freunde über einen Token hinzufügen. Diesen bekommt man über das Share Symbol auf der Freundes Seite. Um ein Freund hinzuzufügen muss man die Freundesanfrage annehmen. Anschließend siehst du auf der Freudes Seite die Vertretung deiner Freunde.",
      ),
      HelpItem(
        header: "Datenschutz",
        body:
            "Deine Einstellungen, Freunde und dein Name werden in der Cloud (in Frankfurt) gespeichert, um Dienste wie Benachrichtigungen und Freunde zu ermöglichen.",
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Card(
        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _items[index].isExpanded = !_items[index].isExpanded;
                });
              },
              children: _items.map((HelpItem item) {
                return ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          item.header,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    isExpanded: item.isExpanded,
                    body: Container(
                      padding:
                          EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        item.body,
                        style: TextStyle(fontSize: 15),
                      ),
                    ));
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

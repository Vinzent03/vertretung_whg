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
            "Wenn in den Einstellungen die personalisierte Vertretung eingeschaltet ist, kannst du in den Einstellungen Fächer die du hast (Whitelist) bzw. nicht hast (Blacklist) eintragen. Anschließend sind weitere Tabs mit nur für dich relevanter Vertretung zu sehen.",
      ),
      HelpItem(
        header: "Wie funktionieren die Benachrichtigungen?",
        body:
            "Die Cloud schaut mehrmals stündlich bei jedem individuellem Nutzer, ob neue Vertretungen verfügbar sind. Dabei werden nur Vertretungen für den aktuellen Tag berücksichtigt. Wenn personalisierte Vertretung eingeschaltet ist, wird man nur bei relevanten Änderungen benachrichtigt.",
      ),
      HelpItem(
        header: "Freunde",
        body:
            "Wenn du Freunde hinzufügst, siehst du wann deine Freunde Entfall haben. So weißt du immer wann du dich mit ihnen treffen kannst. Um Freunde hinzuzufügen, schickst du deinen Freundestoken/Link an einen Freund. Die Person muss den Token dann eingeben oder auf den Link klicken.",
      ),
      HelpItem(
        header: "Datenschutz",
        body:
            "Deine Einstellungen werden in der Cloud (Frankfurt) gespeichert. Dies ist z.B für das Freundes-Feature nötig. Zusätzlich werden besondere Ereignisse wie Registrierungen und Fehlerberichte anonym gesendet.",
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
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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

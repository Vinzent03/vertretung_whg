import 'package:Vertretung/logic/theme.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/myItem.dart';
import 'package:provider/provider.dart';


class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<MyItem> _items = <MyItem>[
    MyItem(
      header: "Woher kommen die Daten?",
      body:
          "Die Daten kommen von der DSB Website und werden aus dem html code gefiltert",
    ),
    MyItem(
      header: "Was ist personalisierte Vertretung?",
      body:
          "Wenn du in den Einstellunen personalisierte Vertretung einschaltest, kannst du deine Fächer, bzw. die Fächer die du nicht hast eintragen. Anschließend ist in der App ein privater Bereich zu sehen, dort siehst du dann nur für dich relevante Vertretung",
    ),
    MyItem(
      header: "Wie funktionieren die Benachrichtigungen?",
      body:
          "Es wird mehrmals die Stunde eine Funktion in der Cloud aufgerufen, die dann jeden Benutzer durchgeht und schaut ob er/sie neue Vertretung hat. Dabei wird aber nur die heutige Vertretung beachtet. Wenn personalisierte Fächer an ist, wird man nur bei privaten Änderungen benachrichtigt. Da die Benachrichtigung von der Cloud aus kommt, schaut nicht euer Handy durchgehend nach neuer Vertretung. Man kann die App also auch schließen, die Benachrichtigung kommt trotzdem an. xD",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeChanger>(context).getTheme(),
      child: Scaffold(
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
                  children: _items.map((MyItem item) {
                    return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              item.header,
                              style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        isExpanded: item.isExpanded,
                        body: Container(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(item.body,style: TextStyle(
                            fontSize: 15
                          ),),
                        ));
                  }).toList(),
                )
              ],
            ),
          )),
    );
  }
}

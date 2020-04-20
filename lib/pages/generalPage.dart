import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/informationTile.dart';
import '../widgets/vertretungTile.dart';

class GeneralPage extends StatelessWidget {
  final bool today;
  final isMy;
  final List<List<String>> list;
  final String change;
  final bool onlyOnePage;
  bool updateAvaible = false;
  GeneralPage(
      {Key key,
      @required this.today,
      @required this.list,
      @required this.change,
      this.isMy,
      this.onlyOnePage,
      this.updateAvaible})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(updateAvaible== null)
      updateAvaible =false;
    return ListView(
      //doppelte listview sonst kann man nicht scrollen
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: <Widget>[
        Column(
          children: <Widget>[
            if(updateAvaible)
              Card(
                color: Colors.red,
                child: ListTile(
                  title: Text("Es ist ein Update ausstehend!"),
                  subtitle: Text("Tippe um zum Download zu kommen"),
                  leading: Icon(Icons.warning),
                  onTap: (){
                    CloudDatabase().getUpdateLink().then((onValue){
                      launch(onValue);
                    });
                  },
                ),
              ),
            InformationTile(
              change: change,
              day: today ? "Heute" : "Morgen",
              isMy: isMy,
            ),
            list[0].isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: list[0].length,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return VertretungTile(
                        dense: list[0].length >7 ? true:false,
                        list: list,
                        index: index,
                      );
                    })
                : Container(
              margin: onlyOnePage==null ? EdgeInsets.only(top: 140): null,
                    child: Icon(
                      Icons.business_center,
                      color: Colors.blue,
                      size: onlyOnePage == null
                          ? 200
                          : 100, // Wenn onlyOnePage soll das Icon kleiner machen
                    ),
                  ),
          ],//mainAxisSize: MainAxisSize.min,
        ),
      ],
    );
  }
}

import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'informationTile.dart';
import 'vertretungTile.dart';

class GeneralBlueprint extends StatelessWidget {
  final bool today;
  final isMy;
  final List<List<String>> list;
  final String change;
  GeneralBlueprint(
      {Key key,
      @required this.today,
      @required this.list,
      @required this.change,
      this.isMy,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(list[0].isNotEmpty)
    return ListView(
      //doppelte listview sonst kann man nicht scrollen
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: <Widget>[
        ListView.builder(
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
      ],
    );
    else
      return Center(
        child: Icon(
          Icons.business_center,
          color: Colors.blue,
          size: 200, // Wenn onlyOnePage soll das Icon kleiner machen
        ),
      );
  }
}

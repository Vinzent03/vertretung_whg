import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/substitute/no_substitute.dart';
import 'package:Vertretung/substitute/substitute_tile.dart';
import 'package:flutter/material.dart';

import 'text_headline.dart';

class TwoDayOverview extends StatelessWidget {
  final List<SubstituteModel> today;
  final List<SubstituteModel> tomorrow;
  final bool fromFriendsPage;
  final double padding = 8;

  const TwoDayOverview({
    Key key,
    @required this.today,
    @required this.tomorrow,
    @required this.fromFriendsPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (today.isNotEmpty || tomorrow.isNotEmpty)
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextHeadline("Heute: ", today.length.toString()),
            if (today.isEmpty)
              NoSubstitute()
            else
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: today.length,
                itemBuilder: (context, index) {
                  return SubstituteListTile(today[index], false);
                },
              ),
            TextHeadline("Morgen: ", tomorrow.length.toString()),
            if (tomorrow.isEmpty)
              NoSubstitute()
            else
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tomorrow.length,
                itemBuilder: (context, index) {
                  return SubstituteListTile(tomorrow[index], false);
                },
              )
          ],
        ),
      );
    else {
      String path;
      if (Theme.of(context).brightness == Brightness.light) {
        path = "assets/images/no-data-light.png";
      } else {
        path = "assets/images/no-data-dark.png";
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(path),
              SizedBox(
                height: 10,
              ),
              Text(
                "Ziemlich leer hier.",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      );
    }
  }
}

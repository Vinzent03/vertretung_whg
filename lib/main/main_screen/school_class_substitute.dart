import 'package:Vertretung/main/main_screen/text_headline.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/substitute/no_substitute.dart';
import 'package:Vertretung/substitute/substitute_tile.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SchoolClassSubstitute extends StatelessWidget {
  final double padding = 10;
  final List<SubstituteModel> today;
  final List<SubstituteModel> tomorrow;
  final Function refresh;
  final RefreshController refreshController;

  const SchoolClassSubstitute(
      {Key key,
      @required this.today,
      @required this.tomorrow,
      @required this.refreshController,
      @required this.refresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: refresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextHeadline("Heute: ${today.length}"),
            if (today.isEmpty)
              NoSubstitute()
            else
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: today.length,
                  itemBuilder: (context, index) {
                    return SubstituteListTile(today[index]);
                  },
                ),
              ),
            TextHeadline("Morgen: ${tomorrow.length}"),
            if (tomorrow.isEmpty)
              NoSubstitute()
            else
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tomorrow.length,
                  itemBuilder: (context, index) {
                    return SubstituteListTile(tomorrow[index]);
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

import 'package:Vertretung/main/main_screen/two_day_overview.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SchoolClassSubstitute extends StatelessWidget {
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
      child: TwoDayOverview(
        today: today,
        tomorrow: tomorrow,
        fromFriendsPage: false,
      ),
    );
  }
}

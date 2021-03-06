import 'package:Vertretung/main/main_screen/two_day_overview.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:flutter/material.dart';

class SchoolClassSubstitute extends StatelessWidget {
  final List<SubstituteModel> today;
  final List<SubstituteModel> tomorrow;
  final Function refresh;

  const SchoolClassSubstitute(
      {Key key,
      @required this.today,
      @required this.tomorrow,
      @required this.refresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: TwoDayOverview(
        today: today,
        tomorrow: tomorrow,
        fromFriendsPage: false,
      ),
    );
  }
}

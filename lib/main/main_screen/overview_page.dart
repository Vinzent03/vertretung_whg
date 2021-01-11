import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/main/main_screen/info_box.dart';
import 'package:Vertretung/main/main_screen/text_headline.dart';
import 'package:Vertretung/main/main_screen/today_overview.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OverviewPage extends StatelessWidget {
  final List<FriendModel> friendsSettings;
  final double padding = 10;
  final bool finishedLoading;
  final Function swapPage;
  final Function refresh;
  final RefreshController refreshController;

  OverviewPage({
    Key key,
    @required this.friendsSettings,
    @required this.swapPage,
    @required this.refreshController,
    @required this.refresh,
    @required this.finishedLoading,
  }) : super(key: key);
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
            TextHeadline(
                "Deine Vertretungen ${context.watch<UserData>().formattedDayNames[0]}: ",
                context.watch<UserData>().substituteToday.length.toString()),
            TodayOverview(
              today: true,
              loaded: finishedLoading,
            ),
            TextHeadline(
                "Deine Vertretungen ${context.watch<UserData>().formattedDayNames[1]}: ",
                context.watch<UserData>().substituteTomorrow.length.toString()),
            TodayOverview(
              today: false,
              loaded: finishedLoading,
            ),
            if (context.watch<UserData>().personalSubstitute)
              TextHeadline(
                "Vertretungen von: ",
                context.watch<UserData>().schoolClass,
              ),
            if (context.watch<UserData>().personalSubstitute)
              Row(
                children: [
                  InfoBox(
                    title: "${context.watch<UserData>().formattedDayNames[0]}",
                    list: Filter.checkForSchoolClass(
                        context.watch<UserData>().schoolClass,
                        context.watch<UserData>().rawSubstituteToday),
                    loaded: finishedLoading,
                    onPressed: () => swapPage(1),
                  ),
                  SizedBox(
                    width: padding,
                  ),
                  InfoBox(
                    title: "${context.watch<UserData>().formattedDayNames[1]}",
                    list: Filter.checkForSchoolClass(
                        context.watch<UserData>().schoolClass,
                        context.watch<UserData>().rawSubstituteTomorrow),
                    loaded: finishedLoading,
                    onPressed: () => swapPage(1),
                  ),
                ],
              ),
            if (context.watch<UserData>().friendsFeature)
              TextHeadline("Freunde"),
            if (context.watch<UserData>().friendsFeature)
              Row(
                children: [
                  InfoBox(
                    list: FriendLogic.friendsWithFreetime(
                      FriendLogic.getFriendsSubstitute(
                        friendsSettings ?? [],
                        context.watch<UserData>().rawSubstituteToday,
                        true,
                      ),
                    ),
                    title: "Freunde haben frei",
                    loaded: friendsSettings != null && finishedLoading,
                    onPressed: () {
                      if (context.read<UserData>().personalSubstitute) {
                        swapPage(2);
                      } else {
                        swapPage(1);
                      }
                    },
                  ),
                  SizedBox(
                    width: padding,
                  ),
                  InfoBox(
                    list: FriendLogic.friendsFreeWithUser(
                        friendsSettings, context.watch<UserData>()),
                    title: "Haben mit Dir frei",
                    loaded: friendsSettings != null && finishedLoading,
                    onPressed: () {
                      if (context.read<UserData>().personalSubstitute) {
                        swapPage(2);
                      } else {
                        swapPage(1);
                      }
                    },
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

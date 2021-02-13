import 'package:Vertretung/friends/add_friend_dialog.dart';
import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/main/main_screen/two_day_overview.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatelessWidget {
  final List<FriendModel> friendsSettings;

  const FriendsPage({Key key, this.friendsSettings}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (friendsSettings != null) {
      final List<SubstituteModel> today = FriendLogic.getFriendsSubstitute(
          friendsSettings, context.watch<UserData>().rawSubstituteToday, true);
      final List<SubstituteModel> tomorrow = FriendLogic.getFriendsSubstitute(
          friendsSettings,
          context.watch<UserData>().rawSubstituteTomorrow,
          false);

      if (friendsSettings.isEmpty) {
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: Text("Füge Freunde hinzu!"),
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => AddFriendDialog());
              },
            ),
            OutlinedButton(
              child: Text("Freunde-Funktion deaktivieren"),
              onPressed: () {
                context.read<UserData>().friendsFeature = false;
              },
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.red)),
            ),
          ],
        ));
      } else {
        //fixes bug with centering the widget in transition
        return TwoDayOverview(
          today: today,
          tomorrow: tomorrow,
          fromFriendsPage: true,
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

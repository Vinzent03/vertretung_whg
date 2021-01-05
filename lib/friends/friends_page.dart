import 'package:Vertretung/friends/add_friend_dialog.dart';
import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/substitute/no_substitute.dart';
import 'package:Vertretung/substitute/substitute_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatelessWidget {
  final List<FriendModel> friendsSettings;

  const FriendsPage({Key key, this.friendsSettings}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (friendsSettings != null) {
      final List<SubstituteModel> list = FriendLogic.getFriendsSubstitute(
          friendsSettings, context.watch<UserData>().rawSubstituteToday);

      if (friendsSettings.isEmpty) {
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Schade, Du hast wohl keine Freunde",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RaisedButton(
              child: Text("Füge Freunde hinzu!"),
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => AddFriendDialog());
              },
            ),
            RaisedButton(
              child: Text("Freundes Funktion deaktivieren"),
              onPressed: () {
                context.read<UserData>().friendsFeature = false;
              },
            ),
          ],
        ));
      } else {
        if (list.isNotEmpty) {
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) =>
                SubstituteListTile(list[index]),
          );
        } else {
          return NoSubstitute();
        }
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

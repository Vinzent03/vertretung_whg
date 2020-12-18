import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/friends/add_friend_dialog.dart';
import 'package:Vertretung/friends/friend_logic.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/services/dynamic_link.dart';
import 'package:Vertretung/substitute/substitute_from_stream.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class FriendsPage extends StatefulWidget {
  @override
  String toStringShort() {
    return "FriendsPage";
  }

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  FriendLogic friendLogic = FriendLogic();

  void shareFriendsToken() async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    await pr.show();
    String uid = AuthService().getUserId();
    String link = await DynamicLink().createLink();
    String name = await CloudDatabase().getName();
    await pr.hide();
    Share.share("Hier ist der Freundestoken von $name: '" +
        uid.substring(0, 5) +
        "' Dieser muss nun unter 'als Freund eintagen' eingegeben werden. Oder einfach auf diesen Link klicken(nur Android): $link");
  }

  showBottomSheet(context) => showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title: Text("Deinen Freundestoken teilen"),
                  leading: Icon(Icons.share),
                  onTap: () {
                    Navigator.pop(context);
                    shareFriendsToken();
                  }),
              ListTile(
                  title: Text("Als Freund eintragen"),
                  leading: Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => AddFriendDialog());
                  }),
              ListTile(
                title: Text("Freundesliste"),
                leading: Icon(Icons.list),
                onTap: () async {
                  await Navigator.pushNamed(context, Names.friendsList);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Freunde",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => showBottomSheet(context),
            );
          }),
        ],
      ),
      body: StreamBuilder<List<FriendModel>>(
          stream: CloudDatabase().getFriendsSettings(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(
                child: Text(
                    "Ein Fehler aufgetreten: " + snapshot.error.toString()),
              );
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty)
                return Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Schade, Du hast wohl keine Freunde",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    RaisedButton(
                      child: Text("Füge Freunde hinzu!"),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AddFriendDialog());
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
              else
                return AnimatedSwitcher(
                  key: ValueKey(friendLogic.getFriendsSubstitute(
                      snapshot.data,
                      context.select(
                          (UserData value) => value.rawSubstituteToday))),
                  duration: Duration(seconds: 1),
                  child: SubstituteFromStream(
                    key: MyKeys.friendsTab,
                    list: friendLogic.getFriendsSubstitute(
                        snapshot.data,
                        context.select(
                            (UserData value) => value.rawSubstituteToday)),
                    isNotUpdated: false,
                  ),
                );
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
    );
  }
}

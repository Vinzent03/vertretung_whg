import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/friends/addFriendDialog.dart';
import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/models/friendModel.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/dynamicLink.dart';
import 'package:Vertretung/substitute/substituteFromStream.dart';
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
                        SharedPref().setBool(Names.friendsFeature, false);
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

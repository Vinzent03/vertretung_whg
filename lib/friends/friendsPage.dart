import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/theme.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:Vertretung/widgets/generalBlueprint.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  List<Map<String, String>> friendsList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    //reload();
    super.initState();
  }

  Future<void> reload() async {
    await FriendLogic().getLists().then((newFriendsList) {
      setState(() {
        friendsList = newFriendsList;
      });
    });
    _refreshController.refreshCompleted();
  }

  addFriendAlert() async {
    final TextEditingController controller = TextEditingController();
    var friendsList = await CloudDatabase().getFriendsList();
    bool valid = true;

    String isValid(st) {
      if (st != "") {
        if (st.length >= 5) {
          for (var friend in friendsList) {
            if (friend["frienduid"].substring(0, 6).contains(controller.text)) {
              valid = false;
              return "Dieser Nutzer ist bereits in deiner Freundesliste";
            }
          }
        }
        if (st.length < 5) {
          valid = false;
          return "Token zu kurz";
        }
      }

      valid = true;
      return null;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gib den Token deines Freundes ein"),
            content: TextFormField(
              controller: controller,
              autovalidate: true,
              validator: isValid,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () async {
                    if (valid) {
                      Functions().callAddFriendRequest(controller.text);
                      Navigator.pop(context);
                    }
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ThemeChanger>(context).getFriendReload()) {
      reload().then((value) => Provider.of<ThemeChanger>(context, listen: false)
          .setFriendReload(false));
    }
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Freunde",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                String uid = await AuthService().getUserId();
                Share.share("Mein Freundestoken: " + uid.substring(0, 5));
              }),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addFriendAlert(),
          ),
          IconButton(
            icon: Icon(Icons.inbox),
            onPressed: () => Navigator.pushNamed(context, Names.friendRequests),
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, Names.friendsList),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: reload,
        child: GeneralBlueprint(
          isFriendList: true,
          friendsList:friendsList,
        )
      ),
    );
  }
}

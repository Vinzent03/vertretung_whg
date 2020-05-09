import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  List<Map<String, String>> friendsList = [
    {"name": "loading", "ver": "loading"}
  ];
  String name = "Lade...";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    reload();
    super.initState();
  }

  void reload() async {
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
      if(st != ""){
        if (st.length >= 5) {
          for (var friend in friendsList) {
            if (friend["frienduid"].substring(0, 6).contains(controller.text)) {
              valid = false;
              return "Dieser Nutzer ist bereits in deiner Freundesliste";
            }
          }
        }
        if(st.length <5){
          valid = false;
          return"Token zu kurz";
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
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Text(
            "Freunde: ${friendsList.length}",
            textAlign: TextAlign.left,
          ),
          onTap: () => Navigator.pushNamed(context, Names.friendsList),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              String uid = await AuthService().getUserId();
              final SnackBar snack = SnackBar(
                content: Text("Dein Token wurde zur Zwischenablage hinzugefügt"),
              );
              Clipboard.setData(ClipboardData(text: uid.substring(0, 5)));
              Scaffold.of(context).showSnackBar(snack);
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addFriendAlert(),
          ),
          IconButton(
            icon: Icon(Icons.inbox),
            onPressed: () => Navigator.pushNamed(context, Names.friendRequests),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: reload,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                itemCount: friendsList.length,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.blue[700],
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        child: Text(friendsList[index]["name"].substring(0, 2)),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(friendsList[index]["ver"]),
                      subtitle: Text(friendsList[index]["name"]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

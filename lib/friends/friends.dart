import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController controller = TextEditingController();
  int friendsCount = 0;
  String name = "Lade...";
  @override
  void initState() {
      CloudDatabase().getFriendsList().then((anz){
        setState(() {
          friendsCount = anz.length;
        });
      });
      LocalDatabase().getString(Names.name).then((newName){
        setState(() {
          name = newName;
        });
      });
    super.initState();
  }

  addFriendAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gib den Token deines Freundes ein"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () {
                    Functions().callFriendRequest(controller.text);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }
  changeNameAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gib deinen neuen Namen ein"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () {
                    LocalDatabase().setString(Names.name, controller.text);
                    setState(() {
                      name = controller.text;
                    });
                    CloudDatabase().updateName(controller.text);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Freunde"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: FlatButton(
                child: Text("Freunde : $friendsCount"),
                onPressed: () => Navigator.pushNamed(context, Names.friendsList),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: ()async{
                      String uid = await AuthService().getUserId();
                      final SnackBar snack = SnackBar(
                        content: Text("dein Token wurde zur Zwichenablage hinzugefügt"),
                      );
                      Clipboard.setData(ClipboardData(text: uid.substring(0,5)));
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
            ),
            ListTile(
              title: Text(
                "Dein Name: $name"
              ),
              trailing: FlatButton(
                child: Text(
                  "Ändern"
                ),
                onPressed: ()=> changeNameAlert(),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: Text("Darstellung noch nicht festgelegt bzw. keine Idee"),
                  leading: CircleAvatar(
                    child: Text("KA"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

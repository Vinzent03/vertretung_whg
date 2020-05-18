import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<dynamic> list = [
    {"name": "Lade"}
  ];
  void removeFriendAlert(var friend) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Möchtest du ${friend["name"]} wirklich von deiner Freundesliste entfernen?"),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () {
                    setState(() {
                      list.remove(friend);
                    });
                    CloudDatabase().removeFriend(friend["frienduid"]);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  @override
  void initState() {
    CloudDatabase().getFriendsList().then((newList) {
      setState(() {
        list = newList;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Freundes Liste"),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: ListTile(
              leading: CircleAvatar(
                  child: Text(list[index]["name"].substring(0, 2))),
              title: Text(list[index]["name"]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => removeFriendAlert(list[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

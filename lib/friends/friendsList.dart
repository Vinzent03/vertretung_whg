import 'package:Vertretung/friends/friendModel.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<FriendModel> friendList = [];
  bool finishedLoading = false;

  void removeFriendAlert(FriendModel friend) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Möchtest du ${friend.name} wirklich von deiner Freundesliste entfernen?"),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                child: Text("Bestätigen"),
                onPressed: () {
                  setState(() {
                    friendList.remove(friend);
                  });
                  CloudDatabase().removeFriend(friend.uid);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    CloudDatabase().getFriendsList().then((newFriendList) {
      //When the data loads to slow and the page is closed
      if (mounted) {
        setState(() {
          finishedLoading = true;
          friendList = newFriendList;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Freundes Liste(${friendList.length})"),
      ),
      body: finishedLoading
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: friendList.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(friendList[index].name.substring(0, 2))),
                    title: Text(friendList[index].name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeFriendAlert(friendList[index]),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

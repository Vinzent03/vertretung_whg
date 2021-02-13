import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  CloudDatabase cloudDatabase = CloudDatabase();
  void removeFriendAlert(FriendModel friend) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Möchtest Du ${friend.name} wirklich von Deiner Freundesliste entfernen?"),
            actions: <Widget>[
              TextButton(
                child: Text("Abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Bestätigen"),
                onPressed: () {
                  CloudDatabase().removeFriend(friend.uid);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Freundes Liste"),
      ),
      body: StreamBuilder<List<FriendModel>>(
        stream: cloudDatabase.getFriendsSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child:
                  Text("Ein Fehler aufgetreten: " + snapshot.error.toString()),
            );
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty)
              return Center(
                child: Text("Schade, Du hast wohl keine Freunde."),
              );
            else
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: ListTile(
                      leading: CircleAvatar(
                          child:
                              Text(snapshot.data[index].name.substring(0, 2))),
                      title: Text(snapshot.data[index].name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            removeFriendAlert(snapshot.data[index]),
                      ),
                    ),
                  );
                },
              );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

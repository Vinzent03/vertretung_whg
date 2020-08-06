import 'package:Vertretung/friends/friendModel.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';

class FriendRequests extends StatefulWidget {
  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  List<FriendModel> friendRequests = [];
  bool finishedLoading = false;

  @override
  void initState() {
    CloudDatabase().getFriendRequests().then((newList) {
      //When the data loads to slow and the page is closed
      if (mounted) {
        setState(() {
          friendRequests = newList;
          finishedLoading = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Freundes Anfragen"),
      ),
      body: finishedLoading
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: friendRequests.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(friendRequests[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                          child: Text("ablehnen"),
                          onPressed: () async {
                            Map res = await Functions().declineFriendRequest(
                                friendRequests[index].name);
                            if (res == null)
                              setState(() {
                                friendRequests.remove(friendRequests[index]);
                              });
                            else
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Es ist ein unerwarteter Fehler aufgetreten : " +
                                        res["message"]),
                              ));
                          }),
                      RaisedButton(
                        child: Text("annehmen"),
                        onPressed: () async {
                          Map res = await Functions()
                              .acceptFriendRequest(friendRequests[index].uid);
                          if (res == null)
                            setState(() {
                              friendRequests.remove(friendRequests[index]);
                            });
                          else
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Es ist ein unerwarteter Fehler aufgetreten : " +
                                      res["message"]),
                            ));
                        },
                      ),
                    ],
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

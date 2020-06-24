import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';

class FriendRequests extends StatefulWidget {
  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  List<dynamic> list = [];
  bool finishedLoading = false;

  @override
  void initState() {
    CloudDatabase().getFriendRequests().then((newList) {
      //When the data loads to slow and the page is closed
      if (mounted) {  
        setState(() {
          list = newList;
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
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(list[index]["name"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                          child: Text("ablehnen"),
                          onPressed: () {
                            Functions().declineFriendRequest(
                                list[index]["frienduid"]);
                            setState(() {
                              list.remove(list[index]);
                            });
                          }),
                      RaisedButton(
                        child: Text("annhemen"),
                        onPressed: () {
                          Functions().acceptFriendRequest(
                              list[index]["frienduid"]);
                          setState(() {
                            list.remove(list[index]);
                          });
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

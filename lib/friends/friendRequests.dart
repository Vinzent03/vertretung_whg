import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class FriendRequests extends StatefulWidget {
  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  List<String> list = [""];

  @override
  void initState(){
    CloudDatabase().getFriendRequests().then((newList){
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
        title: Text("Freundes Anfragen"),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(list[index]),
            trailing: RaisedButton(
              child: Text("annhemen"),
              onPressed: () {
                CloudDatabase().addFriend(list[index]);
                setState(() {
                  list.remove(list[index]);
                });
              },
            ),
          );
        },
      ),
    );
  }
}

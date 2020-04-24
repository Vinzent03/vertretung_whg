import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<String> list = [""];
  @override
  void initState() {
    CloudDatabase().getFriendsList().then((newList){
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
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(list[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                setState(() {
                  CloudDatabase().removeFriend(list[index]);
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

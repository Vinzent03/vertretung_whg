import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<dynamic> list = [{"name":""}];
  @override
  void initState() {
    CloudDatabase().getFriendsList().then((newList){
      setState(() {
        list = newList;
        print(list);
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
          return ListTile(
            title: Text(list[index]["name"]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                setState(() {
                  CloudDatabase().removeFriend(list[index]["frienduid"]);
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

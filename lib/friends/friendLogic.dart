import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendLogic {
  final Firestore ref = Firestore.instance;

  Future<List> individual(String frienduid) async {
    DocumentSnapshot snap =
        await ref.collection("userdata").document(frienduid).get();
    Filter filter = Filter(snap["stufe"]);
    if (snap.data["faecherOn"]) {
      var list = await filter.checkerFaecher(
          Names.lessonsToday, snap["faecher"], snap["faecherNot"]);
      return list[0];
    }else{
      var list = await filter.checker(
          Names.lessonsToday,);
      return list[0];
    }
  }

  Future<List<Map<String, String>>> getLists() async {
    List<Map<String, String>> newFriendsList = [];
    List<dynamic> anz = await CloudDatabase().getFriendsList();
    for (var user in anz) {
      List<String> list = await individual(user["frienduid"]);
      for (String ver in list) {
        if (newFriendsList.isNotEmpty) {
          List<String> lol = [];
          for(var st in newFriendsList){
          lol.add(st["ver"]);
        }


          if (lol.contains(ver)) {
            for (var oldVer in newFriendsList) {
              if (oldVer["ver"] == ver) {
                oldVer["name"] = oldVer["name"] +", " +user["name"];
              }
            }
          }else {
            newFriendsList.add({
              "name": user["name"],
              "ver": ver,
            });
          }
        } else {
          newFriendsList.add({
            "name": user["name"],
            "ver": ver,
          });
        }
      }
    }
    return newFriendsList;
  }
}

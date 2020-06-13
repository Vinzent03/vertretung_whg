import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendLogic {
  final Firestore ref = Firestore.instance;

  ///get Vertretung for the given user
  Future<List> individual(String frienduid) async {
    DocumentSnapshot snap =
        await ref.collection("userdata").document(frienduid).get();
    Filter filter = Filter(snap["schoolClass"]);
    if (snap.data["personalSubstitute"]) {
      var list = await filter.checkForSubjects(
          Names.substituteToday, snap.data["subjects"], snap.data["subjectsNot"]);
      return list;
    } else {
      var list = await filter.checkForSchoolClass(
        Names.substituteToday,
      );
      return list;
    }
  }

  Future<dynamic> getFriendVertretung(List<dynamic> users) async {
    List<Map<String, String>> friendsVertretung = [];

    for (var user in users) {
      List<dynamic> list = await individual(user["frienduid"]);
      for (var vertretung in list) {
        if (friendsVertretung.isNotEmpty) {
          List<String> temporarilyfriendVertretung = [];
          for (var st in friendsVertretung) {
            temporarilyfriendVertretung.add(st["ver"]);
          }

          if (temporarilyfriendVertretung.contains(vertretung["ver"])) {
            //add the name to the list who have this Vertretung
            for (var oldVer in friendsVertretung) {
              if (oldVer["ver"] == vertretung["ver"]) {
                oldVer["name"] = oldVer["name"] + ", " + user["name"];
              }
            }
          } else {
            //nobody else has this Vertretung
            friendsVertretung.add({
              "name": user["name"],
              "ver": vertretung["ver"],
              "subjectPrefix": vertretung["subjectPrefix"]
            });
          }
        } else {
          //first Vertretung in the List
          friendsVertretung.add({
            "name": user["name"],
            "ver": vertretung["ver"],
            "subjectPrefix": vertretung["subjectPrefix"]
          });
        }
      }
    }
    return friendsVertretung;
  }
}

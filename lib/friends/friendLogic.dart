import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendLogic {
  final Firestore ref = Firestore.instance;

  ///get Substitute for the given user
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
    List<Map<String, String>> friendsSubstitute = [];

    for (var user in users) {
      List<dynamic> list = await individual(user["frienduid"]);
      for (var substitute in list) {
        if (friendsSubstitute.isNotEmpty) {
          List<String> temporarilyfriendVertretung = [];
          for (var st in friendsSubstitute) {
            temporarilyfriendVertretung.add(st["ver"]);
          }

          if (temporarilyfriendVertretung.contains(substitute["ver"])) {
            //add the name to the list who have this Substitute
            for (var oldVer in friendsSubstitute) {
              if (oldVer["ver"] == substitute["ver"]) {
                oldVer["name"] = oldVer["name"] + ", " + user["name"];
              }
            }
          } else {
            //nobody else has this Substitute
            friendsSubstitute.add({
              "name": user["name"],
              "ver": substitute["ver"],
              "subjectPrefix": substitute["subjectPrefix"]
            });
          }
        } else {
          //first Substitute in the List
          friendsSubstitute.add({
            "name": user["name"],
            "ver": substitute["ver"],
            "subjectPrefix": substitute["subjectPrefix"]
          });
        }
      }
    }
    return friendsSubstitute;
  }
}

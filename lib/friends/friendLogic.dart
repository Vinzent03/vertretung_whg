import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Vertretung/friends/friendModel.dart';

class FriendLogic {
  final Firestore ref = Firestore.instance;
  SharedPref sharedPref = SharedPref();
  List<String> rawSubstituteList;
  List<FriendModel> friends = [];

  Future<void> setFriendsSettings() async {
    for (var friend in friends) {
      DocumentSnapshot snap =
          await ref.collection("userdata").document(friend.uid).get();
      friend.subjects = snap.data[Names.subjects];
      friend.subjectsNot = snap.data[Names.subjectsNot];
      friend.personalSubstitute = snap.data[Names.personalSubstitute];
      friend.schoolClass = snap.data[Names.schoolClass];
    }
  }

  List _getSubstituteOfFriend(FriendModel friend) {
    Filter filter = Filter(friend.schoolClass, rawSubstituteList);
    if (friend.personalSubstitute) {
      var list = filter.checkForSubjects(friend.subjects, friend.subjectsNot);
      return list;
    } else {
      var list = filter.checkForSchoolClass();
      return list;
    }
  }

  Future<dynamic> getFriendsSubstitute() async {
    List<Map<String, String>> friendsSubstitute = [];
    rawSubstituteList = await sharedPref.getStringList(Names.substituteToday);

    for (var friend in friends) {
      List<dynamic> list = _getSubstituteOfFriend(friend);
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
                oldVer["name"] = oldVer["name"] + ", " + friend.name;
              }
            }
          } else {
            //nobody else has this Substitute
            friendsSubstitute.add({
              "name": friend.name,
              "ver": substitute["ver"],
              "subjectPrefix": substitute["subjectPrefix"]
            });
          }
        } else {
          //first Substitute in the List
          friendsSubstitute.add({
            "name": friend.name,
            "ver": substitute["ver"],
            "subjectPrefix": substitute["subjectPrefix"]
          });
        }
      }
    }
    return friendsSubstitute;
  }

  Future<void> updateFriendsList(List<FriendModel> newFriends) async {
    friends = newFriends;
    await setFriendsSettings();
  }
}

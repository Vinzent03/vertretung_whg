import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/models/substituteModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Vertretung/models/friendModel.dart';

class FriendLogic {
  final FirebaseFirestore ref = FirebaseFirestore.instance;
  SharedPref sharedPref = SharedPref();
  List<String> rawSubstituteList;
  List<FriendModel> friends = [];
  bool friendsLoaded = false;

  Future<void> setFriendsSettings() async {
    for (var friend in friends) {
      DocumentSnapshot snap =
          await ref.collection("userdata").doc(friend.uid).get();
      friend.subjects = snap.data()[Names.subjects];
      friend.subjectsNot = snap.data()[Names.subjectsNot];
      friend.personalSubstitute = snap.data()[Names.personalSubstitute];
      friend.schoolClass = snap.data()[Names.schoolClass];
    }
  }

  List<SubstituteModel> _getSubstituteOfFriend(FriendModel friend) {
    Filter filter = Filter(friend.schoolClass, rawSubstituteList);
    List<SubstituteModel> substitute;
    List<SubstituteModel> justCancelledLessons = [];
    if (friend.personalSubstitute) {
      var list = filter.checkForSubjects(friend.subjects, friend.subjectsNot);
      substitute = list;
    } else {
      var list = filter.checkForSchoolClass();
      substitute = list;
    }
    for (SubstituteModel item in substitute) {
      if (item.title.contains("Entfall")) justCancelledLessons.add(item);
    }
    return justCancelledLessons;
  }

  Future<List<SubstituteModel>> getFriendsSubstitute() async {
    if (!friendsLoaded) return [];
    List<SubstituteModel> friendsSubstitute = [];
    rawSubstituteList = await sharedPref.getStringList(Names.substituteToday);

    for (var friend in friends) {
      List<SubstituteModel> list = _getSubstituteOfFriend(friend);
      for (SubstituteModel substitute in list) {
        if (friendsSubstitute.isNotEmpty) {
          List<String> temporarilyfriendVertretung = [];
          for (var st in friendsSubstitute) {
            temporarilyfriendVertretung.add(st.title);
          }

          if (temporarilyfriendVertretung.contains(substitute.title)) {
            //add the name to the list who have this Substitute
            for (var oldVer in friendsSubstitute) {
              if (oldVer.title == substitute.title) {
                oldVer.names = oldVer.names + ", " + friend.name;
              }
            }
          } else {
            //nobody else has this Substitute
            friendsSubstitute.add(SubstituteModel(
                substitute.title, substitute.subjectPrefix, friend.name));
          }
        } else {
          //first Substitute in the List
          friendsSubstitute.add(SubstituteModel(
              substitute.title, substitute.subjectPrefix, friend.name));
        }
      }
    }
    return friendsSubstitute;
  }

  Future<void> updateFriendsList(List<FriendModel> newFriends) async {
    friends = newFriends;
    await setFriendsSettings();
    friendsLoaded = true;
  }
}

import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/data/names.dart';
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
    if (friends.isEmpty) return;
    QuerySnapshot friendsData = await ref
        .collection("userdata")
        .where("__name__", whereIn: friends.map((e) => e.uid).toList())
        .get();
    for (QueryDocumentSnapshot friendDoc in friendsData.docs) {
      FriendModel friend =
          friends.firstWhere((element) => element.uid == friendDoc.id);
      friend.subjects = friendDoc.data()[Names.subjects];
      friend.subjectsNot = friendDoc.data()[Names.subjectsNot];
      friend.personalSubstitute = friendDoc.data()[Names.personalSubstitute];
      friend.schoolClass = friendDoc.data()[Names.schoolClass];
      friend.freeLessons = friendDoc.data()[Names.freeLessons] ?? [];
      friend.name = friendDoc.data()["name"];
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

  bool _isLessonOver(int lesson, DateTime now) {
    List<Map<String, int>> lessons = [
      {
        "hour": 8,
        "minute": 45,
      },
      {
        "hour": 9,
        "minute": 35,
      },
      {
        "hour": 10,
        "minute": 25,
      },
      {
        "hour": 11,
        "minute": 35,
      },
      {
        "hour": 12,
        "minute": 25,
      },
      {
        "hour": 13,
        "minute": 30,
      },
      {
        "hour": 14,
        "minute": 20,
      },
      {
        "hour": 15,
        "minute": 10,
      },
      {
        "hour": 16,
        "minute": 00,
      },
    ];
    return now.isAfter(DateTime(now.year, now.month, now.day,
        lessons[lesson - 1]["hour"], lessons[lesson - 1]["minute"]));
  }

  List<SubstituteModel> _getFreeLessonsOfFriend(FriendModel friend) {
    List<SubstituteModel> freeLessons = [];
    DateTime now = DateTime.now();
    //cycle thru free lessons entries
    for (int i = 0; i < friend.freeLessons.length; i++) {
      String entry = friend.freeLessons[i];
      int lesson = int.parse(entry.substring(1, 2));
      int weekday = int.parse(entry.substring(0, 1));
      //use only free lessons of current weekday
      if (weekday != now.weekday - 1) continue;
      if (_isLessonOver(lesson, now)) continue;
      if (freeLessons.isNotEmpty) {
        if (freeLessons.last.title.contains((lesson - 1).toString())) {
          //change lesson range
          if (freeLessons.last.title.contains("-"))
            freeLessons.last.title =
                freeLessons.last.title.replaceRange(5, 6, lesson.toString());
          //change from single to multi lesson
          else
            freeLessons.last.title =
                "${(lesson - 1).toString()}. - ${lesson.toString()} Std. Freistunde";
        } else
          freeLessons.add(
              SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
      } else
        freeLessons.add(
            SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
    }

    return freeLessons;
  }

  /// includes substitute and free lessons
  Future<List<SubstituteModel>> getFriendsSubstitute() async {
    if (!friendsLoaded) return [];
    List<SubstituteModel> friendsSubstitute = [];
    rawSubstituteList = await sharedPref.getStringList(Names.substituteToday);

    for (FriendModel friend in friends) {
      List<SubstituteModel> substituteAndFreeLessons =
          _getSubstituteOfFriend(friend) + _getFreeLessonsOfFriend(friend);
      for (SubstituteModel substitute in substituteAndFreeLessons) {
        if (friendsSubstitute.map((e) => e.title).contains(substitute.title)) {
          //instead of showing a substitute doubled add the name to the existing one
          friendsSubstitute
              .firstWhere((element) => element.title == substitute.title)
              .names += ", " + friend.name;
        } else {
          //nobody else has this substitute so far
          friendsSubstitute.add(SubstituteModel(
              substitute.title, substitute.subjectPrefix, friend.name));
        }
      }
    }
    return friendsSubstitute;
  }

  Future<List<SubstituteModel>> getFriendsFreeLessons() async {
    if (!friendsLoaded) return [];
    List<SubstituteModel> friendsFreeLessons = [];
    for (FriendModel friend in friends) {
      _getFreeLessonsOfFriend(friend).forEach((element) {
        friendsFreeLessons.add(element);
      });
    }
    return friendsFreeLessons;
  }

  Future<void> updateFriendsList(List<FriendModel> newFriends) async {
    friends = newFriends;
    await setFriendsSettings();
    friendsLoaded = true;
  }
}
